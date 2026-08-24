import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/domain/ui_value/yearly_balance_value/yearly_balance_value.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_empty_state.dart';
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
              return AppEmptyState(
                icon: Icons.show_chart_rounded,
                title: '家計簿をはじめましょう',
                description: '毎日の収支を記録するとグラフが表示されます',
                buttonLabel: '＋ 記録を追加する',
                onPressed: () {
                  showAppModalBottomSheet(
                    context,
                    child: const RegisaterPageBase.addExpense(),
                  );
                },
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.sm),

                        // ========== 支出行 ==========
                        if (hasExpense)
                          // データあり行
                          AppInkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              final dateScope = ref
                                  .read(homeDateScopeEntityProvider)
                                  .value!;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => YearlyExpenseListPage(
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
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: context.colors.expense,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '総支出',
                                            style: AppTextStyles
                                                .appCardPrimaryTitleLabel,
                                          ),
                                          WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: AppSpacing.xs,
                                              ),
                                              child: Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 12,
                                                color:
                                                    context.colors.textSecondary,
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
                                  style: AppTextStyles.listTilePriceLabel,
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
                                    color: context.colors.expense
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  '＋ 支出を登録する',
                                  style: AppTextStyles.appCardPrimaryTitleLabel
                                      .copyWith(
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: AppSpacing.sm),

                        // 支出バー（両方あるときのみ）
                        if (showBars)
                          AnimatedContainer(
                            height: 8.5,
                            width: isBuilt ? expenseBar : barInitialWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: context.colors.expense,
                            ),
                            duration: const Duration(milliseconds: 500),
                          ),

                        SizedBox(
                          height: showBars ? AppSpacing.lg : AppSpacing.sm,
                        ),

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
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: context.colors.income,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '総収入',
                                            style: AppTextStyles
                                                .appCardPrimaryTitleLabel,
                                          ),
                                          WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: AppSpacing.xs,
                                              ),
                                              child: Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 12,
                                                color:
                                                    context.colors.textSecondary,
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
                                  style: AppTextStyles.listTilePriceLabel,
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
                                    color: context.colors.income.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  '＋ 収入を登録する',
                                  style: AppTextStyles.appCardPrimaryTitleLabel
                                      .copyWith(
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: AppSpacing.sm),

                        // 収入バー（両方あるときのみ）
                        if (showBars)
                          AnimatedContainer(
                            height: 8.5,
                            width: isBuilt ? incomeBar : barInitialWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: context.colors.income,
                            ),
                            duration: const Duration(milliseconds: 500),
                          ),

                        // 残金行（両方あるときのみ）
                        if (showBars) ...[
                          const SizedBox(height: AppSpacing.md),
                          Divider(
                            thickness: 1.0,
                            height: 4.0,
                            color: context.colors.separator,
                          ),
                          const SizedBox(height: AppSpacing.xs),
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

                        const SizedBox(height: AppSpacing.xs),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          // ローディングはトップレベル(PageLoadingIndicator)で吸収する
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => const AppErrorState(),
        );
  }
}
