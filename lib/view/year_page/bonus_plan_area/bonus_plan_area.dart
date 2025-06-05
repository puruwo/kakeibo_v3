import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_plan_bar_graph.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_bonus_plan_provider.dart';

class BonusPlanArea extends ConsumerWidget {
  const BonusPlanArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedBonusPlanValueProvider).when(
          data: (bonusPlanValue) {
            return Container(
              width: double.infinity,
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
                            'ボーナス',
                            style: MyFonts.planAreaLeftLabel,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                formattedPriceGetter(
                                    bonusPlanValue.yearlyBonusIncome),
                                style: MyFonts.planAreaRightLabel,
                              ),
                              Text(
                                ' 円',
                                style: MyFonts.planAreaYenLabel,
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
                          '利用額',
                          style: MyFonts.planAreaLeftLabel,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                                formattedPriceGetter(
                                    bonusPlanValue.yearlyBonusExpense),
                                style: MyFonts.planAreaRightLabel),
                            Text(
                              ' 円',
                              style: MyFonts.planAreaYenLabel,
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

                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12.0, 0, 4.0),
                      child: BonusPlanBarGraph(expense: bonusPlanValue.yearlyBonusExpense,budget: bonusPlanValue.yearlyBonusIncome,),
                    ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'ボーナス残額',
                          style: MyFonts.planAreaLeftLabel,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              formattedPriceGetter(
                                  bonusPlanValue.lastBonusPrice),
                              style: MyFonts.planAreaRightLabel,
                            ),
                            Text(
                              ' 円',
                              style: MyFonts.planAreaYenLabel,
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
