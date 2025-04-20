import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/service/expense_history/expense_history_usecase.dart';
import 'package:kakeibo/domain/expense_history_tile_value/expense_history_tile_group_value.dart';
import 'package:kakeibo/view_model/provider/selected_calendar_period/selected_calendar_period.dart';
import 'package:kakeibo/view_model/provider/selected_datetime/selected_datetime.dart';

final resolvedExpenseHistoryValueProvider =
    FutureProvider<List<ExpenseHistoryTileGroupValue>>((ref) async {

  // 選択された日付を取得する
  final selectedDate = ref.watch(selectedDatetimeNotifierProvider);
  
  // 選択された日付から集計期間を取得する
  final monthPeriodValue = await ref.watch(selectedCalendarPeriodProvider(selectedDate).future);
  
  // 選択された集計期間を元に、Entityを取得する
  final result = ref.watch(expenseHistoryNotifierProvider(monthPeriodValue).future);
  return result;
});
