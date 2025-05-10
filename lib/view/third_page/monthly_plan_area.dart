import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/ui_value/monthly_plan_value/monthly_plan_value.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_monthly_plan_provider.dart';

class MonthlyPlanArea extends ConsumerWidget {
  const MonthlyPlanArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedMonthlyPlanValueProvider).when(
          data: (monthlyPlanValue) {
            return MonthlyPlanCard(allCategoryTileEntity: monthlyPlanValue);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('$error')),
        );
  }

  Widget MonthlyPlanCard({required MonthlyPlanValue allCategoryTileEntity}) {
    return Container(
      child: Row(
        children: [
          Text(allCategoryTileEntity.monthlyIncome.toString()),
          Text(allCategoryTileEntity.monthlyBudget.toString()),
          Text(allCategoryTileEntity.expectedSavings.toString()),
        ],
      ),
    );
  }
}
