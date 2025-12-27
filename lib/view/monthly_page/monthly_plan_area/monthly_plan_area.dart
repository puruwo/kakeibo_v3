import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthly_plan_area_parts/monthly_plan_graph_area/monthly_plan_graph_area.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthly_plan_area_parts/monthly_income_graph_area/monthly_income_graph_area.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthy_plan_home_page/monthly_plan_home_page.dart';

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
          const MnothlyPlanGraphArea(),
          const MonthlyIncomeGraphArea(),
          const SizedBox(
            height: 12,
          ),
          hasButtonArea == true
              ? Column(
                  children: [
                    const Divider(
                      thickness: 1,
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // 予算ボタン
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: PlanAreaButton(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MonthlyPlanHomePage(
                                            initialTab: 0),
                                  ),
                                );
                              },
                              icon: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: SvgPicture.asset(
                                  'assets/images/ui_icon_edit.svg',
                                  colorFilter: const ColorFilter.mode(
                                      MyColors.themeColor, BlendMode.srcIn),
                                  width: 15,
                                  height: 15,
                                ),
                              ),
                              label: '予算',
                            ),
                          ),
                          const SizedBox(width: 6),
                          // 収入ボタン
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: PlanAreaButton(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MonthlyPlanHomePage(
                                            initialTab: 1),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.add,
                                size: 18,
                                color: MyColors.themeColor,
                              ),
                              label: '収入',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Container(),
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
                style: const TextStyle(
                    color: MyColors.themeColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
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
