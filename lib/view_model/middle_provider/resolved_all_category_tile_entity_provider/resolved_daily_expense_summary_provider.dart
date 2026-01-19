import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/expense_history/historical_transaction_usecase.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/ui_value/daily_expense_summary_value/daily_expense_summary_value.dart';
import 'package:kakeibo/domain/ui_value/daily_transaction_group/daily_transaction_group.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/view/daily_expense_summary_page/parts/daily_expense_graph_area.dart';

/// 日次支出サマリーページ用の中間プロバイダー
/// 対象日のトランザクションデータを取得し、計算済みのValueを返す
final resolvedDailyExpenseSummaryProvider = FutureProvider.family
    .autoDispose<DailyExpenseSummaryValue, DateTime>((ref, date) async {
  // 対象月の期間を作成（月初〜月末）
  final periodValue = PeriodValue(
    startDatetime: DateTime(date.year, date.month, 1),
    endDatetime: DateTime(date.year, date.month + 1, 0),
  );

  // 月間のトランザクションデータを取得
  final transactions = await ref
      .watch(historicalTransactionNotifierProvider(periodValue).future);

  // 日付順にグループ化
  final dailyGroups = groupTransactionsByDate(transactions);

  // 対象日のグループを取得
  final dailyGroup = dailyGroups.firstWhere(
    (g) =>
        g.date.year == date.year &&
        g.date.month == date.month &&
        g.date.day == date.day,
    orElse: () => DailyTransactionGroup(date: date),
  );

  // 合計金額を計算
  final expenseTotal =
      dailyGroup.expenses.fold<int>(0, (sum, e) => sum + e.price);
  final confirmedFixedCostTotal =
      dailyGroup.confirmedFixedCosts.fold<int>(0, (sum, e) => sum + e.price);
  final unconfirmedFixedCostTotal = dailyGroup.unconfirmedFixedCosts
      .fold<int>(0, (sum, e) => sum + e.estimatedPrice);
  final totalExpense =
      expenseTotal + confirmedFixedCostTotal + unconfirmedFixedCostTotal;

  // すべて空の場合
  final hasNoData = dailyGroup.expenses.isEmpty &&
      dailyGroup.confirmedFixedCosts.isEmpty &&
      dailyGroup.unconfirmedFixedCosts.isEmpty;

  // 生活支出をカテゴリー別にグループ化
  final expensesByCategory = _groupExpensesByCategory(dailyGroup.expenses);

  // グラフ用カテゴリーサマリー
  final categorySummaries =
      DailyExpenseGraphArea.createCategorySummaries(dailyGroup.expenses);

  return DailyExpenseSummaryValue(
    date: date,
    expensesByCategory: expensesByCategory,
    confirmedFixedCosts: dailyGroup.confirmedFixedCosts,
    unconfirmedFixedCosts: dailyGroup.unconfirmedFixedCosts,
    expenseTotal: expenseTotal,
    confirmedFixedCostTotal: confirmedFixedCostTotal,
    unconfirmedFixedCostTotal: unconfirmedFixedCostTotal,
    totalExpense: totalExpense,
    hasNoData: hasNoData,
    categorySummaries: categorySummaries,
  );
});

/// 支出をカテゴリー別にグループ化
List<ExpenseCategoryGroup> _groupExpensesByCategory(
    List<ExpenseHistoryTileValue> expenses) {
  final Map<String, List<ExpenseHistoryTileValue>> grouped = {};

  for (final expense in expenses) {
    final key = expense.bigCategoryName;
    if (!grouped.containsKey(key)) {
      grouped[key] = [];
    }
    grouped[key]!.add(expense);
  }

  // ExpenseCategoryGroupのリストに変換
  final List<ExpenseCategoryGroup> result = [];
  for (final entry in grouped.entries) {
    final firstExpense = entry.value.first;
    final categoryTotal = entry.value.fold<int>(0, (sum, e) => sum + e.price);

    result.add(ExpenseCategoryGroup(
      categoryName: firstExpense.bigCategoryName,
      iconPath: firstExpense.iconPath,
      colorCode: firstExpense.colorCode,
      expenses: entry.value,
      categoryTotal: categoryTotal,
    ));
  }

  return result;
}
