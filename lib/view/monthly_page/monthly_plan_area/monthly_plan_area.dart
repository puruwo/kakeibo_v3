import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_monthly_plan_provider.dart';

class MonthlyPlanArea extends ConsumerWidget {
  const MonthlyPlanArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedMonthlyPlanValueProvider).when(
          data: (monthlyPlanValue) {
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
                            '月の収入',
                            style: MyFonts.topCardTitleLabel,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                formattedPriceGetter(
                                    monthlyPlanValue.monthlyIncome),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '月の予算',
                          style: MyFonts.topCardTitleLabel,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              formattedPriceGetter(
                                  monthlyPlanValue.monthlyBudget),
                              style: MyFonts.topCardPriceLabel,
                            ),
                            Text(
                              ' 円',
                              style: MyFonts.topCardYenLabel,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 4.0,
                    ),
                    const Divider(
                      thickness: 1.0,
                      height: 4.0,
                      color: MyColors.separater,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '予想貯金',
                          style: MyFonts.topCardTitleLabel,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              formattedPriceGetter(
                                  monthlyPlanValue.expectedSavings),
                              style: MyFonts.topCardPriceLabel,
                            ),
                            Text(
                              ' 円',
                              style: MyFonts.topCardYenLabel,
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
          error: (error, stack) => Center(child: Text('$error')),
        );
  }
}
