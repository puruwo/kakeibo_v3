// Local Import
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';

DatabaseHelper db = DatabaseHelper.instance;

void tBL003RecordDelete(int id) async {
  db.delete(SqfBudget.tableName,id);
}


