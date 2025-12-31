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
                                  style: MonthlyPageStyles.topCardTitleLabel,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                // 総収入
                                RichText(
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text: formattedPriceGetter(
                                            allCategoryCardEntity
                                                .allCategoryTotalIncome),
                                        style: MonthlyPageStyles
                                            .categoryTilePriceLabel,
                                      ),
                                      TextSpan(
                                        text: ' 円',
                                        style: MonthlyPageStyles
                                            .categoryTileYenLabel,
                                      ),
                                    ])),
                              ],
                            ),
                            // 残金
                            allCategoryCardEntity.realSavings != 0
                                ? Flexible(
                                    child: RichText(
                                        textAlign: TextAlign.end,
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(children: [
                                          TextSpan(
                                            text: '残金 ',
                                            style: MonthlyPageStyles
                                                .categoryTileBudgetTextLabel,
                                          ),
                                          // カテゴリー予算
                                          TextSpan(
                                            text: formattedPriceGetter(
                                                allCategoryCardEntity
                                                    .realSavings),
                                            style: MonthlyPageStyles
                                                .categoryTileBudgetPriceLabel,
                                          ),
                                          TextSpan(
                                            text: ' 円',
                                            style: MonthlyPageStyles
                                                .categoryTileBudgetYenLabel,
                                          ),
                                        ])),
                                  )
                                : Container(),
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('$error')),
        );
  }
}
