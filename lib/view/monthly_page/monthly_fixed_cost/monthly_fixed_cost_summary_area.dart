import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_category_summary_list.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_fixed_cost_value_provider.dart';

class MonthlyFixedCostSummaryArea extends ConsumerWidget {
  const MonthlyFixedCostSummaryArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedFixedCostSammaryValueProvider).when(
          data: (summaryValue) {
            return CardContainer(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 8.0),
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
                            style: AppTextStyles.cardPrimaryTitle,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                ///月の総支出
                                formattedPriceGetter(
                                    summaryValue.scheduledPaymentAmount),
                                style: AppTextStyles.cardPriceLabel,
                              ),
                              Text(
                                ' 円',
                                style: AppTextStyles.cardSecondaryTitle,
                              ),
                            ],
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
                              style: AppTextStyles.cardSecondaryTitle,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              formattedPriceGetter(summaryValue.fixedCostSum),
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.cardSecondaryTitle,
                              textAlign: TextAlign.end,
                            ),
                            Text(
                              ' 円',
                              style: AppTextStyles.cardSecondaryTitle,
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),

                        const SizedBox(width: 16),

                        // 予想分
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '予想分',
                              style: AppTextStyles.cardSecondaryTitle,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              summaryValue.unconfirmedFixedCostSum == 0
                                  ? '---'
                                  : formattedPriceGetter(
                                      summaryValue.unconfirmedFixedCostSum),
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.cardSecondaryTitle,
                              textAlign: TextAlign.end,
                            ),
                            Text(
                              ' 円',
                              style: AppTextStyles.cardSecondaryTitle,
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ],
                    ),

                    // カテゴリー別サマリー
                    const MonthlyFixedCostCategorySummaryList(),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        );
  }
}
