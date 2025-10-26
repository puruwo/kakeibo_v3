import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/core/category_entity/i_category_entity.dart';

//Freezedで生成されるデータクラス
part 'fixed_cost_category_entity.freezed.dart';

//jsonを変換する処理が生成されるクラス
part 'fixed_cost_category_entity.g.dart';

// 固定費カテゴリーのエンティティ
@freezed
class FixedCostCategoryEntity with _$FixedCostCategoryEntity implements ICategoryEntity{
  const factory FixedCostCategoryEntity({
    @Default(0) int id,
    required String categoryName,
    required String colorCode,
    required String resourcePath,
    @Default(0) int displayOrder,
    @Default(1) int isDisplayed,
    // 表示用のソートキー
    @Default(0) int sortKey,
  }) = _FixedCostCategoryEntity;

  factory FixedCostCategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$FixedCostCategoryEntityFromJson(json);
}
