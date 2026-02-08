import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthy_plan_home_page/summary_bar_graph.dart';
import 'package:kakeibo/view/monthly_page/skeleton/monthly_plan_skeleton.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_all_category_tile_entity_provider.dart';

/// 予算ページ上部のサマリーエリア
/// 予算合計と収入合計のみを表示する（支出のテキスト情報は含まない）
/// 棒グラフは予算カテゴリー別と収入カテゴリー別でそれぞれ表示する
/// denominator = max(予算合計, 収入合計) で両方の棒グラフを統一スケールにする
class BudgetPageSummaryArea extends HookConsumerWidget {
  const BudgetPageSummaryArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedAllCategoryCardModelProvider).when(
          data: (allCategoryCardEntity) {
            // 予算と収入の大きい方を棒グラフの基準にする
            final budgetIncomeDenominator = max(
                allCategoryCardEntity.allCategoryTotalBudget,
                allCategoryCardEntity.allCategoryTotalIncome);

            // 予定収支 = 収入 - 予算
            final projectedSavings =
                allCategoryCardEntity.allCategoryTotalIncome -
                    allCategoryCardEntity.allCategoryTotalBudget;

            return CardContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 予算エリア
                  if (allCategoryCardEntity.cardStatusType.hasBudget)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '予算',
                                style: AppTextStyles.appCardTitleLabel,
                              ),
                              const SizedBox(width: 8),
                              RichText(
                                textAlign: TextAlign.end,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: formattedPriceGetter(
                                        allCategoryCardEntity
                                            .allCategoryTotalBudget),
                                    style: AppTextStyles
                                        .appCardOptionalSecondaryPriceLabel,
                                  ),
                                  TextSpan(
                                    text: ' 円',
                                    style:
                                        AppTextStyles.appCardSecondaryPriceUnit,
                                  ),
                                ]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: LayoutBuilder(
                              builder: (context, constraints) =>
                                  SummaryBarGraph(
                                amounts:
                                    allCategoryCardEntity.budgetCategoryList,
                                colors:
                                    allCategoryCardEntity.budgetCategoryColorList,
                                denominator: budgetIncomeDenominator,
                                maxGraphWidth: constraints.maxWidth,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 収入エリア
                  if (allCategoryCardEntity.cardStatusType.hasIncome)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '総収入',
                                    style: AppTextStyles.appCardTitleLabel,
                                  ),
                                  const SizedBox(width: 8),
                                  RichText(
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text: formattedPriceGetter(
                                            allCategoryCardEntity
                                                .allCategoryTotalIncome),
                                        style: AppTextStyles
                                            .appCardOptionalSecondaryPriceLabel,
                                      ),
                                      TextSpan(
                                        text: ' 円',
                                        style: AppTextStyles
                                            .appCardSecondaryPriceUnit,
                                      ),
                                    ]),
                                  ),
                                ],
                              ),
                              // 予定収支
                              if (projectedSavings != 0)
                                Flexible(
                                  child: RichText(
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text: '予定収支 ',
                                        style: AppTextStyles
                                            .appCardTertiaryTitleLabel,
                                      ),
                                      TextSpan(
                                        text: formattedPriceGetter(
                                            projectedSavings),
                                        style: AppTextStyles
                                            .appCardTertiaryPriceLabel,
                                      ),
                                      TextSpan(
                                        text: ' 円',
                                        style: AppTextStyles
                                            .appCardTertiaryPriceUnit,
                                      ),
                                    ]),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: LayoutBuilder(
                              builder: (context, constraints) =>
                                  SummaryBarGraph(
                                amounts:
                                    allCategoryCardEntity.incomeCategoryList,
                                colors:
                                    allCategoryCardEntity.incomeCategoryColorList,
                                denominator: budgetIncomeDenominator,
                                maxGraphWidth: constraints.maxWidth,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),
                ],
              ),
            );
          },
          loading: () => const MonthlyPlanSkeleton(),
          error: (error, stack) => Center(child: Text('$error')),
        );
  }
}
