import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'expense_history_tile_value.freezed.dart';

// 支出データのエンティティ
@freezed
class ExpenseHistoryTileValue with _$ExpenseHistoryTileValue {
  const factory ExpenseHistoryTileValue({
    required int id,
    required DateTime date,
    required int price,
    required int paymentCategoryId,
    @Default('') String memo,
    required String smallCategoryName,
    required String bigCategoryName,
    required String colorCode,
    required String iconPath,
  }) = _ExpenseHistoryTileValue;

}
