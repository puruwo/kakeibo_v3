import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/core/category_entity/i_category_entity.dart';

//Freezedで生成されるデータクラス
part 'income_category_entity.freezed.dart';
//jsonを変換する処理が生成されるクラス
part 'income_category_entity.g.dart';

@freezed
class IncomeCategoryEntity with _$IncomeCategoryEntity implements ICategoryEntity {
  const factory IncomeCategoryEntity({
    @Default(0) int id,
    required int smallCategoryOrderKey,
    required int bigCategoryKey,
    required int displaydOrderInBig,
    required String categoryName,
    required int defaultDisplayed,

    required String  bigCategoryName,
    required String  colorCode,
    required String  resourcePath,

    // 表示用のソートキー
    @Default(0) int sortKey,
  }) = _IncomeCategoryEntity;

  @override
  factory IncomeCategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$IncomeCategoryEntityFromJson(json);
}