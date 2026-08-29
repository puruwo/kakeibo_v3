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
    // 大カテゴリー単位の集計・絞り込みはIDで行う（同名カテゴリーを合算しない）
    required int bigCategoryId,
    required String bigCategoryName,
    required String colorCode,
    required String iconPath,
    required int incomeSourceBigCategory,
    // 固定費マスタへの参照。NULL＝通常支出（v10で追加）
    // 明細行に「固定費」チップを出すかの判定に使う（仕様 §7.2）
    int? fixedCostId,
    // 0=未確定 / 1=確定。通常支出は常に1（v10で追加）
    @Default(1) int isConfirmed,
  }) = _ExpenseHistoryTileValue;

}
