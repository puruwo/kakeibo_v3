import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'small_category_entity.freezed.dart';
//jsonを変換する処理が生成されるクラス
part 'small_category_entity.g.dart';

@freezed
class SmallCategoryEntity with _$SmallCategoryEntity {
  const factory SmallCategoryEntity({
    @Default(0) int id,
    @Default(0) int displeyOrder,
    required String smallCategoryName,
    @Default(0) int totalExpenseBySmallCategory,
  }) = _SmallCategoryEntity;

  @override
  factory SmallCategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$SmallCategoryEntityFromJson(json);
}