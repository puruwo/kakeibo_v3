import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthly_plan_area_parts/monthly_plan_graph_area/monthly_plan_graph_area.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthly_plan_area_parts/monthly_income_graph_area/monthly_income_graph_area.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthy_plan_home_page/monthly_plan_home_page.dart';
import 'package:kakeibo/view/yearly_income_list_page/yearly_income_list_page.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_all_category_tile_entity_provider.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/analyze_page_date_scope.dart';

class MonthlyPlanArea extends ConsumerWidget {
  const MonthlyPlanArea({Key? key, this.hasButtonArea = true})
      : super(key: key);

  final bool hasButtonArea;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CardContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MnothlyPlanGraphArea(
            trailing: hasButtonArea
                ? PlanAreaButton(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MonthlyPlanHomePage(),
                        ),
                      );
                    },
                    icon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: SvgPicture.asset(
                        'assets/images/ui_icon_edit.svg',
                        colorFilter: const ColorFilter.mode(
                            MyColors.themeColor, BlendMode.srcIn),
                        width: 15,
                        height: 15,
                      ),
                    ),
                    label: '予算',
                  )
                : null,
          ),
          MonthlyIncomeGraphArea(
            trailing: hasButtonArea
                ? PlanAreaButton(
                    onTap: () {
                      final dateScope =
                          ref.read(analyzePageDateScopeEntityProvider).value;
                      if (dateScope == null) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => YearlyIncomeListPage(
                              period: dateScope.aggregationMonthPeriod),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add,
                      size: 18,
                      color: MyColors.themeColor,
                    ),
                    label: '収入',
                  )
                : null,
          ),
          hasButtonArea == true
              ? ref.watch(resolvedAllCategoryCardModelProvider).when(
                    data: (allCategoryCardEntity) {
                      return allCategoryCardEntity.realSavings != 0
                          ? Column(
                              children: [
                                const SizedBox(height: 12),
                                const Divider(
                                  thickness: 1,
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 10, 16, 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.end,
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(children: [
                                          TextSpan(
                                            text: '残金 ',
                                            style: AppTextStyles
                                                .appCardTertiaryTitleLabel,
                                          ),
                                          TextSpan(
                                            text: formattedPriceGetter(
                                                allCategoryCardEntity
                                                    .realSavings),
                                            style: AppTextStyles
                                                .appCardTertiaryPriceLabel,
                                          ),
                                          TextSpan(
                                            text: ' 円',
                                            style: AppTextStyles
                                                .appCardTertiaryPriceUnit,
                                          ),
                                        ]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox(height: 12);
                    },
                    loading: () => const SizedBox(height: 12),
                    error: (_, __) => const SizedBox(height: 12),
                  )
              : const SizedBox(height: 12),
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
  });

  final void Function() onTap;
  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppInkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 37,
        width: 95,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: MyColors.tirtiarySystemfill,
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
                style: MonthlyPageStyles.planAreaButtonLabel,
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
