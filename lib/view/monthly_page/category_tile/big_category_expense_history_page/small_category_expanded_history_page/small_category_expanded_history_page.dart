import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/monthly_page/category_tile/big_category_expense_history_page/category_expence_history_list_area.dart';

class SmallCategoryExpenseHistoryPage extends ConsumerWidget {
  const SmallCategoryExpenseHistoryPage({super.key, required this.smallId});
  final int smallId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: context.colors.surfaceElevated,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: const GlassAppBarBackground(),
        title: Text(
          'カテゴリー別利用状況',
          style: AppTextStyles.pageHeaderText,
        ),
      ),
      body: Column(
        children: [
          CategoryExpenceHistoryArea(
            listAreaMode: ListAreaMode.smallCategory,
            smallId: smallId,
            // ListView内padding-topでAppBar分の余白を確保することで、
            // スクロール時にアイテムがAppBar背後を通り透過効果が機能する
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight,
            ),
          ),
        ],
      ),
    );
  }
}
