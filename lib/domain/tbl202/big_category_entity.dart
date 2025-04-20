import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/tableNameKey.dart';

//Freezedで生成されるデータクラス
part 'big_category_entity.freezed.dart';
//jsonを変換する処理が生成されるクラス
part 'big_category_entity.g.dart';

DatabaseHelper db = DatabaseHelper.instance;

@freezed
class BigCategoryEntity with _$BigCategoryEntity {
  const BigCategoryEntity._();

  const factory BigCategoryEntity({
    required int id,
    required String colorCode,
    required String bigCategoryName,
    required String resourcePath,
    required int displayOrder,
    required int isDisplayed,
  }) = _BigCategoryEntity;

  @override
  factory BigCategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$BigCategoryEntityFromJson(json);

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
