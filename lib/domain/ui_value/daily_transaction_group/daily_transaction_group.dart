import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/domain/ui_value/income_history_tile_value/income_history_tile_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_confirmed_fixed_cost_tile_value/monthly_confirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';

part 'daily_transaction_group.freezed.dart';

@freezed
class DailyTransactionGroup with _$DailyTransactionGroup {
  const factory DailyTransactionGroup({
    required DateTime date,
    @Default([]) List<ExpenseHistoryTileValue> expenses,
    @Default([]) List<ExpenseHistoryTileValue> bonusExpenses,
    @Default([]) List<IncomeHistoryTileValue> incomes,
    @Default([]) List<IncomeHistoryTileValue> bonusIncomes,
    @Default([]) List<MonthlyConfirmedFixedCostTileValue> confirmedFixedCosts,
    @Default([])
    List<MonthlyUnconfirmedFixedCostTileValue> unconfirmedFixedCosts,
  }) = _DailyTransactionGroup;
}
