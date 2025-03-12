import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/category_entity/category_entity.dart';
import 'package:kakeibo/domain/small_category_entity/small_category_entity.dart';

//Freezedで生成されるデータクラス
part 'category_tile_entity.freezed.dart';

@freezed
class CategoryTileEntity with _$CategoryTileEntity {
  const factory CategoryTileEntity({
    required CategoryEntity categoryEntity,
    required List<SmallCategoryEntity> smallCategoryList,
  }) = _CategoryTileEntity;
}