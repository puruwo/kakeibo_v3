import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'income_small_category_entity.freezed.dart';
//jsonを変換する処理が生成されるクラス
part 'income_small_category_entity.g.dart';

@freezed
class IncomeSmallCategoryEntity with _$IncomeSmallCategoryEntity {
  const IncomeSmallCategoryEntity._();

  const factory IncomeSmallCategoryEntity({
    required int id,
    required int smallCategoryOrderKey,
    required int bigCategoryKey,
    required int displayedOrderInBig,
    required String smallCategoryName,
    required int defaultDisplayed,
    // 論理削除（0=有効 / 1=削除済み）。v14で追加（KP-024）
    @Default(0) int deleteFlag,
  }) = _IncomeSmallCategoryEntity;

  @override
  factory IncomeSmallCategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$IncomeSmallCategoryEntityFromJson(json);
}
