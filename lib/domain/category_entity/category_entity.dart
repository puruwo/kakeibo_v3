import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/tbl202/big_category_entity.dart';

//Freezedで生成されるデータクラス
part 'category_entity.freezed.dart';
//jsonを変換する処理が生成されるクラス
part 'category_entity.g.dart';

@freezed
class CategoryEntity with _$CategoryEntity {
  const factory CategoryEntity({
    @Default(0) int id,
    required int smallCategoryOrderKey,
    required int bigCategoryKey,
    required int displaydOrderInBig,
    required String smallCategoryName,
    required int defaultDisplayed,
    required BigCategoryEntity bigCategoryEntity,
  }) = _CategoryEntity;

  @override
  factory CategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$CategoryEntityFromJson(json);
}