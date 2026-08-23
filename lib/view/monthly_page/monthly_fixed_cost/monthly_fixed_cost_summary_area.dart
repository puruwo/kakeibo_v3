import 'package:flutter/material.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_big_category_summary_list.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_fixed_cost_value_provider.dart';

class MonthlyFixedCostSummaryArea extends ConsumerWidget {
  const MonthlyFixedCostSummaryArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedFixedCostSammaryValueProvider).when(
          data: (summaryValue) {
            return CardContainer(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '支払い予定',
                            style: AppTextStyles.appCardTitleLabel,
                          ),
                          Text(
                            yenmarkFormattedPriceGetter(
                                summaryValue.scheduledPaymentAmount),
                            style: AppTextStyles.appCardPriceLabel,
                          ),
                        ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        // 確定分
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '確定分',
                              style: AppTextStyles.appCardTertiaryTitleLabel,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              yenmarkFormattedPriceGetter(summaryValue.fixedCostSum),
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.appCardTertiaryPriceLabel,
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),

                        const SizedBox(width: AppSpacing.lg),

                        // 予想分
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '予想分',
                              style: AppTextStyles.appCardTertiaryTitleLabel,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              summaryValue.unconfirmedFixedCostSum == 0
                                  ? '---'
                                  : yenmarkFormattedPriceGetter(
                                      summaryValue.unconfirmedFixedCostSum),
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.appCardTertiaryPriceLabel,
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ],
                    ),

                    // カテゴリー別サマリー
                    const MonthlyFixedCostBigCategorySummaryList(),
                  ],
                ),
              ),
            );
          },
          // ローディングはトップレベル(MonthlyPageFullSkeleton)で吸収する
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => const AppErrorState(),
        );
  }
}
