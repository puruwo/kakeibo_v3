import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/application/expense_history/historical_transaction_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/constant/styles/history_list_styles.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/ui_value/daily_transaction_group/daily_transaction_group.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/daily_expense_summary_page/parts/daily_expense_graph_area.dart';

/// 日次支出サマリーページ（フルモーダル形式）
/// ツールチップからタップで遷移し、1日の支出詳細を表示
class DailyExpenseSummaryPage extends ConsumerWidget {
  const DailyExpenseSummaryPage({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 対象の月のPeriodValueを作成（月初から月末）
    final periodValue = PeriodValue(
      startDatetime: DateTime(date.year, date.month, 1),
      endDatetime: DateTime(date.year, date.month + 1, 0),
    );

    // 月間のトランザクションデータを取得
    final transactionsAsync =
        ref.watch(historicalTransactionNotifierProvider(periodValue));

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
      body: transactionsAsync.when(
        data: (transactions) {
          // 月間データからDailyTransactionGroupリストを生成
          final dailyGroups = groupTransactionsByDate(transactions);

          // 対象日のグループを取得
          final dailyGroup = dailyGroups.firstWhere(
            (g) =>
                g.date.year == date.year &&
                g.date.month == date.month &&
                g.date.day == date.day,
            orElse: () => DailyTransactionGroup(date: date),
          );

          return _buildContent(context, dailyGroup);
        },
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

  Widget _buildContent(BuildContext context, DailyTransactionGroup group) {
    final leftsidePadding = context.leftsidePadding;
    final screenHorizontalMagnification = context.screenHorizontalMagnification;

    // 合計金額を計算
    final expenseTotal =
        group.expenses.fold<int>(0, (sum, e) => sum + e.price) +
            group.bonusExpenses.fold<int>(0, (sum, e) => sum + e.price);
    final confirmedFixedCostTotal =
        group.confirmedFixedCosts.fold<int>(0, (sum, e) => sum + e.price);
    final unconfirmedFixedCostTotal = group.unconfirmedFixedCosts
        .fold<int>(0, (sum, e) => sum + e.estimatedPrice);
    final totalExpense =
        expenseTotal + confirmedFixedCostTotal + unconfirmedFixedCostTotal;

    // すべて空の場合
    final hasNoData = group.expenses.isEmpty &&
        group.bonusExpenses.isEmpty &&
        group.confirmedFixedCosts.isEmpty &&
        group.unconfirmedFixedCosts.isEmpty;

    // 生活支出をカテゴリー別にグループ化
    final allExpenses = [...group.expenses, ...group.bonusExpenses];
    final expensesByCategory = _groupExpensesByCategory(allExpenses);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            if (hasNoData)
              _buildEmptyState()
            else ...[
              // グラフエリア（総支出とカテゴリー別）
              DailyExpenseGraphArea(
                totalExpense: totalExpense,
                categorySummaries:
                    DailyExpenseGraphArea.createCategorySummaries(allExpenses),
              ),
              const SizedBox(height: 24),

              // 生活支出セクション
              if (allExpenses.isNotEmpty) ...[
                // カテゴリー別グループ
                ...expensesByCategory.entries.map((entry) {
                  return _buildCategoryGroup(
                    context,
                    entry.key,
                    entry.value,
                    leftsidePadding,
                    screenHorizontalMagnification,
                  );
                }),
              ],

              // 固定費（確定）セクション
              if (group.confirmedFixedCosts.isNotEmpty) ...[
                _buildTotalCard('固定費合計', confirmedFixedCostTotal),
                const SizedBox(height: 16),
                ...group.confirmedFixedCosts.map((fixedCost) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildFixedCostItem(
                      fixedCost.name,
                      fixedCost.resourcePath,
                      fixedCost.colorCode,
                      fixedCost.price,
                      '固定費',
                      leftsidePadding,
                    ),
                  );
                }),
              ],

              // 固定費（未確定）セクション
              if (group.unconfirmedFixedCosts.isNotEmpty) ...[
                _buildTotalCard('固定費(未確定)合計', unconfirmedFixedCostTotal),
                const SizedBox(height: 16),
                ...group.unconfirmedFixedCosts.map((fixedCost) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildFixedCostItem(
                      fixedCost.name,
                      fixedCost.resourcePath,
                      fixedCost.colorCode,
                      fixedCost.estimatedPrice,
                      '固定費(未確定)',
                      leftsidePadding,
                      isUnconfirmed: true,
                    ),
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

  /// 支出をカテゴリー別にグループ化
  Map<_CategoryInfo, List<ExpenseHistoryTileValue>> _groupExpensesByCategory(
      List<ExpenseHistoryTileValue> expenses) {
    final Map<String, List<ExpenseHistoryTileValue>> grouped = {};

    for (final expense in expenses) {
      final key = expense.bigCategoryName;
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(expense);
    }

    // _CategoryInfoをキーにしたMapに変換
    final Map<_CategoryInfo, List<ExpenseHistoryTileValue>> result = {};
    for (final entry in grouped.entries) {
      final firstExpense = entry.value.first;
      final categoryInfo = _CategoryInfo(
        name: firstExpense.bigCategoryName,
        iconPath: firstExpense.iconPath,
        colorCode: firstExpense.colorCode,
      );
      result[categoryInfo] = entry.value;
    }

    return result;
  }

  /// 合計カード
  Widget _buildTotalCard(String title, int total) {
    return CardContainer(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: HistoryListStyles.historyTileSubLabel.copyWith(fontSize: 15),
          ),
          Text(
            yenFormattedPriceGetter(total),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: MyColors.label,
            ),
          ),
        ],
      ),
    );
  }

  /// カテゴリーグループ
  Widget _buildCategoryGroup(
    BuildContext context,
    _CategoryInfo categoryInfo,
    List<ExpenseHistoryTileValue> expenses,
    double leftsidePadding,
    double screenHorizontalMagnification,
  ) {
    final categoryTotal = expenses.fold<int>(0, (sum, e) => sum + e.price);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // カテゴリーヘッダー（カテゴリー名 + 合計金額）
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // カテゴリー名
              Expanded(
                child: Text(
                  categoryInfo.name,
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
        ),

        // 個別アイテムリスト
        ...expenses.map((expense) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildExpenseItem(
              expense,
              leftsidePadding,
              screenHorizontalMagnification,
            ),
          );
        }),

        const SizedBox(height: 8),
      ],
    );
  }

  /// 支出アイテムカード
  Widget _buildExpenseItem(
    ExpenseHistoryTileValue expense,
    double leftsidePadding,
    double screenHorizontalMagnification,
  ) {
    final priceLabel =
        expense.price == 0 ? '未確定' : yenFormattedPriceGetter(expense.price);

    return CardContainer(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // カテゴリーアイコン
          SvgPicture.asset(
            expense.iconPath,
            colorFilter: ColorFilter.mode(
                MyColors().getColorFromHex(expense.colorCode), BlendMode.srcIn),
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 12),
          // 中央：大カテゴリー名とメモ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.bigCategoryName,
                  style: HistoryListStyles.historyTileBigCategoryLabel,
                ),
                if (expense.memo.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      expense.memo,
                      style: HistoryListStyles.historyTileSubLabel,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          // 右側：金額とマイナスアイコン
          Text(
            priceLabel,
            style: HistoryListStyles.historyTilePriceLabel,
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.remove,
            size: 18,
            color: MyColors.label,
          ),
        ],
      ),
    );
  }

  /// 固定費アイテムカード
  Widget _buildFixedCostItem(
    String name,
    String iconPath,
    String colorCode,
    int price,
    String subLabel,
    double leftsidePadding, {
    bool isUnconfirmed = false,
  }) {
    final priceLabel = price == 0 ? '未確定' : yenFormattedPriceGetter(price);
    final priceColor =
        isUnconfirmed && price == 0 ? MyColors.red : MyColors.pink;

    return CardContainer(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 左側：固定費名とサブラベル
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: HistoryListStyles.historyTileBigCategoryLabel,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subLabel,
                    style: HistoryListStyles.historyTileSubLabel,
                  ),
                ),
              ],
            ),
          ),
          // 右側：金額とマイナスアイコン
          Text(
            priceLabel,
            style: HistoryListStyles.historyTilePriceLabel.copyWith(
              color: priceColor,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.remove,
            size: 18,
            color: priceColor,
          ),
        ],
      ),
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

/// カテゴリー情報を保持するクラス
class _CategoryInfo {
  final String name;
  final String iconPath;
  final String colorCode;

  _CategoryInfo({
    required this.name,
    required this.iconPath,
    required this.colorCode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CategoryInfo &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}
