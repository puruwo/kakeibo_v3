import 'package:intl/intl.dart';

// Local Import
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/tableNameKey.dart';
import 'package:kakeibo/model/db_read_impl.dart';

DatabaseHelper db = DatabaseHelper.instance;

void tBL003RecordDelete(int id) async {
  db.delete(TBL003RecordKey().tableName,id);
}

void tBL202RecordDelete(int id) async {
  db.delete(TBL202RecordKey().tableName,id);
}

void tBL201RecordDelete(int id) async {
  db.delete(TBL201RecordKey().tableName,id);
}
