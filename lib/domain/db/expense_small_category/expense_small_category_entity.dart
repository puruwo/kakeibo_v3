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
  }) = _SmallCategoryEntity;

  @override
  factory ExpenseSmallCategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$ExpenseSmallCategoryEntityFromJson(json);

  update() {
    print(
        'id: $id,smallCategoryKey: $smallCategoryOrderKey,bigCategoryKey: $bigCategoryKey,categoryName: $smallCategoryName,defaultDisplayed: $displayedOrderInBig,isDisplayed:$defaultDisplayedを登録しました');
    db.update(
        TBL201RecordKey().tableName,
        {
          TBL201RecordKey().id: id,
          TBL201RecordKey().smallCategoryOrderKey: smallCategoryOrderKey,
          TBL201RecordKey().bigCategoryKey: bigCategoryKey,
          TBL201RecordKey().displayedOrderInBig: displayedOrderInBig,
          TBL201RecordKey().categoryName: smallCategoryName,
          TBL201RecordKey().defaultDisplayed: defaultDisplayed,
        },
        id);
  }
}
