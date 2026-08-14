import 'package:flutter/material.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_plan_bar_graph.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_bonus_plan_provider.dart';

class BonusPlanArea extends ConsumerWidget {
  const BonusPlanArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedBonusPlanValueProvider).when(
          data: (bonusPlanValue) {
            return CardContainer(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
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
                            style: AppTextStyles.appCardTitleLabel,
                          ),
                          Text(
                            yenmarkFormattedPriceGetter(
                                bonusPlanValue.yearlyBonusIncome),
                            style: AppTextStyles.appCardPriceLabel,
                          ),
                        ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '利用額',
                          style: AppTextStyles.appCardTitleLabel,
                        ),
                        Text(
                          yenmarkFormattedPriceGetter(
                              bonusPlanValue.yearlyBonusExpense),
                          style: AppTextStyles.appCardPriceLabel,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 4.0,
                    ),
                    Divider(
                      thickness: 1.0,
                      height: 4.0,
                      color: context.colors.separator,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        0,
                        AppSpacing.md,
                        0,
                        AppSpacing.xs,
                      ),
                      child: BonusPlanBarGraph(
                        expense: bonusPlanValue.yearlyBonusExpense,
                        budget: bonusPlanValue.yearlyBonusIncome,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'ボーナス残額',
                          style: AppTextStyles.appCardTitleLabel,
                        ),
                        Text(
                          yenmarkFormattedPriceGetter(
                              bonusPlanValue.lastBonusPrice),
                          style: AppTextStyles.appCardPriceLabel,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          // ローディングはトップレベル(PageLoadingIndicator)で吸収する
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => const AppErrorState(),
        );
  }
}
