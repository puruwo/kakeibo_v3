import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthly_plan_area_parts/monthly_plan_graph_area/monthly_plan_graph_area.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthly_plan_area_parts/monthly_income_graph_area/monthly_income_graph_area.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_all_category_tile_entity_provider.dart';

class MonthlyPlanArea extends ConsumerWidget {
  const MonthlyPlanArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelAsync = ref.watch(resolvedAllCategoryCardModelProvider);

    return CardContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MnothlyPlanGraphArea(),
          const MonthlyIncomeGraphArea(),
          const SizedBox(height: AppSpacing.md),
          // 今月の収支行: realSavings != 0 のとき表示
          modelAsync.when(
            data: (model) {
              if (model.realSavings == 0) return const SizedBox.shrink();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(
                    thickness: 1,
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '今月の収支',
                          style: AppTextStyles.appCardTitleLabel,
                        ),
                        Text(
                          signedYenmarkFormattedPriceGetter(
                            model.realSavings,
                            showPlusSign: true,
                          ),
                          style: AppTextStyles.appCardPriceLabel,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, s) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
