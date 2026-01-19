import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/yearly_balance_value/yearly_balance_value.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/card_container.dart';
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
  Widget build(BuildContext context) {
    /// ビルドが完了したら横棒グラフのサイズを変更しアニメーションが動く
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isBuilt = true;
    });

    return ref.watch(resolvedYearlyBalanceValueProvider).when(
          data: (yearlyBalanceValue) {
            if (yearlyBalanceValue.yearlyBalanceType ==
                YearlyBalanceType.noRecorod) {
              return CardContainer(
                width: double.infinity,
                height: 30,
                child: Center(
                  child: Text(
                    'まだ記録がありません',
                    style: AppTextStyles.listCardSecondaryTitle,
                  ),
                ),
              );
            }
            return LayoutBuilder(builder: (context, constraints) {
              // =============グラフサイズ計算================
              /// 画面の横幅を取得し、棒グラフの幅を設定
              /// 横幅の70%を大きい方の棒グラフの幅に設定
              final double largerBarFrameWidth = constraints.maxWidth * 0.7;

              //横棒グラフの初期値
              double barInitialWidth = 0;

              // アニメーション後の小さい方の横棒グラフの幅を計算
              double smallerBarDegrees;
              if (yearlyBalanceValue.yearlyBalanceType ==
                  YearlyBalanceType.surplus) {
                smallerBarDegrees = (yearlyBalanceValue.yearlyExpense /
                    yearlyBalanceValue.yearlyIncome);
              } else if (yearlyBalanceValue.yearlyBalanceType ==
                  YearlyBalanceType.deficit) {
                smallerBarDegrees = (yearlyBalanceValue.yearlyIncome /
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

              return CardContainer(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 8,
                      ),

                      // 支出
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '総支出  ',
                            style: AppTextStyles.appCardTitleLabel,
                          ),
                          yearlyBalanceValue.yearlyBalanceType !=
                                  YearlyBalanceType.noExpense
                              ? Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      formattedPriceGetter(
                                          yearlyBalanceValue.yearlyExpense),
                                      style: AppTextStyles.listCardPriceLabel,
                                    ),
                                    Text(
                                      ' 円',
                                      style: AppTextStyles
                                          .appCardSecondaryPriceUnit,
                                    ),
                                  ],
                                )
                              : Text(
                                  'まだ記録がありません',
                                  style: AppTextStyles.listCardSecondaryTitle,
                                ),
                        ],
                      ),

                      // 支出バー
                      yearlyBalanceValue.yearlyBalanceType !=
                              YearlyBalanceType.noExpense
                          ? AnimatedContainer(
                              height: 10,
                              width: isBuilt ? expenseBar : barInitialWidth,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: MyColors.pink,
                              ),
                              duration: const Duration(milliseconds: 500),
                            )
                          : Container(),

                      const SizedBox(
                        height: 12.0,
                      ),

                      AppInkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          final dateScope =
                              ref.read(homeDateScopeEntityProvider).value!;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => YearlyIncomeListPage(
                                dateScope: dateScope,
                              ),
                            ),
                          );
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '総収入',
                                style: AppTextStyles.appCardTitleLabel,
                              ),
                              const Icon(
                                size: 12,
                                Icons.arrow_forward_ios_rounded,
                                color: MyColors.secondaryLabel,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              yearlyBalanceValue.yearlyBalanceType !=
                                      YearlyBalanceType.noIncome
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                            formattedPriceGetter(
                                                yearlyBalanceValue
                                                    .yearlyIncome),
                                            style: AppTextStyles
                                                .listCardPriceLabel),
                                        Text(
                                          ' 円',
                                          style: AppTextStyles
                                              .appCardSecondaryPriceUnit,
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'まだ記録がありません',
                                      style:
                                          AppTextStyles.listCardSecondaryTitle,
                                    ),
                            ]),
                      ),

                      // 収入バー
                      yearlyBalanceValue.yearlyBalanceType !=
                              YearlyBalanceType.noIncome
                          ? AnimatedContainer(
                              height: 10,
                              width: isBuilt ? incomeBar : barInitialWidth,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: MyColors.mintBlue,
                              ),
                              duration: const Duration(milliseconds: 500),
                            )
                          : Container(),

                      const SizedBox(
                        height: 12.0,
                      ),

                      const Divider(
                        thickness: 1.0,
                        height: 4.0,
                        color: MyColors.separater,
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '残金',
                            style: AppTextStyles.appCardTitleLabel,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                formattedPriceGetter(
                                    yearlyBalanceValue.savings),
                                style: AppTextStyles.appCardPriceLabel,
                              ),
                              Text(
                                ' 円',
                                style: AppTextStyles.appCardPriceUnit,
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 4,
                      )
                    ],
                  ),
                ),
              );
            });
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('$error')),
        );
  }
}
