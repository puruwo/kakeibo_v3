import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';

//Freezedで生成されるデータクラス
part 'tbl003_record.freezed.dart';
//jsonを変換する処理が生成されるクラス
part 'tbl003_record.g.dart';

DatabaseHelper db = DatabaseHelper.instance;

@freezed
class TBL003Record with _$TBL003Record {
  const TBL003Record._();

  const factory TBL003Record({
    @Default(0) int id,
    required String date,
    required int bigCategory,
    required int price,
  }) = _TBL003Record;

  @override
  factory TBL003Record.fromJson(Map<String, dynamic> json) =>
      _$TBL003RecordFromJson(json);

  //登録ボタン押下関数
  insert() {
    print('$date,$bigCategory,$price');
    // //データベースに格納の処理
    print(db.insert(SqfBudget().tableName,{
      SqfBudget().date: date,
      SqfBudget().price: price,
      SqfBudget().bigCategoryId: bigCategory,
    }));
  }

  delete(){
    db.delete(SqfBudget().tableName, id);
    print('${SqfBudget().tableName}で${id}のレコードを削除しました');
  }

}
