import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/domain/ui_value/daily_expense_summary_value/daily_expense_summary_value.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/daily_expense_summary_page/parts/daily_expense_graph_area.dart';
import 'package:kakeibo/view/daily_expense_summary_page/parts/daily_expense_item_tile.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_daily_expense_summary_provider.dart';

/// 日次支出サマリーページ（フルモーダル形式）
/// ツールチップからタップで遷移し、1日の支出詳細を表示
class DailyExpenseSummaryPage extends ConsumerWidget {
  const DailyExpenseSummaryPage({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 中間プロバイダーからデータを取得
    final summaryAsync = ref.watch(resolvedDailyExpenseSummaryProvider(date));

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: context.colors.surfaceElevated,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: const GlassAppBarBackground(),
        leading: IconButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          icon: const Icon(Icons.close),
        ),
        title: Text(
          '${date.month}月${date.day}日の支出',
          style: AppTextStyles.pageHeaderText,
        ),
        centerTitle: true,
      ),
      body: summaryAsync.when(
        data: (summary) => _buildContent(context, summary),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            const AppErrorState(message: 'データの取得に失敗しました'),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DailyExpenseSummaryValue summary) {
    final leftsidePadding = context.leftsidePadding;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppBarのぶんだけスペースをあける
            SizedBox(
              height: MediaQuery.of(context).padding.top + kToolbarHeight,
            ),
            const SizedBox(height: 16),
            if (summary.hasNoData)
              _buildEmptyState()
            else ...[
              // グラフエリア（総支出とカテゴリー別）
              DailyExpenseGraphArea(
                totalExpense: summary.totalExpense,
                categorySummaries: summary.categorySummaries,
                variableExpenseTotal: summary.variableExpenseTotal,
                fixedCostTotal: summary.fixedCostTotal,
                unconfirmedFixedCostTotal: summary.unconfirmedFixedCostTotal,
              ),
              const SizedBox(height: 24),

              // 支出セクション（カテゴリー別グループ。固定費行も同じ一覧に並ぶ）
              if (summary.expensesByCategory.isNotEmpty) ...[
                ...summary.expensesByCategory.map((categoryGroup) {
                  return _buildCategoryGroup(categoryGroup);
                }),
              ],
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// カテゴリーグループ
  Widget _buildCategoryGroup(ExpenseCategoryGroup categoryGroup) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // カテゴリーヘッダー（カテゴリー名 + 合計金額）
        DailyExpenseSummaryHeader(
          categoryName: categoryGroup.categoryName,
          categoryTotal: categoryGroup.categoryTotal,
        ),

        // 個別アイテムリスト
        ...categoryGroup.expenses.map((expense) {
          return DailyExpenseItemTile(value: expense);
        }),

        const SizedBox(height: 8),
      ],
    );
  }

  /// データなしの状態
  Widget _buildEmptyState() {
    return CardContainer(
      width: double.infinity,
      height: 120,
      child: Center(
        child: Text('この日の支出はありません', style: AppTextStyles.listEmptyMessage),
      ),
    );
  }
}

class DailyExpenseSummaryHeader extends StatelessWidget {
  const DailyExpenseSummaryHeader({
    super.key,
    required this.categoryName,
    required this.categoryTotal,
  });

  final String categoryName;
  final int categoryTotal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // カテゴリー名
          Expanded(
            child: Text(
              categoryName,
              style: AppTextStyles.listTilePrimaryTitle,
            ),
          ),
          // カテゴリー合計金額
          Text(
            yenmarkFormattedPriceGetter(categoryTotal),
            style: AppTextStyles.listTileTirtiaryTitle.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
