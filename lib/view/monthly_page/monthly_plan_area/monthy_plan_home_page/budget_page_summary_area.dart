import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthly_plan_area_parts/monthly_plan_graph_area/monthly_plan_graph_parts.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthly_plan_area_parts/monthly_income_graph_area/monthly_income_graph_parts.dart';
import 'package:kakeibo/view/monthly_page/skeleton/monthly_plan_skeleton.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_all_category_tile_entity_provider.dart';

/// 予算ページ上部のサマリーエリア
/// 予算合計と収入合計のみを表示する（支出のテキスト情報は含まない）
/// 棒グラフは予算と収入それぞれ表示する
class BudgetPageSummaryArea extends HookConsumerWidget {
  const BudgetPageSummaryArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedAllCategoryCardModelProvider).when(
          data: (allCategoryCardEntity) {
            return CardContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 予算エリア
                  if (allCategoryCardEntity.cardStatusType.hasBudget ||
                      allCategoryCardEntity.cardStatusType.hasExpense)
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
                                  MnothlyPlanGraph(
                                      maxGraphWidth: constraints.maxWidth,
                                      allCategoryCardEntity:
                                          allCategoryCardEntity),
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
                              // 残金
                              if (allCategoryCardEntity.realSavings != 0)
                                Flexible(
                                  child: RichText(
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text: '残金 ',
                                        style: AppTextStyles
                                            .appCardTertiaryTitleLabel,
                                      ),
                                      TextSpan(
                                        text: formattedPriceGetter(
                                            allCategoryCardEntity.realSavings),
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
                                  MonthlyIncomeGraph(
                                      maxGraphWidth: constraints.maxWidth,
                                      allCategoryCardEntity:
                                          allCategoryCardEntity),
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
