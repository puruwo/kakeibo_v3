import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/view/budget_setting_page/budget_category_tile.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_monthly_budget_provider.dart';

class BudgetCategoryArea extends ConsumerWidget {
  const BudgetCategoryArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedBudgetEditValueProvider).when(data: (valueList) {
      return Expanded(
        child: ListView.builder(
          itemCount: valueList.length,
          itemBuilder: (BuildContext context, int i) {
            return BudgetCategoryTile(budgetEditValue: valueList[i]);
          },
        ),
      );
    }, error: (Object error, StackTrace stackTrace) {
      return const Text('エラーが発生しました');
    }, loading: () {
      return const CircularProgressIndicator();
    });
  }
}
