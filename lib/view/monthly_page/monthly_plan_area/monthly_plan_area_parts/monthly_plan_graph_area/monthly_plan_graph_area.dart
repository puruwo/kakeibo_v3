import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthly_plan_area_parts/monthly_plan_graph_area/monthly_plan_graph_parts.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_all_category_tile_entity_provider.dart';

class MnothlyPlanGraphArea extends HookConsumerWidget {
  const MnothlyPlanGraphArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedAllCategoryCardModelProvider).when(
          data: (allCategoryCardEntity) {
            return allCategoryCardEntity.cardStatusType.hasExpense ||
                    allCategoryCardEntity.cardStatusType.hasBudget
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '総支出',
                              style: AppTextStyles.appCardTitleLabel,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            // カテゴリー総支出
                            RichText(
                                textAlign: TextAlign.end,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: formattedPriceGetter(
                                        allCategoryCardEntity
                                            .allCategoryTotalExpense),
                                    style: AppTextStyles
                                        .appCardOptionalSecondaryPriceLabel,
                                  ),
                                  TextSpan(
                                    text: ' 円',
                                    style: AppTextStyles
                                        .appCardOptionalSecondaryPriceUnit,
                                  ),
                                ])),

                            // 予算
                            allCategoryCardEntity.cardStatusType.hasBudget
                                ? Flexible(
                                    child: RichText(
                                        textAlign: TextAlign.end,
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(children: [
                                          TextSpan(
                                            text: ' /',
                                            style: AppTextStyles
                                                .appCardTertiaryTitleLabel,
                                          ),
                                          TextSpan(
                                            text: '予算 ',
                                            style: AppTextStyles
                                                .appCardTertiaryTitleLabel,
                                          ),
                                          // カテゴリー予算
                                          TextSpan(
                                            text: formattedPriceGetter(
                                                allCategoryCardEntity
                                                    .allCategoryTotalBudget),
                                            style: AppTextStyles
                                                .appCardTertiaryPriceLabel,
                                          ),
                                          TextSpan(
                                            text: ' 円',
                                            style: AppTextStyles
                                                .appCardTertiaryPriceUnit,
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
                            builder: (context, constraints) => MnothlyPlanGraph(
                                maxGraphWidth: constraints.maxWidth,
                                allCategoryCardEntity: allCategoryCardEntity),
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
