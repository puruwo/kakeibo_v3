import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthly_plan_area_parts/monthly_plan_data_area.dart';

import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthly_plan_area_parts/monthly_plan_graph_area/monthly_plan_graph_area.dart';

class MonthlyPlanArea extends ConsumerWidget {
  const MonthlyPlanArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: MyColors.quarternarySystemfill,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [MnothlyPlanGraphArea(), MonthlyPlanDataArea()],
      ),
    );
  }
}
