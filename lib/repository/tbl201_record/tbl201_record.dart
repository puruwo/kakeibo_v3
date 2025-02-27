import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/tableNameKey.dart';

//Freezedで生成されるデータクラス
part 'tbl201_record.freezed.dart';
//jsonを変換する処理が生成されるクラス
part 'tbl201_record.g.dart';

DatabaseHelper db = DatabaseHelper.instance;

@freezed
class TBL201Record with _$TBL201Record {
  const TBL201Record._();

  const factory TBL201Record({
    required int id,
    required int smallCategoryOrderKey,
    required int bigCategoryKey,
    required int displayedOrderInBig,
    required String categoryName,
    required int defaultDisplayed,
  }) = _TBL201Record;

  @override
  factory TBL201Record.fromJson(Map<String, dynamic> json) =>
      _$TBL201RecordFromJson(json);

  //登録ボタン押下関数
  insert() {
    print('id: $id,smallCategoryKey: $smallCategoryOrderKey,bigCategoryKey: $bigCategoryKey,displayedOrderInBigcategoryName: $categoryName,defaultDisplayed: $defaultDisplayed,を登録しました');
    // //データベースに格納の処理
    print(db.insert(TBL201RecordKey().tableName,{
      TBL201RecordKey().id: id,
      TBL201RecordKey().smallCategoryOrderKey: smallCategoryOrderKey,
      TBL201RecordKey().bigCategoryKey: bigCategoryKey,
      TBL201RecordKey().displayedOrderInBig: displayedOrderInBig,
      TBL201RecordKey().categoryName: categoryName,
      TBL201RecordKey().defaultDisplayed: defaultDisplayed,
    }));
  }

  update(){
    print('id: $id,smallCategoryKey: $smallCategoryOrderKey,bigCategoryKey: $bigCategoryKey,displayedOrderInBigcategoryName: $categoryName,defaultDisplayed: $defaultDisplayed,にこうしんしました');
    db.update(TBL201RecordKey().tableName, {
      TBL201RecordKey().id: id,
      TBL201RecordKey().smallCategoryOrderKey: smallCategoryOrderKey,
      TBL201RecordKey().bigCategoryKey: bigCategoryKey,
      TBL201RecordKey().displayedOrderInBig: displayedOrderInBig,
      TBL201RecordKey().categoryName: categoryName,
      TBL201RecordKey().defaultDisplayed: defaultDisplayed,
    }, id);
  }

  //削除機能はなし
  //過去のレコードのカテゴリーの参照先がなくなってしまうため
}
