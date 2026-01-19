import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/constant/styles/history_list_styles.dart';
import 'package:kakeibo/domain/ui_value/daily_expense_summary_value/daily_expense_summary_value.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/daily_expense_summary_page/parts/daily_expense_graph_area.dart';
import 'package:kakeibo/view/daily_expense_summary_page/parts/daily_expense_item_tile.dart';
import 'package:kakeibo/view/daily_expense_summary_page/parts/daily_fixed_cost_item_tile.dart';
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
      backgroundColor: MyColors.secondarySystemBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
        error: (error, stack) => Center(
          child: Text(
            'データの取得に失敗しました',
            style: HistoryListStyles.historyEmptyMessage,
          ),
        ),
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
            const SizedBox(height: 16),
            if (summary.hasNoData)
              _buildEmptyState()
            else ...[
              // グラフエリア（総支出とカテゴリー別）
              DailyExpenseGraphArea(
                totalExpense: summary.totalExpense,
                categorySummaries: summary.categorySummaries,
              ),
              const SizedBox(height: 24),

              // 生活支出セクション（カテゴリー別グループ）
              if (summary.expensesByCategory.isNotEmpty) ...[
                ...summary.expensesByCategory.map((categoryGroup) {
                  return _buildCategoryGroup(categoryGroup);
                }),
              ],

              // 固定費（確定）セクション
              if (summary.confirmedFixedCosts.isNotEmpty) ...[
                DailyExpenseSummaryHeader(
                  categoryName: '固定費合計',
                  categoryTotal: summary.confirmedFixedCostTotal,
                ),
                ...summary.confirmedFixedCosts.map((fixedCost) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: DailyConfirmedFixedCostItemTile(value: fixedCost),
                  );
                }),
              ],

              // 固定費（未確定）セクション
              if (summary.unconfirmedFixedCosts.isNotEmpty) ...[
                DailyExpenseSummaryHeader(
                  categoryName: '固定費(未確定)合計',
                  categoryTotal: summary.unconfirmedFixedCostTotal,
                ),
                ...summary.unconfirmedFixedCosts.map((fixedCost) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: DailyUnconfirmedFixedCostItemTile(value: fixedCost),
                  );
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
        child: Text(
          'この日の支出はありません',
          style: HistoryListStyles.historyEmptyMessage,
        ),
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
              style: HistoryListStyles.historyTileBigCategoryLabel,
            ),
          ),
          // カテゴリー合計金額
          Text(
            '${formattedPriceGetter(categoryTotal)}円',
            style: HistoryListStyles.historyTileSubLabel.copyWith(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
