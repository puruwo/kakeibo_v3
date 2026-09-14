import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';

//Freezedで生成されるデータクラス
part 'expense_small_category_entity.freezed.dart';
//jsonを変換する処理が生成されるクラス
part 'expense_small_category_entity.g.dart';

DatabaseHelper db = DatabaseHelper.instance;

@freezed
class ExpenseSmallCategoryEntity with _$ExpenseSmallCategoryEntity {
  const ExpenseSmallCategoryEntity._();

  const factory ExpenseSmallCategoryEntity({
    required int id,
    required int smallCategoryOrderKey,
    required int bigCategoryKey,
    required int displayedOrderInBig,
    required String smallCategoryName,
    required int defaultDisplayed,
    // 論理削除（0=有効 / 1=削除済み）。v14で追加（KP-024）
    @Default(0) int deleteFlag,
  }) = _SmallCategoryEntity;

  @override
  factory ExpenseSmallCategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$ExpenseSmallCategoryEntityFromJson(json);

  update() {
    print(
        'id: $id,smallCategoryKey: $smallCategoryOrderKey,bigCategoryKey: $bigCategoryKey,categoryName: $smallCategoryName,defaultDisplayed: $displayedOrderInBig,isDisplayed:$defaultDisplayedを登録しました');
    db.update(
        SqfExpenseSmallCategory.tableName,
        {
          SqfExpenseSmallCategory.id: id,
          SqfExpenseSmallCategory.smallCategoryOrderKey: smallCategoryOrderKey,
          SqfExpenseSmallCategory.bigCategoryKey: bigCategoryKey,
          SqfExpenseSmallCategory.displayedOrderInBig: displayedOrderInBig,
          SqfExpenseSmallCategory.name: smallCategoryName,
          SqfExpenseSmallCategory.defaultDisplayed: defaultDisplayed,
        },
        id);
  }
}
