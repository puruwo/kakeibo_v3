import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'category_entity.freezed.dart';
//jsonを変換する処理が生成されるクラス
part 'category_entity.g.dart';

@freezed
class CategoryEntity with _$CategoryEntity {
  const factory CategoryEntity({
    @Default(0) int id,
    required String categoryColor,
    required String bigCategoryName,
    required String categoryIconPath,
    @Default(0) int budget,
    @Default(0) int totalExpenseByBigCategory,
  }) = _CategoryEntity;

  @override
  factory CategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$CategoryEntityFromJson(json);
}