import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/tableNameKey.dart';

//Freezedで生成されるデータクラス
part 'tbl202_record.freezed.dart';
//jsonを変換する処理が生成されるクラス
part 'tbl202_record.g.dart';

DatabaseHelper db = DatabaseHelper.instance;

@freezed
class TBL202Record with _$TBL202Record {
  const TBL202Record._();

  const factory TBL202Record({
    required int id,
    required String colorCode,
    required String bigCategoryName,
    required String resourcePath,
    required int displayOrder,
    required int isDisplayed,
  }) = _TBL202Record;

  @override
  factory TBL202Record.fromJson(Map<String, dynamic> json) =>
      _$TBL202RecordFromJson(json);

  // displayOrder指定で挿入
  insert() {
    print('id: $id,smallCategoryKey: $colorCode,bigCategoryKey: $bigCategoryName,categoryName: $resourcePath,defaultDisplayed: $displayOrder,を登録しました');
    // //データベースに格納の処理
    print(db.insert(TBL202RecordKey().tableName,{
      TBL202RecordKey().id: id,
      TBL202RecordKey().colorCode: colorCode,
      TBL202RecordKey().bigCategoryName: bigCategoryName,
      TBL202RecordKey().resourcePath: resourcePath,
      TBL202RecordKey().displayOrder: displayOrder,
      TBL202RecordKey().isDisplayed: isDisplayed,
    }));
  }
  // displayOrder指定なしで最後尾に挿入
  insertToLast() {
    print('id: $id,smallCategoryKey: $colorCode,bigCategoryKey: $bigCategoryName,categoryName: $resourcePath,defaultDisplayed: $displayOrder,を登録しました');
    // //データベースに格納の処理
    print(db.insert(TBL202RecordKey().tableName,{
      TBL202RecordKey().id: id,
      TBL202RecordKey().colorCode: colorCode,
      TBL202RecordKey().bigCategoryName: bigCategoryName,
      TBL202RecordKey().resourcePath: resourcePath,
      TBL202RecordKey().isDisplayed: isDisplayed,
    }));
  }

  update(){
    print('id: $id,smallCategoryKey: $colorCode,bigCategoryKey: $bigCategoryName,categoryName: $resourcePath,defaultDisplayed: $displayOrder,isDisplayed:$isDisplayedを登録しました');
    db.update(TBL202RecordKey().tableName, {
      TBL202RecordKey().id: id,
      TBL202RecordKey().colorCode: colorCode,
      TBL202RecordKey().bigCategoryName: bigCategoryName,
      TBL202RecordKey().resourcePath: resourcePath,
      TBL202RecordKey().displayOrder: displayOrder,
      TBL202RecordKey().isDisplayed: isDisplayed,
    }, id);
  }

  //削除機能はなし
  //過去のレコードのカテゴリーの参照先がなくなってしまうため
}
