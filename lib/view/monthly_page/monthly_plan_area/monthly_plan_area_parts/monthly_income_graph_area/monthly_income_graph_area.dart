import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthly_plan_area_parts/monthly_income_graph_area/monthly_income_graph_parts.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_all_category_tile_entity_provider.dart';

class MonthlyIncomeGraphArea extends HookConsumerWidget {
  const MonthlyIncomeGraphArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedAllCategoryCardModelProvider).when(
          data: (allCategoryCardEntity) {
            return allCategoryCardEntity.cardStatusType.hasIncome
                ? Padding(
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
                                const SizedBox(
                                  width: 8,
                                ),
                                // 総収入
                                Text(
                                  yenmarkFormattedPriceGetter(
                                      allCategoryCardEntity
                                          .allCategoryTotalIncome),
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles
                                      .appCardOptionalSecondaryPriceLabel,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
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
                  )
                : Container();
          },
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => Center(child: Text('$error')),
        );
  }
}
