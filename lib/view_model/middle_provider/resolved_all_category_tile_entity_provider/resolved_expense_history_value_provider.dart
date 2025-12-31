import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/expense_history/big_category_expense_history_usecase/big_category_expense_history_usecase.dart';
import 'package:kakeibo/application/expense_history/big_category_expense_history_usecase/request_big_expense_history.dart';
import 'package:kakeibo/application/expense_history/historical_transaction_usecase.dart';
import 'package:kakeibo/application/expense_history/small_category_expense_history_usecase/request_small_expense_history.dart';
import 'package:kakeibo/application/expense_history/small_category_expense_history_usecase/small_category_expense_history_usecase.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/ui_value/daily_transaction_group/daily_transaction_group.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_group_value.dart';
import 'package:kakeibo/util/extension/datetime_extension.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/analyze_page_date_scope.dart';
import 'package:kakeibo/view_model/state/date_scope/historical_page/historical_date_scope.dart';

// historical系のページで利用する
// 全トランザクションデータ（支出、ボーナス支出、収入、固定費確定/未確定）を取得
final resolvedExpenseHistoryValueProvider =
    FutureProvider<List<DailyTransactionGroup>>((ref) async {
  // 選択された日付から月単位期間を取得する（1日〜月末）
  final dateScope = await ref
      .watch(historicalDateScopeEntityProvider.selectAsync((data) => data));

  // 選択された月単位期間を元に、全トランザクションデータを取得する
  PeriodValue periodValue = dateScope.selectedDate.getMonthPeriod();
  final result = await ref
      .watch(historicalTransactionNotifierProvider(periodValue).future);

  // 日付順にグループ分けして返す
  return groupTransactionsByDate(result);
});

// monthly系のページで利用する
final resolvedCategoryExpenseHistoryDigestValueProvider =
    FutureProvider.family<List<ExpenseHistoryTileGroupValue>, int>(
        (ref, bigId) async {
  // 選択された日付から集計期間を取得する
  final monthPeriodValue = await ref.watch(analyzePageDateScopeEntityProvider
      .selectAsync((data) => data.monthPeriod));

  final request = RequestBigExpenseHistory(
    bigId: bigId,
    monthPeriodValue: monthPeriodValue,
  );

  // 選択された集計期間を元に、Entityを取得する
  final result =
      ref.watch(bigCategoryExpenseHistoryNotifierProvider(request).future);
  return result;
});

final resolvedSmallCategoryExpenseHistoryDigestValueProvider =
    FutureProvider.family<List<ExpenseHistoryTileGroupValue>, int>(
        (ref, smallId) async {
  // 選択された日付から集計期間を取得する
  final monthPeriodValue = await ref.watch(analyzePageDateScopeEntityProvider
      .selectAsync((data) => data.monthPeriod));

  final request = RequestSmallExpenseHistory(
    smallId: smallId,
    monthPeriodValue: monthPeriodValue,
  );

  // 選択された集計期間を元に、Entityを取得する
  final result =
      ref.watch(smallCategoryExpenseHistoryNotifierProvider(request).future);
  return result;
});
