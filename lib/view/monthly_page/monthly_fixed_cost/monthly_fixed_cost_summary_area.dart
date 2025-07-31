import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_fixed_cost_value_provider.dart';

class MonthlyFixedCostSummaryArea extends ConsumerWidget {
  const MonthlyFixedCostSummaryArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedFixedCostSammaryValueProvider).when(
          data: (summaryValue) {
            return Container(
              decoration: BoxDecoration(
                color: MyColors.quarternarySystemfill,
                borderRadius: BorderRadius.circular(8.0),
              ),
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
                            '全体支出',
                            style: MyFonts.topCardTitleLabel,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                ///月の総支出
                                formattedPriceGetter(
                                    summaryValue.scheduledPaymentAmount),
                                style: MyFonts.topCardPriceLabel,
                              ),
                              Text(
                                ' 円',
                                style: MyFonts.topCardYenLabel,
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
                              style: MyFonts.topCardTirtiaryTitleLabel,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              formattedPriceGetter(summaryValue.fixedCostSum),
                              overflow: TextOverflow.ellipsis,
                              style: MyFonts.topCardTirtiaryPriceLabel,
                              textAlign: TextAlign.end,
                            ),
                            Text(
                              ' 円',
                              style: MyFonts.topCardTirtiaryYenLabel,
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),

                        // Spacer(),
                        const SizedBox(width: 16),

                        // 未確定分
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '未確定分',
                              style: MyFonts.topCardTirtiaryTitleLabel,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              summaryValue.unconfirmedFixedCostSum == 0
                                  ? '---'
                                  : formattedPriceGetter(
                                      summaryValue.unconfirmedFixedCostSum),
                              overflow: TextOverflow.ellipsis,
                              style: MyFonts.topCardTirtiaryPriceLabel,
                              textAlign: TextAlign.end,
                            ),
                            Text(
                              ' 円',
                              style: MyFonts.topCardTirtiaryYenLabel,
                              textAlign: TextAlign.end,
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        );
  }
}
