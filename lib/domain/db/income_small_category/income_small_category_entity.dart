import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';

//Freezedで生成されるデータクラス
part 'income_small_category_entity.freezed.dart';
//jsonを変換する処理が生成されるクラス
part 'income_small_category_entity.g.dart';

DatabaseHelper db = DatabaseHelper.instance;

@freezed
class IncomeSmallCategoryEntity with _$IncomeSmallCategoryEntity {
  const IncomeSmallCategoryEntity._();

  const factory IncomeSmallCategoryEntity({
    required int id,
    required int smallCategoryOrderKey,
    required int bigCategoryKey,
    required int displayedOrderInBig,
    required String smallCategoryName,
    required int defaultDisplayed,
  }) = _IncomeSmallCategoryEntity;

  @override
  factory IncomeSmallCategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$IncomeSmallCategoryEntityFromJson(json);

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
