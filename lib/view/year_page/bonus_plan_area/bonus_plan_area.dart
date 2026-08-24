import 'package:flutter/material.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_plan_bar_graph.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_bonus_plan_provider.dart';

/// トップ画面用の特別枠サマリーカード（案件 UIデザイン改修 §4）
///
/// 役割は「残額のglanceable」。残額を主役（20/w700）に置き、
/// バーと「利用／収入」の1行だけを添える。
/// 詳細（3分割の内訳）は特別枠ページ側の BonusPlanDetailSummary が担う。
class BonusPlanArea extends ConsumerWidget {
  const BonusPlanArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(resolvedBonusPlanValueProvider)
        .when(
          data: (bonusPlanValue) {
            return CardContainer(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 残額（主役）
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('残額', style: AppTextStyles.appCardTitleLabel),
                      Text(
                        yenmarkFormattedPriceGetter(
                          bonusPlanValue.lastBonusPrice,
                        ),
                        style: AppTextStyles.appCardPriceLabel,
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      AppSpacing.md,
                      0,
                      AppSpacing.sm,
                    ),
                    child: BonusPlanBarGraph(
                      expense: bonusPlanValue.yearlyBonusExpense,
                      budget: bonusPlanValue.yearlyBonusIncome,
                    ),
                  ),

                  // 利用／収入の補足1行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '利用 ${yenmarkFormattedPriceGetter(bonusPlanValue.yearlyBonusExpense)}',
                        style: AppTextStyles.budgetFixedCostForecastLabel,
                      ),
                      Text(
                        '収入 ${yenmarkFormattedPriceGetter(bonusPlanValue.yearlyBonusIncome)}',
                        style: AppTextStyles.budgetFixedCostForecastLabel,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          // ローディングはトップレベル(PageLoadingIndicator)で吸収する
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => const AppErrorState(),
        );
  }
}
