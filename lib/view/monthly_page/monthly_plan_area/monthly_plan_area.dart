import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/button_util.dart';
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
          const SizedBox(height: 12),
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
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '今月の収支',
                          style: AppTextStyles.appCardTitleLabel,
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: model.realSavings > 0
                                    ? '+${formattedPriceGetter(model.realSavings)}'
                                    : formattedPriceGetter(model.realSavings),
                                style: AppTextStyles.appCardPriceLabel,
                              ),
                              TextSpan(
                                text: ' 円',
                                style: AppTextStyles.appCardPriceUnit,
                              ),
                            ],
                          ),
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

class PlanAreaButton extends StatelessWidget {
  const PlanAreaButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.label,
    this.colorType = ButtonColorType.secondary,
  });

  final void Function() onTap;
  final Widget icon;
  final String label;
  final ButtonColorType colorType;

  @override
  Widget build(BuildContext context) {
    return AppInkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorType.color,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 6),
              Text(
                label,
                style: colorType == ButtonColorType.main
                    ? AppTextStyles.whiteButtonText
                    : AppTextStyles.subButtonText,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: true,
                  applyHeightToLastDescent: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
