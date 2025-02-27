import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/tableNameKey.dart';

//Freezedで生成されるデータクラス
part 'tbl001_record.freezed.dart';
//jsonを変換する処理が生成されるクラス
part 'tbl001_record.g.dart';

DatabaseHelper db = DatabaseHelper.instance;

@freezed
class TBL001Record with _$TBL001Record {
  const TBL001Record._();

  const factory TBL001Record({
    @Default(0) int id,
    required String date,
    @Default(0) int price,
    @Default(0) int category,
    @Default('') String memo,
  }) = _TBL001Record;

  @override
  factory TBL001Record.fromJson(Map<String, dynamic> json) =>
      _$TBL001RecordFromJson(json);

  //登録ボタン押下関数
  insert() {
    print('$category,$date,$price,$memo');
    // //データベースに格納の処理
    print(db.insert(TBL001RecordKey().tableName,{
      TBL001RecordKey().date: date,
      TBL001RecordKey().price: price,
      TBL001RecordKey().paymentCategoryId: category,
      TBL001RecordKey().memo: memo
    }));
  }

  update(){
    print('id: $id,category:$category,$date,$price円,$memo,にこうしんしました');
    db.update(TBL001RecordKey().tableName, {
      TBL001RecordKey().date: date,
      TBL001RecordKey().price: price,
      TBL001RecordKey().paymentCategoryId: category,
      TBL001RecordKey().memo: memo
    }, id);
  }

  delete()async{
    await db.delete(TBL001RecordKey().tableName, id);
    print('${TBL001RecordKey().tableName}で${id}のレコードを削除しました');
  }
}
