import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/core/category_entity/i_category_entity.dart';

//Freezedで生成されるデータクラス
part 'expense_category_entity.freezed.dart';
//jsonを変換する処理が生成されるクラス
part 'expense_category_entity.g.dart';

@freezed
class ExpenseCategoryEntity with _$ExpenseCategoryEntity implements ICategoryEntity {
  const factory ExpenseCategoryEntity({
    @Default(0) int id,
    required int smallCategoryOrderKey,
    required int bigCategoryKey,
    required int displaydOrderInBig,
    required String smallCategoryName,
    required int defaultDisplayed,

    required String  bigCategoryName,
    required String  colorCode,
    required String  resourcePath,
    required int  displayOrder,
    required int  isDisplayed,

    // 表示用のソートキー
    @Default(0) int sortKey,

  }) = _ExpenseCategoryEntity;

  @override
  factory ExpenseCategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$ExpenseCategoryEntityFromJson(json);
}