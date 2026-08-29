import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'income_history_tile_value.freezed.dart';

// 支出データのエンティティ
@freezed
class IncomeHistoryTileValue with _$IncomeHistoryTileValue {
  const factory IncomeHistoryTileValue({
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
  }) = _IncomeHistoryTileValue;

}
