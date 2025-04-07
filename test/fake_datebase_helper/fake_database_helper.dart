// fake_database_helper.dart
import 'dart:async';

import 'package:kakeibo/model/database_helper.dart';
import 'package:sqflite_common/sqlite_api.dart';

class FakeDatabaseHelper implements DatabaseHelper {
  
  @override
  Future<List<Map<String, dynamic>>> queryRowsWhere(
      String table, String where, List<dynamic> whereArgs) async {
    // 例: DailyExpenseEntity.fromJson が、'id', 'amount', 'date'などのキーを期待していると仮定
    // ここでは whereArgs[0] に入っている日付（yyyyMMdd形式）をそのまま返す例とする
    return [
      {
        'dateTime': whereArgs[0],
        'totalExpense': 100,
      }
    ];
  }

  @override
  // TODO: implement database
  Future<Database?> get database => throw UnimplementedError();

  @override
  Future<int> delete(String table, int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> row) {
    // TODO: implement insert
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> query(String sql) {
    // TODO: implement query
    throw UnimplementedError();
  }

  @override
  Future<int?> queryRowCount(String table) {
    // TODO: implement queryRowCount
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> queryRows(String table) {
    // TODO: implement queryRows
    throw UnimplementedError();
  }

  @override
  Future<int> update(String table, Map<String, dynamic> row, int id) {
    // TODO: implement update
    throw UnimplementedError();
  }

  // その他、DatabaseHelperに定義されているメソッドは必要に応じて実装するか、throwで済ませる
}