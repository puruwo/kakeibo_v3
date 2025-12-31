import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view/monthly_page/category_tile/big_category_expense_history_page/category_expence_history_list_area.dart';
import 'package:kakeibo/view/monthly_page/category_tile/big_category_expense_history_page/expanded_category_sum_tile.dart';

class CategoryExpenseHistoryPage extends ConsumerWidget {
  const CategoryExpenseHistoryPage({super.key, required this.bigId});
  final int bigId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'カテゴリー別利用状況',
          style: AppTextStyles.pageHeaderText,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ExpandedCategoryTile(
              bigId: bigId,
            ),
          ),
          CategoryExpenceHistoryArea(
              listAreaMode: ListAreaMode.bigCategory, bigId: bigId),
        ],
      ),
    );
  }
}
