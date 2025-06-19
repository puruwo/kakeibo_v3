import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/view/monthly_page/category_tile/big_category_expense_history_page/category_expence_history_list_area.dart';
import 'package:kakeibo/view/monthly_page/category_tile/big_category_expense_history_page/expanded_category_sum_tile.dart';

class CategoryExpenseHistoryPage extends ConsumerWidget {
  const CategoryExpenseHistoryPage({super.key, required this.bigId});
  final int bigId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Expense List'),
      ),
      body: Column(
        children: [
          ExpandedCategoryTile(bigId: bigId,),
          CategoryExpenceHistoryArea(bigId: bigId),
        ],
      ),
    );
  }
}
