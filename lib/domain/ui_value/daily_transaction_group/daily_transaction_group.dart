import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/domain/ui_value/income_history_tile_value/income_history_tile_value.dart';

part 'daily_transaction_group.freezed.dart';

@freezed
class DailyTransactionGroup with _$DailyTransactionGroup {
  const factory DailyTransactionGroup({
    required DateTime date,
    /// 支出（固定費行も含む。固定費かどうかは fixedCostId で判定する）
    @Default([]) List<ExpenseHistoryTileValue> expenses,
    @Default([]) List<ExpenseHistoryTileValue> bonusExpenses,
    @Default([]) List<IncomeHistoryTileValue> incomes,
    @Default([]) List<IncomeHistoryTileValue> bonusIncomes,
  }) = _DailyTransactionGroup;
}
