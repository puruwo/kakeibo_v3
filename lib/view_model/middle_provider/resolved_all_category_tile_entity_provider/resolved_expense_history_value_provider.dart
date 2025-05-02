import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/expense_history/expense_history_usecase.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_group_value.dart';
import 'package:kakeibo/view_model/state/date_scope/date_scope.dart';

final resolvedExpenseHistoryValueProvider =
    FutureProvider<List<ExpenseHistoryTileGroupValue>>((ref) async {
  
  // 選択された日付から集計期間を取得する
  final monthPeriodValue = await ref.watch(dateScopeEntityProvider.selectAsync((data) => data.monthPeriod));
  
  // 選択された集計期間を元に、Entityを取得する
  final result = ref.watch(expenseHistoryNotifierProvider(monthPeriodValue).future);
  return result;
});
