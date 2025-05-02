import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';

//Freezedで生成されるデータクラス
part 'expense_history_tile_group_value.freezed.dart';

// 支出データのエンティティ
@freezed
class ExpenseHistoryTileGroupValue with _$ExpenseHistoryTileGroupValue {
  const factory ExpenseHistoryTileGroupValue({
    required DateTime date,
    required List<ExpenseHistoryTileValue> expenseHistoryTileValueList,
  }) = _ExpenseHistoryTileGroupValue;

}
