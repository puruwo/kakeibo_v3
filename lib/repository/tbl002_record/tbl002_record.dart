import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/tableNameKey.dart';

//Freezedで生成されるデータクラス
part 'tbl002_record.freezed.dart';
//jsonを変換する処理が生成されるクラス
part 'tbl002_record.g.dart';

DatabaseHelper db = DatabaseHelper.instance;

@freezed
class TBL002Record with _$TBL002Record {
  const TBL002Record._();

  const factory TBL002Record({
    @Default(0) int id,
    required String date,
    @Default(0) int price,
    @Default(0) int category,
    @Default('') String memo,
  }) = _TBL002Record;

  @override
  factory TBL002Record.fromJson(Map<String, dynamic> json) =>
      _$TBL002RecordFromJson(json);

  //登録ボタン押下関数
  insert() {
    print('$category,$date,$price,$memo');
    // //データベースに格納の処理
    print(db.insert(TBL002RecordKey().tableName,{
      TBL002RecordKey().date: date,
      TBL002RecordKey().price: price,
      TBL002RecordKey().incomeCategoryId: category,
      TBL002RecordKey().memo: memo
    }));
  }

  update(){
    print('$category,$date,$price,$memo,にこうしんしました');
    db.update(TBL002RecordKey().tableName, {
      TBL002RecordKey().date: date,
      TBL002RecordKey().price: price,
      TBL002RecordKey().incomeCategoryId: category,
      TBL002RecordKey().memo: memo
    }, id);
  }

  delete(){
    db.delete(TBL002RecordKey().tableName, id);
    print('${TBL002RecordKey().tableName}で${id}のレコードを削除しました');
  }
}
