import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/yearly_balance_value/yearly_balance_value.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';
import 'package:kakeibo/view/yearly_expense_list_page/yearly_expense_list_page.dart';
import 'package:kakeibo/view/yearly_income_list_page/yearly_income_list_page.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_yearly_balance_provider.dart';
import 'package:kakeibo/view_model/state/date_scope/home_page/home_date_scope.dart';

class YearlyBalanceArea extends ConsumerStatefulWidget {
  const YearlyBalanceArea({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _YearlyBalanceAreaState();
}

class _YearlyBalanceAreaState extends ConsumerState<YearlyBalanceArea> {
  /// アニメーション用フラグ
  bool isBuilt = false;

  @override
  void initState() {
    super.initState();
    /// ビルドが完了したら横棒グラフのサイズを変更しアニメーションが動く
    /// setState を呼ばないと AnimatedContainer.width に反映されないので注意
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => isBuilt = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(resolvedYearlyBalanceValueProvider)
        .when(
          data: (yearlyBalanceValue) {
            if (yearlyBalanceValue.yearlyBalanceType ==
                YearlyBalanceType.noRecorod) {
              return CardContainer(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.show_chart_rounded,
                        size: 32,
                        color: MyColors.secondaryLabel,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '家計簿をはじめましょう',
                        style: AppTextStyles.appCardTitleLabel,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '毎日の収支を記録するとグラフが表示されます',
                        style: AppTextStyles.listCardSecondaryTitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: MainButton(
                          buttonText: '＋ 記録を追加する',
                          onPressed: () {
                            showAppModalBottomSheet(
                              context,
                              child: const RegisaterPageBase.addExpense(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                // =============グラフサイズ計算================
                /// 画面の横幅を取得し、棒グラフの幅を設定
                /// カードの左右パディング(16*2)を除いた横幅いっぱいを大きい方の棒グラフ幅とする
                final double largerBarFrameWidth = constraints.maxWidth - 32;

                //横棒グラフの初期値
                double barInitialWidth = 0;

                // アニメーション後の小さい方の横棒グラフの幅を計算
                double smallerBarDegrees;
                if (yearlyBalanceValue.yearlyBalanceType ==
                    YearlyBalanceType.surplus) {
                  smallerBarDegrees =
                      (yearlyBalanceValue.yearlyExpense /
                      yearlyBalanceValue.yearlyIncome);
                } else if (yearlyBalanceValue.yearlyBalanceType ==
                    YearlyBalanceType.deficit) {
                  smallerBarDegrees =
                      (yearlyBalanceValue.yearlyIncome /
                              yearlyBalanceValue.yearlyExpense)
                          .abs();
                } else {
                  smallerBarDegrees = 0.0;
                }
                double smallerBarFrameWidth =
                    largerBarFrameWidth * smallerBarDegrees;

                // 収入と支出のグラフ幅を決定
                double incomeBar;
                double expenseBar;
                if (yearlyBalanceValue.yearlyBalanceType ==
                    YearlyBalanceType.surplus) {
                  incomeBar = largerBarFrameWidth;
                  expenseBar = smallerBarFrameWidth;
                } else if (yearlyBalanceValue.yearlyBalanceType ==
                    YearlyBalanceType.deficit) {
                  incomeBar = smallerBarFrameWidth;
                  expenseBar = largerBarFrameWidth;
                } else {
                  incomeBar = 0.0;
                  expenseBar = 0.0;
                }
                // =============グラフサイズ計算ここまで================

                // 収入・支出それぞれの記録有無
                final bool hasExpense =
                    yearlyBalanceValue.yearlyBalanceType ==
                            YearlyBalanceType.surplus ||
                        yearlyBalanceValue.yearlyBalanceType ==
                            YearlyBalanceType.deficit ||
                        yearlyBalanceValue.yearlyBalanceType ==
                            YearlyBalanceType.noIncome;
                final bool hasIncome =
                    yearlyBalanceValue.yearlyBalanceType ==
                            YearlyBalanceType.surplus ||
                        yearlyBalanceValue.yearlyBalanceType ==
                            YearlyBalanceType.deficit ||
                        yearlyBalanceValue.yearlyBalanceType ==
                            YearlyBalanceType.noExpense;
                // バーと残金行は両方記録がある場合のみ表示
                final bool showBars =
                    yearlyBalanceValue.yearlyBalanceType ==
                            YearlyBalanceType.surplus ||
                        yearlyBalanceValue.yearlyBalanceType ==
                            YearlyBalanceType.deficit;

                return CardContainer(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // ========== 支出行 ==========
                        if (hasExpense)
                          // データあり行
                          AppInkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const YearlyExpenseListPage(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: MyColors.pink,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '総支出',
                                            style: AppTextStyles
                                                .appCardPrimaryTitleLabel,
                                          ),
                                          const WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: Padding(
                                              padding: EdgeInsets.only(left: 4),
                                              child: Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 12,
                                                color: MyColors.secondaryLabel,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  yenmarkFormattedPriceGetter(
                                    yearlyBalanceValue.yearlyExpense,
                                  ),
                                  style: AppTextStyles.listCardPriceLabel,
                                ),
                              ],
                            ),
                          )
                        else
                          // CTA行（支出なし）
                          AppInkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              showAppModalBottomSheet(
                                context,
                                child:
                                    const RegisaterPageBase.addExpense(),
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: MyColors.pink.withValues(alpha: 0.4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '＋ 支出を登録する',
                                  style: AppTextStyles.appCardPrimaryTitleLabel
                                      .copyWith(
                                    color: MyColors.secondaryLabel,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 8.0),

                        // 支出バー（両方あるときのみ）
                        if (showBars)
                          AnimatedContainer(
                            height: 8.5,
                            width: isBuilt ? expenseBar : barInitialWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: MyColors.pink,
                            ),
                            duration: const Duration(milliseconds: 500),
                          ),

                        SizedBox(height: showBars ? 16.0 : 8.0),

                        // ========== 収入行 ==========
                        if (hasIncome)
                          // データあり行
                          AppInkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              final dateScope = ref
                                  .read(homeDateScopeEntityProvider)
                                  .value!;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => YearlyIncomeListPage(
                                    period: dateScope.yearPeriod,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: MyColors.incomeEmerald,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '総収入',
                                            style: AppTextStyles
                                                .appCardPrimaryTitleLabel,
                                          ),
                                          const WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: Padding(
                                              padding: EdgeInsets.only(left: 4),
                                              child: Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 12,
                                                color: MyColors.secondaryLabel,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  yenmarkFormattedPriceGetter(
                                    yearlyBalanceValue.yearlyIncome,
                                  ),
                                  style: AppTextStyles.listCardPriceLabel,
                                ),
                              ],
                            ),
                          )
                        else
                          // CTA行（収入なし）
                          AppInkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              showAppModalBottomSheet(
                                context,
                                child:
                                    const RegisaterPageBase.addIncome(),
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: MyColors.incomeEmerald.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '＋ 収入を登録する',
                                  style: AppTextStyles.appCardPrimaryTitleLabel
                                      .copyWith(
                                    color: MyColors.secondaryLabel,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 8.0),

                        // 収入バー（両方あるときのみ）
                        if (showBars)
                          AnimatedContainer(
                            height: 8.5,
                            width: isBuilt ? incomeBar : barInitialWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: MyColors.incomeEmerald,
                            ),
                            duration: const Duration(milliseconds: 500),
                          ),

                        // 残金行（両方あるときのみ）
                        if (showBars) ...[
                          const SizedBox(height: 12.0),
                          const Divider(
                            thickness: 1.0,
                            height: 4.0,
                            color: MyColors.separater,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '残金',
                                style: AppTextStyles.appCardTitleLabel,
                              ),
                              Text(
                                signedYenmarkFormattedPriceGetter(
                                  yearlyBalanceValue.savings,
                                ),
                                style: AppTextStyles.appCardPriceLabel,
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          // ローディングはトップレベル(PageLoadingIndicator)で吸収する
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => Center(child: Text('$error')),
        );
  }
}
