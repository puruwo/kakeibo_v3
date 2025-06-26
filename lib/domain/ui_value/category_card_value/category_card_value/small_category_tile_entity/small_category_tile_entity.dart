import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'small_category_tile_entity.freezed.dart';
//jsonを変換する処理が生成されるクラス
part 'small_category_tile_entity.g.dart';

@freezed
class SmallCategoryTileEntity with _$SmallCategoryTileEntity {
  const factory SmallCategoryTileEntity({
    @Default(0) int id,
    @Default(0) int displeyOrder,
    required String smallCategoryName,
    @Default(0) int totalExpenseBySmallCategory,
    @Default(0) int recordCount,
  }) = _SmallCategoryTileEntity;

  @override
  factory SmallCategoryTileEntity.fromJson(Map<String, dynamic> json) =>
      _$SmallCategoryTileEntityFromJson(json);
}