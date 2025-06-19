import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/expense_history/category_expense_history_usecase.dart';
import 'package:kakeibo/application/expense_history/expense_history_digest_usecase.dart';
import 'package:kakeibo/application/expense_history/expense_history_usecase.dart';
import 'package:kakeibo/application/expense_history/request_expense_history.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_group_value.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/view_model/state/date_scope/date_scope.dart';

final resolvedExpenseHistoryValueProvider =
    FutureProvider<List<ExpenseHistoryTileGroupValue>>((ref) async {
  
  // 選択された日付から集計期間を取得する
  final monthPeriodValue = await ref.watch(dateScopeEntityProvider.selectAsync((data) => data.monthPeriod));
  
  // 選択された集計期間を元に、Entityを取得する
  final result = ref.watch(expenseHistoryGroupByDateNotifierProvider(monthPeriodValue).future);
  return result;
});

final resolvedExpenseHistoryDigestValueProvider =
    FutureProvider<List<ExpenseHistoryTileValue>>((ref) async {
  
  // 選択された日付から集計期間を取得する
  final monthPeriodValue = await ref.watch(dateScopeEntityProvider.selectAsync((data) => data.monthPeriod));
  
  // 選択された集計期間を元に、Entityを取得する
  final result = ref.watch(expenseHistoryDigestNotifierProvider(monthPeriodValue).future);
  return result;
});

final resolvedCategoryExpenseHistoryDigestValueProvider =
    FutureProvider.family<List<ExpenseHistoryTileGroupValue>,int>((ref,bigId) async {
  
  // 選択された日付から集計期間を取得する
  final monthPeriodValue = await ref.watch(dateScopeEntityProvider.selectAsync((data) => data.monthPeriod));

  final request = RequestExpenseHistory(
    bigId: bigId,
    monthPeriodValue: monthPeriodValue,
  );
  
  // 選択された集計期間を元に、Entityを取得する
  final result = ref.watch(categoryExpenseHistoryNotifierProvider(request).future);
  return result;
});