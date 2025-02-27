import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kakeibo/model/sql_sentence.dart';

import 'package:kakeibo/model/tableNameKey.dart';

class DatabaseHelper {
  // static final _databaseName = "kakeibo_on_mac.db"; // DB名
  // static final _databaseVersion = 6; // スキーマのバージョン指定
  static final _databaseName = "kakeibo.db"; // DB名
  static final _databaseVersion = 5; // スキーマのバージョン指定

  //読み出しデータ(Map)はImmutable!!!!!!!!!!
  //なので'Unsupported operation: read-only'が出た時はmakeMutable関数で返す必要がある

  // DatabaseHelper クラスを定義
  DatabaseHelper._privateConstructor();
  // DatabaseHelper._privateConstructor() コンストラクタを使用して生成されたインスタンスを返すように定義
  // DatabaseHelper クラスのインスタンスは、常に同じものであるという保証
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Databaseクラス型のstatic変数_databaseを宣言
  // クラスはインスタンス化しない
  static Database? _database;

  // databaseメソッド定義
  // 非同期処理
  Future<Database?> get database async {
    // _databaseがNULLか判定
    // NULLの場合、_initDatabaseを呼び出しデータベースの初期化し、_databaseに返す
    // NULLでない場合、そのまま_database変数を返す
    // これにより、データベースを初期化する処理は、最初にデータベースを参照するときにのみ実行されるようになります。
    // このような実装を「遅延初期化 (lazy initialization)」と呼びます。
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // データベース接続
  _initDatabase() async {
    // アプリケーションのドキュメントディレクトリのパスを取得
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // 取得パスを基に、データベースのパスを生成
    String path = join(documentsDirectory.path, _databaseName);
    // データベース接続
    return await openDatabase(
      path, version: _databaseVersion,

      // テーブル作成とレコード挿入
      onCreate: (Database db, int version) async {
        print('データベースの初期設定中');
        await DataBaseHelperHandling().funcOnCreate(db);
        print('データベースの初期設定が完了しました');
      },

      // DBアップグッレード時に一度だけ呼び出す
      onUpgrade: (db, oldVersion, newVersion) async {
        print('データベースをアップデート中です');
        await DataBaseHelperHandling().funcOnUpdate(db);
        print('アップデートが完了しました');
      },
    );
  }

  //挿入メソッド
  //dictionary形式でレコードを変数として入力
  //戻り値はid?を返す
  Future<int> insert(String table, Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(table, row);
  }

  //クエリメソッド
  //全行取得
  Future<List<Map<String, dynamic>>> queryRows(String table) async {
    Database? db = await instance.database;
    return await db!.query(table);
  }

  //条件指定
  Future<List<Map<String, dynamic>>> queryRowsWhere(
      String table, String where, List whereArgs) async {
    Database? db = await instance.database;
    return await db!.query(table, where: where, whereArgs: whereArgs);
  }

  // レコード数を確認
  Future<int?> queryRowCount(String table) async {
    Database? db = await instance.database;
    return Sqflite.firstIntValue(
        await db!.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // SQL入力のクエリ処理
  Future<List<Map<String, dynamic>>> query(String sql) async {
    Database? db = await instance.database;
    return await db!.rawQuery(sql);
  }

  //　更新処理
  Future<int> update(String table, Map<String, dynamic> row, int id) async {
    Database? db = await instance.database;
    return await db!.update(table, row, where: '_Id = ?', whereArgs: [id]);
  }

  //　削除処理
  Future<int> delete(String table, int id) async {
    Database? db = await instance.database;
    return await db!.delete(table, where: '_id = ?', whereArgs: [id]);
  }
}
