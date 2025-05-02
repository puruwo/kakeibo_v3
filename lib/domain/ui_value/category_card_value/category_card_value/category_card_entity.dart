import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_entity.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_entity.dart';

//Freezedで生成されるデータクラス
part 'category_card_entity.freezed.dart';

@freezed
class CategoryCardEntity with _$CategoryCardEntity {
  const factory CategoryCardEntity({
    required CategoryAccountingEntity monthlyExpenseByCategoryEntity,
    required List<SmallCategoryTileEntity> smallCategoryList,
  }) = _CategoryCardEntity;
}