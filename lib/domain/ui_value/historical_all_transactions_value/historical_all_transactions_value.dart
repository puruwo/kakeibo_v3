import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_group_value.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/domain/ui_value/income_history_tile_value/income_history_tile_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_confirmed_fixed_cost_tile_value/monthly_confirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';

//Freezedで生成されるデータクラス
part 'historical_all_transactions_value.freezed.dart';

/// 履歴ページで使用する全トランザクションデータ
@freezed
class HistoricalAllTransactionsValue with _$HistoricalAllTransactionsValue {
  const factory HistoricalAllTransactionsValue({
    /// 通常支出（ボーナス除く）- 日付でグループ化済み
    required List<ExpenseHistoryTileGroupValue> expenses,

    /// ボーナス支出
    required List<ExpenseHistoryTileValue> bonusExpenses,

    /// 収入（月次収入）
    required List<IncomeHistoryTileValue> incomes,

    /// ボーナス収入
    required List<IncomeHistoryTileValue> bonusIncomes,

    /// 固定費（確定）
    required List<MonthlyConfirmedFixedCostTileValue> confirmedFixedCosts,

    /// 固定費（未確定）
    required List<MonthlyUnconfirmedFixedCostTileValue> unconfirmedFixedCosts,
  }) = _HistoricalAllTransactionsValue;
}
