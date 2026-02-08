import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/monthly_page/skeleton/monthly_plan_skeleton.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_all_category_tile_entity_provider.dart';

/// 予算ページ上部のサマリーエリア
/// 予算合計と収入合計のみを表示する（支出情報は含まない）
class BudgetPageSummaryArea extends ConsumerWidget {
  const BudgetPageSummaryArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedAllCategoryCardModelProvider).when(
          data: (allCategoryCardEntity) {
            return CardContainer(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 予算
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '予算',
                          style: AppTextStyles.appCardTitleLabel,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              formattedPriceGetter(
                                  allCategoryCardEntity.allCategoryTotalBudget),
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
                    const SizedBox(height: 8),
                    const Divider(height: 1, thickness: 1),
                    const SizedBox(height: 8),
                    // 収入
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '収入',
                          style: AppTextStyles.appCardTitleLabel,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              formattedPriceGetter(
                                  allCategoryCardEntity.allCategoryTotalIncome),
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
                  ],
                ),
              ),
            );
          },
          loading: () => const MonthlyPlanSkeleton(),
          error: (error, stack) => Center(child: Text('$error')),
        );
  }
}
