// マイグレーション（sql_on_update.dart）のDB結合テスト
//
// 旧形状のDBを実際に作ってから本物のマイグレーションを流し、
// 「列構成がどう変わるか・データが引き継がれるか」を仕様として固定する。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/sql_on_update.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/theme/category_palette.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helper/db_test_helper.dart';

// ---------------------------------------------------------------------------
// 旧形状のDDL（歴史上のスキーマなので、現在の定数ではなく当時の字面をそのまま置く）
// ---------------------------------------------------------------------------

/// v10で廃止した旧テーブル `fixed_cost_expense` の列名（移行テスト専用）
///
/// 本体からは削除済み（`sql_on_update.dart` の移行SQLに閉じている）ため、
/// 旧形状DBを組み立てるテスト側でも同じ字面をここに置く。
class SqfFixedCostExpense {
  static const tableName = 'fixed_cost_expense';

  static const id = '_id';
  static const fixedCostId = 'fixed_cost_id';
  static const fixedCostCategoryId = 'fixed_cost_category_id';
  static const date = 'date';
  static const price = 'price';
  static const name = 'name';
  static const confirmedCostType = 'confirmed_cost_type';
  static const isConfirmed = 'is_confirmed';
}

/// v10で廃止した旧テーブル `fixed_cost_category` の列名（移行テスト専用）
class SqfFixedCostCategory {
  static const tableName = 'fixed_cost_category';

  static const id = '_id';
  static const categoryName = 'category_name';
  static const colorCode = 'color_code';
  static const resourcePath = 'resource_path';
  static const displayOrder = 'display_order';
  static const isDisplayed = 'is_displayed';
}

/// v10で削除した `fixed_cost.fixed_cost_category_id` 列（移行テスト専用）
const _legacyFixedCostCategoryIdColumn = 'fixed_cost_category_id';

/// 旧固定費カテゴリーの既定「その他」の名称（参照欠損の救済先）
const _legacyFallbackCategoryName = 'その他';

/// v7以前の `fixed_cost` のDDL。
///
/// 出典: lib/model/sql_on_update.dart の `toV3` の CREATE 文。
/// 当時 `SqfFixedCost.firstPaymentDate` の値はタイポしていて
/// `fiirst_payment_date` だったため、その字面で固定している
/// （現在の定数を使うと「旧形状」を再現できなくなるため）。
const _createFixedCostWithTypo = '''
CREATE TABLE fixed_cost (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  variable INTEGER NOT NULL,
  price INTEGER,
  estimated_price INTEGER,
  fixed_cost_category_id INTEGER NOT NULL,
  interval_number INTEGER NOT NULL,
  interval_unit INTEGER NOT NULL,
  fiirst_payment_date TEXT NOT NULL,
  recent_payment_date TEXT,
  next_payment_date TEXT NOT NULL,
  delete_flag INTEGER NOT NULL
);
''';

/// タイポ修正後（= 現行と同じ）の `fixed_cost` のDDL。
///
/// 出典: lib/model/sql_on_update.dart の `toV8` が作る `fixed_cost_new` と同一形状。
const _createFixedCostFixed = '''
CREATE TABLE fixed_cost (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  variable INTEGER NOT NULL,
  price INTEGER,
  estimated_price INTEGER,
  fixed_cost_category_id INTEGER NOT NULL,
  interval_number INTEGER NOT NULL,
  interval_unit INTEGER NOT NULL,
  first_payment_date TEXT NOT NULL,
  recent_payment_date TEXT,
  next_payment_date TEXT NOT NULL,
  delete_flag INTEGER NOT NULL
);
''';

/// v6マイグレーション時点の `fixed_cost_expense` のDDL（`fixed_cost_id` 列が無い形）。
///
/// 出典: lib/model/sql_on_update.dart の `toV6` の CREATE 文。
const _createFixedCostExpenseWithoutFixedCostId = '''
CREATE TABLE fixed_cost_expense (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  fixed_cost_category_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  price INTEGER NOT NULL,
  name TEXT,
  confirmed_cost_type INTEGER,
  is_confirmed INTEGER NOT NULL
);
''';

/// v7以降の新規インストールが持つ `fixed_cost_expense` のDDL（`fixed_cost_id` 列あり）。
///
/// 出典: lib/model/sql_on_create.dart の CREATE 文。
const _createFixedCostExpenseWithFixedCostId = '''
CREATE TABLE fixed_cost_expense (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  fixed_cost_id INTEGER NOT NULL,
  fixed_cost_category_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  price INTEGER NOT NULL,
  name TEXT NOT NULL,
  confirmed_cost_type INTEGER NOT NULL,
  is_confirmed INTEGER NOT NULL
);
''';

/// toV8を一度適用済みの `fixed_cost_expense` のDDL。
///
/// toV8 は `ALTER TABLE ... ADD COLUMN` で列を足すため、`fixed_cost_id` は
/// NULL 許容かつ末尾の列になる。再実行時の挙動を見るために使う。
const _createFixedCostExpenseMigrated = '''
CREATE TABLE fixed_cost_expense (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  fixed_cost_category_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  price INTEGER NOT NULL,
  name TEXT,
  confirmed_cost_type INTEGER,
  is_confirmed INTEGER NOT NULL,
  fixed_cost_id INTEGER
);
''';

/// `fixed_cost_expense` の形状バリエーション
enum _FixedCostExpenseShape {
  /// v6マイグレーション経由の端末（fixed_cost_id 列が無い）
  withoutFixedCostId,

  /// v7以降の新規インストール（fixed_cost_id が NOT NULL）
  freshInstall,

  /// toV8適用済み（fixed_cost_id が NULL 許容）
  migrated,
}

/// テーブルの列名集合を取得する
Future<Set<String>> _columnNames(Database db, String table) async {
  final rows = await db.rawQuery('PRAGMA table_info($table)');
  return rows.map((row) => row['name'] as String).toSet();
}

/// 旧形状のテーブルだけを持つインメモリDBを開く（テスト終了時に自動close）
Future<Database> _openLegacyDatabase({
  bool fixedCostHasTypoColumn = true,
  _FixedCostExpenseShape fixedCostExpenseShape =
      _FixedCostExpenseShape.withoutFixedCostId,
}) async {
  final db = await databaseFactory.openDatabase(inMemoryDatabasePath);
  addTearDown(db.close);

  await db.execute(
    fixedCostHasTypoColumn ? _createFixedCostWithTypo : _createFixedCostFixed,
  );
  await db.execute(switch (fixedCostExpenseShape) {
    _FixedCostExpenseShape.withoutFixedCostId =>
      _createFixedCostExpenseWithoutFixedCostId,
    _FixedCostExpenseShape.freshInstall =>
      _createFixedCostExpenseWithFixedCostId,
    _FixedCostExpenseShape.migrated => _createFixedCostExpenseMigrated,
  });

  return db;
}

void main() {
  setUpDbTestEnvironment();

  // -------------------------------------------------------------------------
  // v6 → v7（カテゴリーカラー刷新）
  // -------------------------------------------------------------------------
  group('toV7: カテゴリーカラー更新', () {
    /// 現行スキーマのDBを開き、色コードだけv7以前の値へ差し戻す
    ///
    /// 旧色は 90ea5e2^ 時点の sql_on_create.dart の値。
    Future<Database> prepareLegacyColors() async {
      final db = await openTestDatabase();
      const legacyExpenseColors = [
        'FF7070',
        '21D19F',
        'ED112B',
        '2596FF',
        'FFC857',
        'B118C8',
        '3E2F5B',
      ];
      for (var i = 0; i < legacyExpenseColors.length; i++) {
        await db.execute(
          "UPDATE ${SqfExpenseBigCategory.tableName} SET ${SqfExpenseBigCategory.colorCode} = '${legacyExpenseColors[i]}' WHERE ${SqfExpenseBigCategory.id} = ${i + 1};",
        );
      }
      // 固定費カテゴリーはv10で廃止したため、onCreateではもう作られない。
      // toV7当時のDBには存在したので、旧形状を再現するためにここで作り直す
      // （出典: lib/model/sql_on_update.dart の toV6 の CREATE 文と初期データ）
      await db.execute('''
        CREATE TABLE ${SqfFixedCostCategory.tableName} (
          ${SqfFixedCostCategory.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${SqfFixedCostCategory.categoryName} TEXT NOT NULL,
          ${SqfFixedCostCategory.colorCode} TEXT NOT NULL,
          ${SqfFixedCostCategory.resourcePath} TEXT NOT NULL,
          ${SqfFixedCostCategory.displayOrder} INTEGER NOT NULL,
          ${SqfFixedCostCategory.isDisplayed} INTEGER NOT NULL
        );
      ''');
      await db.execute('''
        INSERT INTO ${SqfFixedCostCategory.tableName}
          (${SqfFixedCostCategory.categoryName}, ${SqfFixedCostCategory.colorCode}, ${SqfFixedCostCategory.resourcePath}, ${SqfFixedCostCategory.displayOrder}, ${SqfFixedCostCategory.isDisplayed})
        VALUES ('住居費', 'FF5722', 'assets/images/icon_home.svg', 0, 1),
               ('通信費', '2196F3', 'assets/images/icon_phone.svg', 1, 1),
               ('サブスク', '9C27B0', 'assets/images/icon_subscription.svg', 2, 1),
               ('光熱費', 'FFC107', 'assets/images/icon_utility.svg', 3, 1),
               ('その他', '607D8B', 'assets/images/icon_others.svg', 4, 1);
      ''');
      // 固定費カテゴリーはv6時点でカテゴリーごとにバラバラの色だった
      const legacyFixedCostColors = [
        'FF5722',
        '2196F3',
        '9C27B0',
        'FFC107',
        '607D8B',
      ];
      for (var i = 0; i < legacyFixedCostColors.length; i++) {
        await db.execute(
          "UPDATE ${SqfFixedCostCategory.tableName} SET ${SqfFixedCostCategory.colorCode} = '${legacyFixedCostColors[i]}' WHERE ${SqfFixedCostCategory.id} = ${i + 1};",
        );
      }
      await db.execute(
        "UPDATE ${SqfIncomeBigCategory.tableName} SET ${SqfIncomeBigCategory.colorCode} = 'FFC857' WHERE ${SqfIncomeBigCategory.id} = 1;",
      );
      await db.execute(
        "UPDATE ${SqfIncomeBigCategory.tableName} SET ${SqfIncomeBigCategory.colorCode} = 'ECB22D' WHERE ${SqfIncomeBigCategory.id} = 2;",
      );
      return db;
    }

    test('支出大カテゴリー7件の色が現行パレットの値へ更新される', () async {
      final db = await prepareLegacyColors();

      await DataBaseMigrate().toV7(db);

      final rows = await db.query(
        SqfExpenseBigCategory.tableName,
        orderBy: SqfExpenseBigCategory.id,
      );
      // toV7 が色を更新するのは _id = 1〜7 のみ。
      // v10 で onCreate に加わった固定費由来カテゴリー（_id = 8〜12）は対象外なので
      // 先頭7件だけを比較する
      expect(
        rows
            .take(7)
            .map((row) => row[SqfExpenseBigCategory.colorCode])
            .toList(),
        [
          CategoryPalette.expense1Hex,
          CategoryPalette.expense2Hex,
          CategoryPalette.expense3Hex,
          CategoryPalette.expense4Hex,
          CategoryPalette.expense5Hex,
          CategoryPalette.expense6Hex,
          CategoryPalette.expense7Hex,
        ],
      );
    });

    test('固定費カテゴリーの色は全件が固定費色に統一される', () async {
      final db = await prepareLegacyColors();

      await DataBaseMigrate().toV7(db);

      final rows = await db.query(
        SqfFixedCostCategory.tableName,
        orderBy: SqfFixedCostCategory.id,
      );
      expect(rows.length, 5);
      // WHERE句なしのUPDATEなので、カテゴリーに関係なく全件が同じ色になる
      for (final row in rows) {
        expect(
          row[SqfFixedCostCategory.colorCode],
          CategoryPalette.fixedCostHex,
        );
      }
    });

    test('収入大カテゴリー2件の色が現行パレットの値へ更新される', () async {
      final db = await prepareLegacyColors();

      await DataBaseMigrate().toV7(db);

      final rows = await db.query(
        SqfIncomeBigCategory.tableName,
        orderBy: SqfIncomeBigCategory.id,
      );
      expect(rows.map((row) => row[SqfIncomeBigCategory.colorCode]).toList(), [
        CategoryPalette.income1Hex,
        CategoryPalette.income2Hex,
      ]);
    });

    test('色以外の列（名前・アイコンパス・表示順）は変化しない', () async {
      final db = await prepareLegacyColors();
      final before = await db.query(
        SqfExpenseBigCategory.tableName,
        orderBy: SqfExpenseBigCategory.id,
      );

      await DataBaseMigrate().toV7(db);

      final after = await db.query(
        SqfExpenseBigCategory.tableName,
        orderBy: SqfExpenseBigCategory.id,
      );
      expect(after.length, before.length);
      for (var i = 0; i < after.length; i++) {
        expect(
          after[i][SqfExpenseBigCategory.name],
          before[i][SqfExpenseBigCategory.name],
        );
        expect(
          after[i][SqfExpenseBigCategory.resourcePath],
          before[i][SqfExpenseBigCategory.resourcePath],
        );
        expect(
          after[i][SqfExpenseBigCategory.displayOrder],
          before[i][SqfExpenseBigCategory.displayOrder],
        );
        expect(
          after[i][SqfExpenseBigCategory.isDisplayed],
          before[i][SqfExpenseBigCategory.isDisplayed],
        );
      }
    });

    test('更新対象のIDが存在しなくてもエラーにならない', () async {
      // UPDATE ... WHERE _id = N を並べているだけなので、0行更新でも例外にならない
      final db = await prepareLegacyColors();
      await db.delete(SqfExpenseBigCategory.tableName);

      await DataBaseMigrate().toV7(db);

      expect(
        await DatabaseHelper.instance.queryRowCount(
          SqfExpenseBigCategory.tableName,
        ),
        0,
      );
    });
  });

  // -------------------------------------------------------------------------
  // v7 → v8 ①: fixed_cost のタイポ列改名
  // -------------------------------------------------------------------------
  group('toV8: fixed_costのカラム名改名', () {
    test('タイポ列fiirst_payment_dateはfirst_payment_dateへ改名される', () async {
      final db = await _openLegacyDatabase();
      await db.insert('fixed_cost', {
        'name': 'ネット回線',
        'variable': 0,
        'price': 4400,
        'estimated_price': null,
        'fixed_cost_category_id': 3,
        'interval_number': 1,
        'interval_unit': 1,
        'fiirst_payment_date': '20241225',
        'recent_payment_date': null,
        'next_payment_date': '20250125',
        'delete_flag': 0,
      });

      await DataBaseMigrate().toV8(db);

      final columns = await _columnNames(db, SqfFixedCost.tableName);
      expect(columns.contains(SqfFixedCost.firstPaymentDate), isTrue);
      expect(columns.contains('fiirst_payment_date'), isFalse);
    });

    test('改名時に全列の値が引き継がれ、NULL許容列のNULLも保持される', () async {
      final db = await _openLegacyDatabase();
      // 変動費（price=NULL / estimated_price あり）と
      // 固定費（price あり / estimated_price=NULL）の両方を用意して型変換を確認する
      await db.insert('fixed_cost', {
        '_id': 10,
        'name': 'chatGPT',
        'variable': 1,
        'price': null,
        'estimated_price': 2500,
        'fixed_cost_category_id': 2,
        'interval_number': 1,
        'interval_unit': 1,
        'fiirst_payment_date': '20241225',
        'recent_payment_date': null,
        'next_payment_date': '20250125',
        'delete_flag': 0,
      });
      await db.insert('fixed_cost', {
        '_id': 20,
        'name': 'appleMusic',
        'variable': 0,
        'price': 1200,
        'estimated_price': null,
        'fixed_cost_category_id': 2,
        'interval_number': 2,
        'interval_unit': 3,
        'fiirst_payment_date': '20240101',
        'recent_payment_date': '20250101',
        'next_payment_date': '20250301',
        'delete_flag': 1,
      });

      await DataBaseMigrate().toV8(db);

      final rows = await db.query(
        SqfFixedCost.tableName,
        orderBy: SqfFixedCost.id,
      );
      expect(rows.length, 2);

      expect(rows[0][SqfFixedCost.id], 10);
      expect(rows[0][SqfFixedCost.name], 'chatGPT');
      expect(rows[0][SqfFixedCost.variable], 1);
      expect(rows[0][SqfFixedCost.price], isNull);
      expect(rows[0][SqfFixedCost.estimatedPrice], 2500);
      expect(rows[0][SqfFixedCost.firstPaymentDate], '20241225');
      expect(rows[0][SqfFixedCost.recentPaymentDate], isNull);
      expect(rows[0][SqfFixedCost.nextPaymentDate], '20250125');
      expect(rows[0][SqfFixedCost.deleteFlag], 0);

      expect(rows[1][SqfFixedCost.id], 20);
      expect(rows[1][SqfFixedCost.name], 'appleMusic');
      expect(rows[1][SqfFixedCost.price], 1200);
      expect(rows[1][SqfFixedCost.estimatedPrice], isNull);
      expect(rows[1][SqfFixedCost.intervalNumber], 2);
      expect(rows[1][SqfFixedCost.intervalUnit], 3);
      expect(rows[1][SqfFixedCost.firstPaymentDate], '20240101');
      expect(rows[1][SqfFixedCost.recentPaymentDate], '20250101');
      expect(rows[1][SqfFixedCost.deleteFlag], 1);
    });

    test('改名してもレコード数は変わらない', () async {
      final db = await _openLegacyDatabase();
      for (var i = 1; i <= 5; i++) {
        await db.insert('fixed_cost', {
          'name': '固定費$i',
          'variable': 0,
          'price': 100 * i,
          'fixed_cost_category_id': 1,
          'interval_number': 1,
          'interval_unit': 1,
          'fiirst_payment_date': '20250101',
          'next_payment_date': '20250201',
          'delete_flag': 0,
        });
      }

      await DataBaseMigrate().toV8(db);

      final rows = await db.query(SqfFixedCost.tableName);
      expect(rows.length, 5);
    });

    test('既にfirst_payment_dateの端末では改名処理がスキップされ、データが保たれる', () async {
      // 定数修正後・v8バージョンbump前のビルドでDBが作られた端末のケース。
      // 改名処理が走ると「no such column: fiirst_payment_date」で落ちるため、
      // 例外なく完了することが仕様。
      final db = await _openLegacyDatabase(fixedCostHasTypoColumn: false);
      await db.insert('fixed_cost', {
        '_id': 7,
        'name': 'アマプラ',
        'variable': 0,
        'price': 600,
        'fixed_cost_category_id': 2,
        'interval_number': 1,
        'interval_unit': 1,
        'first_payment_date': '20241225',
        'next_payment_date': '20250125',
        'delete_flag': 0,
      });

      await DataBaseMigrate().toV8(db);

      final rows = await db.query(SqfFixedCost.tableName);
      expect(rows.length, 1);
      expect(rows[0][SqfFixedCost.id], 7);
      expect(rows[0][SqfFixedCost.firstPaymentDate], '20241225');
    });
  });

  // -------------------------------------------------------------------------
  // v7 → v8 ②: fixed_cost_expense への fixed_cost_id 補完
  // -------------------------------------------------------------------------
  group('toV8: fixed_cost_expenseのfixed_cost_id補完', () {
    /// 固定費マスタ1件と、それに対応する支払実績1件を用意する
    Future<Database> prepareForBackfill() async {
      final db = await _openLegacyDatabase();
      await db.insert('fixed_cost', {
        '_id': 1,
        'name': 'ネット回線',
        'variable': 0,
        'price': 4400,
        'fixed_cost_category_id': 3,
        'interval_number': 1,
        'interval_unit': 1,
        'fiirst_payment_date': '20241225',
        'next_payment_date': '20250125',
        'delete_flag': 0,
      });
      return db;
    }

    test('fixed_cost_id列が無いテーブルにはNULL許容の列が追加される', () async {
      final db = await prepareForBackfill();

      await DataBaseMigrate().toV8(db);

      final info = await db.rawQuery(
        'PRAGMA table_info(${SqfFixedCostExpense.tableName})',
      );
      final column = info.firstWhere(
        (c) => c['name'] == SqfFixedCostExpense.fixedCostId,
        orElse: () => <String, Object?>{},
      );
      expect(column.isNotEmpty, isTrue);
      // ALTER TABLE ADD COLUMN で後付けするため NOT NULL は付かない
      expect(column['notnull'], 0);
    });

    test('名前と固定費カテゴリーが一致するマスタの_idで補完される', () async {
      final db = await prepareForBackfill();
      await db.insert('fixed_cost_expense', {
        '_id': 100,
        'fixed_cost_category_id': 3,
        'date': '20250125',
        'price': 4400,
        'name': 'ネット回線',
        'confirmed_cost_type': 0,
        'is_confirmed': 1,
      });

      await DataBaseMigrate().toV8(db);

      final rows = await db.query(SqfFixedCostExpense.tableName);
      expect(rows.length, 1);
      expect(rows[0][SqfFixedCostExpense.fixedCostId], 1);
    });

    test('支払日がマスタの支払日と違ってもマッチングに影響しない', () async {
      // 突合キーは名前とカテゴリーのみ（日付は使わない）ことを固定する
      final db = await prepareForBackfill();
      await db.insert('fixed_cost_expense', {
        'fixed_cost_category_id': 3,
        'date': '20991231', // マスタのどの支払日とも一致しない日付
        'price': 4400,
        'name': 'ネット回線',
        'confirmed_cost_type': 0,
        'is_confirmed': 1,
      });

      await DataBaseMigrate().toV8(db);

      final rows = await db.query(SqfFixedCostExpense.tableName);
      expect(rows[0][SqfFixedCostExpense.fixedCostId], 1);
    });

    test('名前が一致してもカテゴリーが違うレコードはNULLのまま残る', () async {
      final db = await prepareForBackfill();
      await db.insert('fixed_cost_expense', {
        'fixed_cost_category_id': 2, // マスタは3なので不一致
        'date': '20250125',
        'price': 4400,
        'name': 'ネット回線',
        'confirmed_cost_type': 0,
        'is_confirmed': 1,
      });

      await DataBaseMigrate().toV8(db);

      final rows = await db.query(SqfFixedCostExpense.tableName);
      expect(rows[0][SqfFixedCostExpense.fixedCostId], isNull);
    });

    test('一致するマスタが無いレコードはNULLのまま残る', () async {
      final db = await prepareForBackfill();
      await db.insert('fixed_cost_expense', {
        'fixed_cost_category_id': 3,
        'date': '20250125',
        'price': 1000,
        'name': '解約済みサービス', // マスタに存在しない名前
        'confirmed_cost_type': 0,
        'is_confirmed': 1,
      });

      await DataBaseMigrate().toV8(db);

      final rows = await db.query(SqfFixedCostExpense.tableName);
      expect(rows[0][SqfFixedCostExpense.fixedCostId], isNull);
    });

    test('同名・同カテゴリーのマスタが複数あってもLIMIT 1で1件だけ採用される', () async {
      final db = await prepareForBackfill();
      // 同じ名前・同じカテゴリーのマスタを追加（重複登録された想定）
      await db.insert('fixed_cost', {
        '_id': 2,
        'name': 'ネット回線',
        'variable': 0,
        'price': 4400,
        'fixed_cost_category_id': 3,
        'interval_number': 1,
        'interval_unit': 1,
        'fiirst_payment_date': '20241225',
        'next_payment_date': '20250125',
        'delete_flag': 0,
      });
      await db.insert('fixed_cost_expense', {
        'fixed_cost_category_id': 3,
        'date': '20250125',
        'price': 4400,
        'name': 'ネット回線',
        'confirmed_cost_type': 0,
        'is_confirmed': 1,
      });

      await DataBaseMigrate().toV8(db);

      final rows = await db.query(SqfFixedCostExpense.tableName);
      // ORDER BY が無いためどちらが選ばれるかは規定されない。「1件に決まること」を固定する
      expect(rows[0][SqfFixedCostExpense.fixedCostId], anyOf(1, 2));
    });

    test('補完してもレコード数と他の列は変わらない', () async {
      final db = await prepareForBackfill();
      for (var i = 1; i <= 3; i++) {
        await db.insert('fixed_cost_expense', {
          'fixed_cost_category_id': 3,
          'date': '2025010$i',
          'price': 100 * i,
          'name': 'ネット回線',
          'confirmed_cost_type': 1,
          'is_confirmed': 0,
        });
      }

      await DataBaseMigrate().toV8(db);

      final rows = await db.query(
        SqfFixedCostExpense.tableName,
        orderBy: SqfFixedCostExpense.id,
      );
      expect(rows.length, 3);
      for (var i = 0; i < rows.length; i++) {
        expect(rows[i][SqfFixedCostExpense.price], 100 * (i + 1));
        expect(rows[i][SqfFixedCostExpense.confirmedCostType], 1);
        expect(rows[i][SqfFixedCostExpense.isConfirmed], 0);
        expect(rows[i][SqfFixedCostExpense.fixedCostId], 1);
      }
    });

    test('toV8適用済みのDBでは補完がスキップされ、未突合のNULLは埋め直されない', () async {
      // fixed_cost_id 列が既にあると UPDATE 自体が走らない。
      // 一致するマスタがあってもNULLのまま残ることで「スキップ」を判別する。
      final db = await _openLegacyDatabase(
        fixedCostExpenseShape: _FixedCostExpenseShape.migrated,
      );
      await db.insert('fixed_cost', {
        '_id': 1,
        'name': 'ネット回線',
        'variable': 0,
        'price': 4400,
        'fixed_cost_category_id': 3,
        'interval_number': 1,
        'interval_unit': 1,
        'fiirst_payment_date': '20241225',
        'next_payment_date': '20250125',
        'delete_flag': 0,
      });
      await db.insert('fixed_cost_expense', {
        'fixed_cost_id': null,
        'fixed_cost_category_id': 3,
        'date': '20250125',
        'price': 4400,
        'name': 'ネット回線',
        'confirmed_cost_type': 0,
        'is_confirmed': 1,
      });

      await DataBaseMigrate().toV8(db);

      final rows = await db.query(SqfFixedCostExpense.tableName);
      expect(rows[0][SqfFixedCostExpense.fixedCostId], isNull);
    });

    test('新規インストール形状（fixed_cost_idがNOT NULL）でも例外なく完了し、既存値が保たれる', () async {
      final db = await _openLegacyDatabase(
        fixedCostExpenseShape: _FixedCostExpenseShape.freshInstall,
      );
      await db.insert('fixed_cost_expense', {
        'fixed_cost_id': 5,
        'fixed_cost_category_id': 3,
        'date': '20250125',
        'price': 4400,
        'name': 'ネット回線',
        'confirmed_cost_type': 0,
        'is_confirmed': 1,
      });

      await DataBaseMigrate().toV8(db);

      final rows = await db.query(SqfFixedCostExpense.tableName);
      expect(rows[0][SqfFixedCostExpense.fixedCostId], 5);
    });
  });

  // -------------------------------------------------------------------------
  // v7 → v8 ③: 再実行耐性
  // -------------------------------------------------------------------------
  group('toV8: 中断残骸への耐性', () {
    test('fixed_cost_newが残った状態でも成功する', () async {
      final db = await _openLegacyDatabase();
      await db.insert('fixed_cost', {
        'name': 'アマプラ',
        'variable': 0,
        'price': 600,
        'fixed_cost_category_id': 2,
        'interval_number': 1,
        'interval_unit': 1,
        'fiirst_payment_date': '20241225',
        'next_payment_date': '20250125',
        'delete_flag': 0,
      });
      // 前回の中断で残った作業テーブルを再現する
      await db.execute(
        _createFixedCostFixed.replaceFirst('fixed_cost', 'fixed_cost_new'),
      );

      await DataBaseMigrate().toV8(db);

      final columns = await _columnNames(db, SqfFixedCost.tableName);
      expect(columns.contains(SqfFixedCost.firstPaymentDate), isTrue);
      final rows = await db.query(SqfFixedCost.tableName);
      expect(rows.length, 1);
      expect(rows[0][SqfFixedCost.name], 'アマプラ');
    });

    test('2回連続で実行しても成功する（冪等）', () async {
      final db = await _openLegacyDatabase();
      await db.insert('fixed_cost', {
        'name': 'アマプラ',
        'variable': 0,
        'price': 600,
        'fixed_cost_category_id': 2,
        'interval_number': 1,
        'interval_unit': 1,
        'fiirst_payment_date': '20241225',
        'next_payment_date': '20250125',
        'delete_flag': 0,
      });
      await db.insert('fixed_cost_expense', {
        'fixed_cost_category_id': 2,
        'date': '20250125',
        'price': 600,
        'name': 'アマプラ',
        'confirmed_cost_type': 0,
        'is_confirmed': 1,
      });

      await DataBaseMigrate().toV8(db);
      await DataBaseMigrate().toV8(db);

      final fixedCosts = await db.query(SqfFixedCost.tableName);
      expect(fixedCosts.length, 1);
      final expenses = await db.query(SqfFixedCostExpense.tableName);
      expect(expenses.length, 1);
      expect(expenses[0][SqfFixedCostExpense.fixedCostId], 1);
    });
  });

  // -------------------------------------------------------------------------
  // toV9: 会計種別（account_type）導入
  // -------------------------------------------------------------------------
  group('toV9: income_big_categoryへの会計種別導入', () {
    /// v8以前の形状（account_type列なし）の income_big_category を作る
    ///
    /// 出典: lib/model/sql_on_create.dart のv8時点のCREATE文
    /// （account_type列はv9で追加されるため、当時の字面をそのまま置く）
    Future<Database> createV8ShapeIncomeBigCategory({
      bool withThirdCategory = false,
    }) async {
      final db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);
      await db.execute('''
        CREATE TABLE income_big_category (
          _id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          color_code TEXT NOT NULL,
          resource_path TEXT NOT NULL
        );
      ''');
      await db.execute('''
        INSERT INTO income_big_category (name, color_code, resource_path)
        VALUES ('月次収入', '21D19F', 'assets/images/icon_regular_income.svg'),
               ('ボーナス', '10B981', 'assets/images/icon_extra_income.svg');
      ''');
      if (withThirdCategory) {
        // 従来仕様でユーザーが追加できてしまっていた第3カテゴリー
        await db.execute('''
          INSERT INTO income_big_category (name, color_code, resource_path)
          VALUES ('副業', '059669', 'assets/images/icon_regular_income.svg');
        ''');
      }
      return db;
    }

    test('account_type列が追加され、月次収入=1（生活収支）・ボーナス=2（特別枠）になる', () async {
      final db = await createV8ShapeIncomeBigCategory();

      await DataBaseMigrate().toV9(db);

      final columns = await _columnNames(db, SqfIncomeBigCategory.tableName);
      expect(columns.contains(SqfIncomeBigCategory.accountType), isTrue);

      final rows = await db.query(
        SqfIncomeBigCategory.tableName,
        orderBy: SqfIncomeBigCategory.id,
      );
      expect(rows[0][SqfIncomeBigCategory.accountType], 1); // 月次収入=生活収支
      expect(rows[1][SqfIncomeBigCategory.accountType], 2); // ボーナス=特別枠
    });

    test('既存の第3カテゴリー（旧仕様の孤児）は生活収支（1）に編入される', () async {
      final db = await createV8ShapeIncomeBigCategory(withThirdCategory: true);

      await DataBaseMigrate().toV9(db);

      final rows = await db.query(
        SqfIncomeBigCategory.tableName,
        orderBy: SqfIncomeBigCategory.id,
      );
      expect(rows[2]['name'], '副業');
      expect(rows[2][SqfIncomeBigCategory.accountType], 1);
    });

    test('2回連続で実行しても列は重複せず値も変わらない（冪等性）', () async {
      final db = await createV8ShapeIncomeBigCategory();

      await DataBaseMigrate().toV9(db);
      await DataBaseMigrate().toV9(db);

      final columns = await db.rawQuery(
        'PRAGMA table_info(${SqfIncomeBigCategory.tableName})',
      );
      final accountTypeColumns = columns
          .where((c) => c['name'] == SqfIncomeBigCategory.accountType)
          .toList();
      expect(accountTypeColumns.length, 1);

      final rows = await db.query(
        SqfIncomeBigCategory.tableName,
        orderBy: SqfIncomeBigCategory.id,
      );
      expect(rows[0][SqfIncomeBigCategory.accountType], 1);
      expect(rows[1][SqfIncomeBigCategory.accountType], 2);
    });

    test('account_type列が既にあるDB（v9適用後の値変更あり）では値を上書きしない', () async {
      final db = await createV8ShapeIncomeBigCategory();
      await DataBaseMigrate().toV9(db);
      // ユーザーが第3カテゴリーを特別枠として追加した状態を再現
      await db.execute('''
        INSERT INTO income_big_category (name, color_code, resource_path, account_type)
        VALUES ('副業', '059669', 'assets/images/icon_regular_income.svg', 2);
      ''');

      await DataBaseMigrate().toV9(db);

      final rows = await db.query(
        SqfIncomeBigCategory.tableName,
        orderBy: SqfIncomeBigCategory.id,
      );
      // 再実行しても特別枠のまま（列が存在する場合はスキップされる）
      expect(rows[2][SqfIncomeBigCategory.accountType], 2);
    });
  });

  // -------------------------------------------------------------------------
  // v9 → v10（固定費カテゴリー統合）
  // -------------------------------------------------------------------------
  group('toV10: 固定費カテゴリー統合', () {
    /// v9時点の形状のDBを作る
    ///
    /// 出典: v10適用前の lib/model/sql_on_create.dart（expense は price NOT NULL・
    /// 新3列なし、fixed_cost は expense_small_category_id なし）。
    /// 支出カテゴリーには固定費カテゴリーと同名の「通信費」を1件混ぜ、
    /// 同名併存（マージしない）が検証できるようにしている。
    Future<Database> createV9ShapeDatabase({
      bool withUserAddedFixedCostCategory = true,
    }) async {
      final db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);

      await db.execute('''
        CREATE TABLE expense (
          _id INTEGER PRIMARY KEY AUTOINCREMENT,
          expense_small_category_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          price INTEGER NOT NULL,
          memo TEXT,
          income_source_big_category INTEGER NOT NULL
        );
      ''');
      await db.execute('''
        CREATE TABLE expense_big_category (
          _id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          color_code TEXT NOT NULL,
          resource_path TEXT NOT NULL,
          display_order INTEGER NOT NULL,
          is_displayed INTEGER NOT NULL
        );
      ''');
      // 「通信費」は固定費カテゴリーにも同名があるカテゴリー（併存の検証用）
      await db.execute('''
        INSERT INTO expense_big_category (name, color_code, resource_path, display_order, is_displayed)
        VALUES('食費', 'FF7171', 'assets/images/icon_meal.svg', 0, 1),
              ('日用品', 'FB5B01', 'assets/images/icon_commodity.svg', 1, 1),
              ('通信費', '4BA6FF', 'assets/images/icon_transportation.svg', 2, 1);
      ''');
      await db.execute('''
        CREATE TABLE expense_small_category (
          _id INTEGER PRIMARY KEY AUTOINCREMENT,
          big_category_key INTEGER NOT NULL,
          name TEXT NOT NULL,
          small_category_order_key INTEGER NOT NULL,
          displayed_order_in_big INTEGER NOT NULL,
          default_displayed INTEGER NOT NULL
        );
      ''');
      await db.execute('''
        INSERT INTO expense_small_category (big_category_key, name, small_category_order_key, displayed_order_in_big, default_displayed)
        VALUES(1, '食費', 0, 0, 1),
              (2, '消耗品', 1, 0, 1),
              (3, '通信費', 2, 0, 1);
      ''');
      await db.execute(_createFixedCostFixed);
      await db.execute('''
        CREATE TABLE fixed_cost_category (
          _id INTEGER PRIMARY KEY AUTOINCREMENT,
          category_name TEXT NOT NULL,
          color_code TEXT NOT NULL,
          resource_path TEXT NOT NULL,
          display_order INTEGER NOT NULL,
          is_displayed INTEGER NOT NULL
        );
      ''');
      // 既定5件（出典: v10適用前の sql_on_create.dart）
      await db.execute('''
        INSERT INTO fixed_cost_category (category_name, color_code, resource_path, display_order, is_displayed)
        VALUES ('住居費', '8E8E93', 'assets/images/icon_home.svg', 0, 1),
               ('サブスク', '8E8E93', 'assets/images/icon_subscription.svg', 1, 1),
               ('通信費', '8E8E93', 'assets/images/icon_cell_tower.svg', 2, 1),
               ('光熱費', '8E8E93', 'assets/images/icon_water_drop.svg', 3, 1),
               ('その他', '8E8E93', 'assets/images/icon_others.svg', 4, 0);
      ''');
      if (withUserAddedFixedCostCategory) {
        // ユーザーが追加した6件目
        await db.execute('''
          INSERT INTO fixed_cost_category (category_name, color_code, resource_path, display_order, is_displayed)
          VALUES ('保険', '8E8E93', 'assets/images/icon_others.svg', 5, 1);
        ''');
      }
      // 実績テーブル（v9時点の形状。fixed_cost_id は toV8 でADD COLUMN済み＝NULL許容）
      await db.execute(_createFixedCostExpenseMigrated);
      return db;
    }

    /// 旧実績（fixed_cost_expense）を1件入れる
    ///
    /// 未確定行のpriceは現行実装で0固定（推定額ではない）ため既定を0にしている。
    Future<void> insertLegacyFixedCostExpense(
      Database db, {
      required int id,
      required int fixedCostCategoryId,
      required String date,
      required String name,
      int? fixedCostId,
      int price = 0,
      int isConfirmed = 0,
    }) async {
      await db.insert(SqfFixedCostExpense.tableName, {
        SqfFixedCostExpense.id: id,
        SqfFixedCostExpense.fixedCostId: fixedCostId,
        SqfFixedCostExpense.fixedCostCategoryId: fixedCostCategoryId,
        SqfFixedCostExpense.date: date,
        SqfFixedCostExpense.price: price,
        SqfFixedCostExpense.name: name,
        SqfFixedCostExpense.confirmedCostType: 0,
        SqfFixedCostExpense.isConfirmed: isConfirmed,
      });
    }

    /// 固定費マスタを1件入れる（fixed_cost_category_id を指定できる）
    Future<void> insertFixedCostMaster(
      Database db, {
      required int id,
      required String name,
      required int fixedCostCategoryId,
    }) async {
      await db.execute('''
        INSERT INTO fixed_cost
          (_id, name, variable, price, estimated_price, fixed_cost_category_id, interval_number, interval_unit, first_payment_date, recent_payment_date, next_payment_date, delete_flag)
        VALUES ($id, '$name', 0, 1000, NULL, $fixedCostCategoryId, 1, 1, '20250125', NULL, '20250225', 0);
      ''');
    }

    test('expenseに3列が追加され、priceはNULL許容になる', () async {
      final db = await createV9ShapeDatabase();

      await DataBaseMigrate().toV10(db);

      final columns = await db.rawQuery(
        'PRAGMA table_info(${SqfExpense.tableName})',
      );
      final byName = {for (final c in columns) c['name'] as String: c};
      expect(byName.containsKey(SqfExpense.fixedCostId), isTrue);
      expect(byName.containsKey(SqfExpense.isConfirmed), isTrue);
      expect(byName.containsKey(SqfExpense.estimatedPrice), isTrue);
      // price の NOT NULL 制約が外れている（notnull=0）
      expect(byName[SqfExpense.price]!['notnull'], 0);
      expect(byName[SqfExpense.isConfirmed]!['notnull'], 1);
    });

    test('既存のexpense行は全列が保全され、通常支出として is_confirmed=1 になる', () async {
      final db = await createV9ShapeDatabase();
      await db.execute('''
        INSERT INTO expense (_id, expense_small_category_id, date, price, memo, income_source_big_category)
        VALUES (1, 2, '20250701', 1200, 'ラーメン', 1),
               (2, 3, '20250702', 3400, NULL, 2);
      ''');

      await DataBaseMigrate().toV10(db);

      final rows = await db.query(SqfExpense.tableName, orderBy: SqfExpense.id);
      expect(rows, hasLength(2));
      expect(rows[0][SqfExpense.id], 1);
      expect(rows[0][SqfExpense.expenseSmallCategoryId], 2);
      expect(rows[0][SqfExpense.date], '20250701');
      expect(rows[0][SqfExpense.price], 1200);
      expect(rows[0][SqfExpense.memo], 'ラーメン');
      expect(rows[0][SqfExpense.incomeSourceBigCategory], 1);
      expect(rows[0][SqfExpense.fixedCostId], isNull);
      expect(rows[0][SqfExpense.isConfirmed], 1);
      expect(rows[0][SqfExpense.estimatedPrice], isNull);
      // NULL許容列のNULLも保持される
      expect(rows[1][SqfExpense.memo], isNull);
      expect(rows[1][SqfExpense.price], 3400);
    });

    test('固定費カテゴリー6件が大カテゴリーとして末尾に移設され、色とアイコンを引き継ぐ', () async {
      final db = await createV9ShapeDatabase();

      await DataBaseMigrate().toV10(db);

      final rows = await db.query(
        SqfExpenseBigCategory.tableName,
        orderBy: SqfExpenseBigCategory.displayOrder,
      );
      // 既存3件＋固定費カテゴリー6件
      expect(rows, hasLength(9));
      final moved = rows.sublist(3);
      expect(moved.map((row) => row[SqfExpenseBigCategory.name]).toList(), [
        '住居費',
        'サブスク',
        '通信費',
        '光熱費',
        'その他',
        '保険',
      ]);
      // 表示順は既存の最大値(2)の次から連番
      expect(
        moved.map((row) => row[SqfExpenseBigCategory.displayOrder]).toList(),
        [3, 4, 5, 6, 7, 8],
      );
      // 色・アイコンは元の値を引き継ぐ
      expect(moved.first[SqfExpenseBigCategory.colorCode], '8E8E93');
      expect(
        moved.first[SqfExpenseBigCategory.resourcePath],
        'assets/images/icon_home.svg',
      );
      // is_displayed も引き継ぐ（「その他」は非表示で作ってある）
      expect(moved[4][SqfExpenseBigCategory.isDisplayed], 0);
    });

    test('移設した各大カテゴリーの配下に同名の小カテゴリーが1件ずつ作られる', () async {
      final db = await createV9ShapeDatabase();

      await DataBaseMigrate().toV10(db);

      final smalls = await db.query(
        SqfExpenseSmallCategory.tableName,
        orderBy: SqfExpenseSmallCategory.id,
      );
      // 既存3件＋固定費カテゴリー6件
      expect(smalls, hasLength(9));
      final added = smalls.sublist(3);
      expect(added.map((row) => row[SqfExpenseSmallCategory.name]).toList(), [
        '住居費',
        'サブスク',
        '通信費',
        '光熱費',
        'その他',
        '保険',
      ]);
      // 通し順は既存の最大値(2)の次から連番、既定表示はON
      expect(
        added
            .map((row) => row[SqfExpenseSmallCategory.smallCategoryOrderKey])
            .toList(),
        [3, 4, 5, 6, 7, 8],
      );
      for (final row in added) {
        expect(row[SqfExpenseSmallCategory.defaultDisplayed], 1);
        expect(row[SqfExpenseSmallCategory.displayedOrderInBig], 0);
      }

      // 小カテゴリーは移設で作った大カテゴリーに紐づく（既存の同名大カテゴリーではない）
      final bigs = await db.query(
        SqfExpenseBigCategory.tableName,
        orderBy: SqfExpenseBigCategory.id,
      );
      for (var i = 0; i < added.length; i++) {
        expect(
          added[i][SqfExpenseSmallCategory.bigCategoryKey],
          bigs[3 + i][SqfExpenseBigCategory.id],
        );
      }
    });

    test('同名の支出カテゴリーがあってもマージせず別レコードとして併存する', () async {
      final db = await createV9ShapeDatabase();

      await DataBaseMigrate().toV10(db);

      final rows = await db.query(
        SqfExpenseBigCategory.tableName,
        where: '${SqfExpenseBigCategory.name} = ?',
        whereArgs: ['通信費'],
      );
      // 既存の支出カテゴリーと固定費由来の2件が並ぶ
      expect(rows, hasLength(2));
      expect(rows[0][SqfExpenseBigCategory.colorCode], '4BA6FF');
      expect(rows[1][SqfExpenseBigCategory.colorCode], '8E8E93');
    });

    test(
      'fixed_costにexpense_small_category_idが追加され、全件が対応する小カテゴリーを指す',
      () async {
        final db = await createV9ShapeDatabase();
        await insertFixedCostMaster(
          db,
          id: 1,
          name: '家賃',
          fixedCostCategoryId: 1, // 住居費
        );
        await insertFixedCostMaster(
          db,
          id: 2,
          name: 'ネット回線',
          fixedCostCategoryId: 3, // 通信費
        );

        await DataBaseMigrate().toV10(db);

        // 新列が増え、旧列は削除される
        final columns = await _columnNames(db, SqfFixedCost.tableName);
        expect(columns.contains(SqfFixedCost.expenseSmallCategoryId), isTrue);
        expect(columns.contains(_legacyFixedCostCategoryIdColumn), isFalse);

        final smallIdOf = <String, int>{};
        for (final row in await db.query(
          SqfExpenseSmallCategory.tableName,
          orderBy: SqfExpenseSmallCategory.id,
        )) {
          smallIdOf[row[SqfExpenseSmallCategory.name] as String] =
              row[SqfExpenseSmallCategory.id] as int;
        }

        final fixedCosts = await db.query(
          SqfFixedCost.tableName,
          orderBy: SqfFixedCost.id,
        );
        expect(
          fixedCosts[0][SqfFixedCost.expenseSmallCategoryId],
          smallIdOf['住居費'],
        );
        // 「通信費」は既存支出カテゴリーにも同名があるが、移設で作った方（id昇順で後）を指す
        final movedCommunication = (await db.query(
          SqfExpenseSmallCategory.tableName,
          where: '${SqfExpenseSmallCategory.name} = ?',
          whereArgs: ['通信費'],
          orderBy: SqfExpenseSmallCategory.id,
        )).last[SqfExpenseSmallCategory.id];
        expect(
          fixedCosts[1][SqfFixedCost.expenseSmallCategoryId],
          movedCommunication,
        );
        // 参照が0（未解決）のまま残っている行は無い
        expect(
          fixedCosts.every(
            (row) => (row[SqfFixedCost.expenseSmallCategoryId] as int) > 0,
          ),
          isTrue,
        );
      },
    );

    test('参照先の固定費カテゴリーが欠損している行は「その他」由来の小カテゴリーへ割り当てる', () async {
      final db = await createV9ShapeDatabase();
      await insertFixedCostMaster(
        db,
        id: 1,
        name: '謎の固定費',
        fixedCostCategoryId: 999, // 存在しないカテゴリー
      );

      await DataBaseMigrate().toV10(db);

      final others = (await db.query(
        SqfExpenseSmallCategory.tableName,
        where: '${SqfExpenseSmallCategory.name} = ?',
        whereArgs: [_legacyFallbackCategoryName],
      )).single[SqfExpenseSmallCategory.id];
      final fixedCost = (await db.query(SqfFixedCost.tableName)).single;
      expect(fixedCost[SqfFixedCost.expenseSmallCategoryId], others);
    });

    test('「その他」が存在しないDBでも救済先（固定費その他）が作られて割り当てられる', () async {
      final db = await createV9ShapeDatabase();
      // ユーザーが「その他」を削除している状況
      await db.execute(
        "DELETE FROM ${SqfFixedCostCategory.tableName} WHERE ${SqfFixedCostCategory.categoryName} = 'その他';",
      );
      await insertFixedCostMaster(
        db,
        id: 1,
        name: '謎の固定費',
        fixedCostCategoryId: 999,
      );

      await DataBaseMigrate().toV10(db);

      final fallback = (await db.query(
        SqfExpenseSmallCategory.tableName,
        where: '${SqfExpenseSmallCategory.name} = ?',
        whereArgs: [
          FixedCostDerivedCategoryConstants.freshInstallFallbackCategoryName,
        ],
      )).single[SqfExpenseSmallCategory.id];
      final fixedCost = (await db.query(SqfFixedCost.tableName)).single;
      expect(fixedCost[SqfFixedCost.expenseSmallCategoryId], fallback);
    });

    test('2回連続で実行してもカテゴリーが二重に作られず、値も変わらない（冪等）', () async {
      final db = await createV9ShapeDatabase();
      await db.execute('''
        INSERT INTO expense (_id, expense_small_category_id, date, price, memo, income_source_big_category)
        VALUES (1, 2, '20250701', 1200, 'ラーメン', 1);
      ''');
      await insertFixedCostMaster(
        db,
        id: 1,
        name: '家賃',
        fixedCostCategoryId: 1,
      );

      await DataBaseMigrate().toV10(db);
      final bigsAfterFirst = await db.query(
        SqfExpenseBigCategory.tableName,
        orderBy: SqfExpenseBigCategory.id,
      );
      final smallsAfterFirst = await db.query(
        SqfExpenseSmallCategory.tableName,
        orderBy: SqfExpenseSmallCategory.id,
      );
      final fixedCostAfterFirst = (await db.query(
        SqfFixedCost.tableName,
      )).single;
      final expenseAfterFirst = (await db.query(SqfExpense.tableName)).single;

      await DataBaseMigrate().toV10(db);

      expect(
        await db.query(
          SqfExpenseBigCategory.tableName,
          orderBy: SqfExpenseBigCategory.id,
        ),
        bigsAfterFirst,
      );
      expect(
        await db.query(
          SqfExpenseSmallCategory.tableName,
          orderBy: SqfExpenseSmallCategory.id,
        ),
        smallsAfterFirst,
      );
      expect((await db.query(SqfFixedCost.tableName)).single, {
        ...fixedCostAfterFirst,
      });
      expect((await db.query(SqfExpense.tableName)).single, {
        ...expenseAfterFirst,
      });
    });

    test('中断残骸（expense_v10_new）が残っていても成功する', () async {
      final db = await createV9ShapeDatabase();
      await db.execute('CREATE TABLE expense_v10_new (dummy INTEGER);');

      await DataBaseMigrate().toV10(db);

      final columns = await _columnNames(db, SqfExpense.tableName);
      expect(columns.contains(SqfExpense.isConfirmed), isTrue);
    });

    // --- 手順3・4: 実績移行と旧テーブルのDROP ---

    /// 移設先の小カテゴリーID（移設で作られた方）を名前で引く
    Future<int> movedSmallCategoryId(Database db, String name) async {
      final rows = await db.rawQuery(
        '''
        SELECT esc.${SqfExpenseSmallCategory.id} AS id
        FROM ${SqfExpenseSmallCategory.tableName} esc
        JOIN ${SqfExpenseBigCategory.tableName} ebc
          ON ebc.${SqfExpenseBigCategory.id} = esc.${SqfExpenseSmallCategory.bigCategoryKey}
        WHERE ebc.${SqfExpenseBigCategory.name} = ?
        ORDER BY ebc.${SqfExpenseBigCategory.displayOrder} DESC
        LIMIT 1;
        ''',
        [name],
      );
      return rows.single['id'] as int;
    }

    /// expenseの固定費行（fixed_cost_id IS NOT NULL 相当）を日付順で返す
    Future<List<Map<String, Object?>>> migratedRows(Database db) => db.query(
      SqfExpense.tableName,
      where: '${SqfExpense.memo} IS NOT NULL',
      orderBy: SqfExpense.date,
    );

    test('確定行はpriceを実額として移行し、estimated_priceはNULLになる', () async {
      final db = await createV9ShapeDatabase();
      await insertFixedCostMaster(db, id: 1, name: '家賃', fixedCostCategoryId: 1);
      await insertLegacyFixedCostExpense(
        db,
        id: 1,
        fixedCostId: 1,
        fixedCostCategoryId: 1,
        date: '20250601',
        name: '家賃',
        price: 80000,
        isConfirmed: 1,
      );

      await DataBaseMigrate().toV10(db);

      final row = (await db.query(SqfExpense.tableName)).single;
      // _idは持ち越さず新規採番（旧_id=1でも衝突しない）
      expect(row[SqfExpense.fixedCostId], 1);
      expect(row[SqfExpense.date], '20250601');
      expect(row[SqfExpense.price], 80000);
      expect(row[SqfExpense.estimatedPrice], isNull);
      expect(row[SqfExpense.isConfirmed], 1);
      // name→memo・拠出元は通常支出と同じ既定値（生活収支）
      expect(row[SqfExpense.memo], '家賃');
      expect(row[SqfExpense.incomeSourceBigCategory], AccountTypeConstants.living);
      // カテゴリーはマスタの移設先小カテゴリー
      expect(
        row[SqfExpense.expenseSmallCategoryId],
        await movedSmallCategoryId(db, '住居費'),
      );
    });

    test('未確定行はprice=NULLになり、マスタの推定額がestimated_priceへ転記される', () async {
      // 旧行のpriceは0固定で推定額ではないため、金額はマスタから引く（仕様 §5 手順3）
      final db = await createV9ShapeDatabase();
      await db.execute('''
        INSERT INTO fixed_cost
          (_id, name, variable, price, estimated_price, fixed_cost_category_id, interval_number, interval_unit, first_payment_date, recent_payment_date, next_payment_date, delete_flag)
        VALUES (2, '電気代', 1, NULL, 6500, 4, 1, 1, '20250125', NULL, '20250225', 0);
      ''');
      await insertLegacyFixedCostExpense(
        db,
        id: 1,
        fixedCostId: 2,
        fixedCostCategoryId: 4,
        date: '20250625',
        name: '電気代',
      );

      await DataBaseMigrate().toV10(db);

      final row = (await db.query(SqfExpense.tableName)).single;
      expect(row[SqfExpense.price], isNull);
      expect(row[SqfExpense.estimatedPrice], 6500);
      expect(row[SqfExpense.isConfirmed], 0);
      expect(
        row[SqfExpense.expenseSmallCategoryId],
        await movedSmallCategoryId(db, '光熱費'),
      );
    });

    test('件数と金額合計が確定・未確定それぞれで一致する', () async {
      final db = await createV9ShapeDatabase();
      // 確定2件（3000+4000）／未確定2件（マスタ推定額 6500×2）
      await insertFixedCostMaster(db, id: 1, name: '家賃', fixedCostCategoryId: 1);
      await db.execute('''
        INSERT INTO fixed_cost
          (_id, name, variable, price, estimated_price, fixed_cost_category_id, interval_number, interval_unit, first_payment_date, recent_payment_date, next_payment_date, delete_flag)
        VALUES (2, '電気代', 1, NULL, 6500, 4, 1, 1, '20250125', NULL, '20250225', 0);
      ''');
      await insertLegacyFixedCostExpense(
        db,
        id: 1,
        fixedCostId: 1,
        fixedCostCategoryId: 1,
        date: '20250501',
        name: '家賃',
        price: 3000,
        isConfirmed: 1,
      );
      await insertLegacyFixedCostExpense(
        db,
        id: 2,
        fixedCostId: 1,
        fixedCostCategoryId: 1,
        date: '20250601',
        name: '家賃',
        price: 4000,
        isConfirmed: 1,
      );
      await insertLegacyFixedCostExpense(
        db,
        id: 3,
        fixedCostId: 2,
        fixedCostCategoryId: 4,
        date: '20250525',
        name: '電気代',
      );
      await insertLegacyFixedCostExpense(
        db,
        id: 4,
        fixedCostId: 2,
        fixedCostCategoryId: 4,
        date: '20250625',
        name: '電気代',
      );

      await DataBaseMigrate().toV10(db);

      final rows = await migratedRows(db);
      expect(rows, hasLength(4));
      final confirmed = rows.where((r) => r[SqfExpense.isConfirmed] == 1);
      final unconfirmed = rows.where((r) => r[SqfExpense.isConfirmed] == 0);
      expect(confirmed, hasLength(2));
      expect(unconfirmed, hasLength(2));
      expect(
        confirmed.fold<int>(0, (sum, r) => sum + (r[SqfExpense.price] as int)),
        7000,
      );
      // 未確定の合計はマスタ推定額の合計と一致する
      expect(
        unconfirmed.fold<int>(
          0,
          (sum, r) => sum + (r[SqfExpense.estimatedPrice] as int),
        ),
        13000,
      );
    });

    test('fixed_cost_idがNULLの旧行は名称＋カテゴリーでマスタへ再突合される', () async {
      // v6経由の端末に残る紐付け欠落行の救済（仕様 §5 手順3）
      final db = await createV9ShapeDatabase();
      await insertFixedCostMaster(db, id: 7, name: 'ネット回線', fixedCostCategoryId: 3);
      await insertLegacyFixedCostExpense(
        db,
        id: 1,
        fixedCostCategoryId: 3,
        date: '20250601',
        name: 'ネット回線',
        price: 4400,
        isConfirmed: 1,
      );

      await DataBaseMigrate().toV10(db);

      final row = (await db.query(SqfExpense.tableName)).single;
      expect(row[SqfExpense.fixedCostId], 7);
      expect(row[SqfExpense.price], 4400);
      expect(
        row[SqfExpense.expenseSmallCategoryId],
        await movedSmallCategoryId(db, '通信費'),
      );
    });

    test('再突合できない旧行はfixed_cost_id=NULLの通常支出として移行される（金額は失わない）', () async {
      final db = await createV9ShapeDatabase();
      await insertLegacyFixedCostExpense(
        db,
        id: 1,
        fixedCostCategoryId: 2,
        date: '20250601',
        name: '解約済みサブスク',
        price: 980,
        isConfirmed: 1,
      );

      await DataBaseMigrate().toV10(db);

      final row = (await db.query(SqfExpense.tableName)).single;
      expect(row[SqfExpense.fixedCostId], isNull);
      expect(row[SqfExpense.price], 980);
      expect(row[SqfExpense.isConfirmed], 1);
      // カテゴリーは旧カテゴリーの移設先へ寄せる
      expect(
        row[SqfExpense.expenseSmallCategoryId],
        await movedSmallCategoryId(db, 'サブスク'),
      );
    });

    test('T2以降にexpenseへ直接生成された行と同じ固定費・日付の旧行はスキップする', () async {
      // 中間状態で新旧両方に同じ実績があると二重計上になる（仕様 §5 手順3）。
      // 「expense側に固定費行が既にある状態で旧実績が残っている」形を、
      // 1回目の移行で作ってから旧テーブルを復活させて再現する。
      final db = await createV9ShapeDatabase();
      await insertFixedCostMaster(db, id: 1, name: '家賃', fixedCostCategoryId: 1);
      await insertLegacyFixedCostExpense(
        db,
        id: 1,
        fixedCostId: 1,
        fixedCostCategoryId: 1,
        date: '20250601',
        name: '家賃',
        price: 80000,
        isConfirmed: 1,
      );
      await DataBaseMigrate().toV10(db);
      // ここまでで expense に 6/1 の固定費行が1件ある

      // 旧テーブルだけが残っている中断残骸を作り、6/1（重複）と7/1（新規）を置く
      await db.execute(_createFixedCostExpenseMigrated);
      await insertLegacyFixedCostExpense(
        db,
        id: 1,
        fixedCostId: 1,
        fixedCostCategoryId: 1,
        date: '20250601',
        name: '家賃',
        price: 80000,
        isConfirmed: 1,
      );
      await insertLegacyFixedCostExpense(
        db,
        id: 2,
        fixedCostId: 1,
        fixedCostCategoryId: 1,
        date: '20250701',
        name: '家賃',
        price: 80000,
        isConfirmed: 1,
      );

      await DataBaseMigrate().toV10(db);

      final rows = await db.query(SqfExpense.tableName, orderBy: SqfExpense.date);
      // 6/1は既にあるのでスキップされ、7/1だけが増える
      expect(rows, hasLength(2));
      expect(rows.map((r) => r[SqfExpense.date]).toList(), [
        '20250601',
        '20250701',
      ]);
    });

    test('旧2テーブルはDROPされ、fixed_costから旧カテゴリー列が消える', () async {
      final db = await createV9ShapeDatabase();
      await insertFixedCostMaster(db, id: 1, name: '家賃', fixedCostCategoryId: 1);

      await DataBaseMigrate().toV10(db);

      final tables =
          (await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type = 'table'",
          )).map((row) => row['name'] as String).toSet();
      expect(tables.contains(SqfFixedCostExpense.tableName), isFalse);
      expect(tables.contains(SqfFixedCostCategory.tableName), isFalse);

      final columns = await _columnNames(db, SqfFixedCost.tableName);
      expect(columns.contains(_legacyFixedCostCategoryIdColumn), isFalse);
      // マスタの中身は保全される
      final master = (await db.query(SqfFixedCost.tableName)).single;
      expect(master[SqfFixedCost.id], 1);
      expect(master[SqfFixedCost.name], '家賃');
      expect(master[SqfFixedCost.price], 1000);
      expect(
        master[SqfFixedCost.expenseSmallCategoryId],
        await movedSmallCategoryId(db, '住居費'),
      );
    });

    test('実績移行を含めて2回連続実行しても二重移行にならない（冪等）', () async {
      final db = await createV9ShapeDatabase();
      await insertFixedCostMaster(db, id: 1, name: '家賃', fixedCostCategoryId: 1);
      await insertLegacyFixedCostExpense(
        db,
        id: 1,
        fixedCostId: 1,
        fixedCostCategoryId: 1,
        date: '20250601',
        name: '家賃',
        price: 80000,
        isConfirmed: 1,
      );

      await DataBaseMigrate().toV10(db);
      final afterFirst = await db.query(
        SqfExpense.tableName,
        orderBy: SqfExpense.id,
      );

      await DataBaseMigrate().toV10(db);

      expect(
        await db.query(SqfExpense.tableName, orderBy: SqfExpense.id),
        afterFirst,
      );
    });

    test('toV10単体ではestimated_price_is_manualは追加されない（列追加はv11の責務）', () async {
      final db = await createV9ShapeDatabase();
      await insertFixedCostMaster(db, id: 1, name: '家賃', fixedCostCategoryId: 1);

      await DataBaseMigrate().toV10(db);

      final columns = await _columnNames(db, SqfFixedCost.tableName);
      expect(columns.contains(SqfFixedCost.estimatedPriceIsManual), isFalse);
    });

    // v10 は先行の TestFlight で配信済みだったため、列追加は v11 として切り直した。
    // v10 適用済み（列なし）の端末で toV11 が列を足せることがこのテストの主眼。
    test('v10適用済みDBにtoV11でestimated_price_is_manualが追加され、既定値は0になる', () async {
      final db = await createV9ShapeDatabase();
      await insertFixedCostMaster(db, id: 1, name: '家賃', fixedCostCategoryId: 1);

      await DataBaseMigrate().toV10(db);
      await DataBaseMigrate().toV11(db);

      final columns = await _columnNames(db, SqfFixedCost.tableName);
      expect(columns.contains(SqfFixedCost.estimatedPriceIsManual), isTrue);
      // 既存マスタは全て自動算出（0）として扱う（仕様 §6.9）
      final master = (await db.query(SqfFixedCost.tableName)).single;
      expect(master[SqfFixedCost.estimatedPriceIsManual], 0);
    });

    test('toV11は2回実行しても壊れない（冪等）', () async {
      final db = await createV9ShapeDatabase();
      await insertFixedCostMaster(db, id: 1, name: '家賃', fixedCostCategoryId: 1);

      await DataBaseMigrate().toV10(db);
      await DataBaseMigrate().toV11(db);
      // 手動設定を入れてから再実行し、値が保たれることまで見る
      await db.update(
        SqfFixedCost.tableName,
        {SqfFixedCost.estimatedPriceIsManual: 1},
        where: '${SqfFixedCost.id} = ?',
        whereArgs: [1],
      );

      await DataBaseMigrate().toV11(db);

      final master = (await db.query(SqfFixedCost.tableName)).single;
      expect(master[SqfFixedCost.estimatedPriceIsManual], 1);
    });

    test('中断残骸（fixed_cost_v10_new）が残っていても成功する', () async {
      final db = await createV9ShapeDatabase();
      await insertFixedCostMaster(db, id: 1, name: '家賃', fixedCostCategoryId: 1);
      await db.execute('CREATE TABLE fixed_cost_v10_new (dummy INTEGER);');

      await DataBaseMigrate().toV10(db);

      final columns = await _columnNames(db, SqfFixedCost.tableName);
      expect(columns.contains(_legacyFixedCostCategoryIdColumn), isFalse);
      expect((await db.query(SqfFixedCost.tableName)).single[SqfFixedCost.name], '家賃');
    });

  group('toV12: 変動固定費の0円確定行の修復', () {
    /// v11 適用済みの状態を作り、変動型マスタ(id=1)と実績行を入れる
    Future<Database> createV11Database() async {
      final db = await createV9ShapeDatabase();
      await db.execute('''
        INSERT INTO fixed_cost
          (_id, name, variable, price, estimated_price, fixed_cost_category_id, interval_number, interval_unit, first_payment_date, recent_payment_date, next_payment_date, delete_flag)
        VALUES (1, '電気代', 1, 0, 55, 1, 1, 1, '20250125', NULL, '20250225', 0);
      ''');
      await DataBaseMigrate().toV10(db);
      await DataBaseMigrate().toV11(db);
      return db;
    }

    Future<void> insertRow(
      Database db, {
      required int id,
      required String date,
      required int? price,
      required int isConfirmed,
      int? estimatedPrice,
      int fixedCostId = 1,
    }) async {
      await db.insert(SqfExpense.tableName, {
        SqfExpense.id: id,
        SqfExpense.expenseSmallCategoryId: 1,
        SqfExpense.date: date,
        SqfExpense.price: price,
        SqfExpense.memo: '電気代',
        SqfExpense.incomeSourceBigCategory: 1,
        SqfExpense.fixedCostId: fixedCostId,
        SqfExpense.isConfirmed: isConfirmed,
        SqfExpense.estimatedPrice: estimatedPrice,
      });
    }

    test('変動型の「確定扱い・0円」行は未確定に戻り、予想額は確定行(price>0)の平均で引き直される', () async {
      final db = await createV11Database();
      // 0円の確定扱い行（旧データ由来）×3、本当の確定行 2,200 ×1
      await insertRow(db, id: 101, date: '20250210', price: 0, isConfirmed: 1);
      await insertRow(db, id: 102, date: '20250310', price: 0, isConfirmed: 1);
      await insertRow(db, id: 103, date: '20250410', price: 0, isConfirmed: 1);
      await insertRow(db, id: 104, date: '20250510', price: 2200, isConfirmed: 1);
      // もともと未確定の行（破損した 55 が同期されている）
      await insertRow(db, id: 105, date: '20250610', price: null, isConfirmed: 0, estimatedPrice: 55);

      await DataBaseMigrate().toV12(db);

      final rows = await db.query(SqfExpense.tableName, orderBy: SqfExpense.id);
      final byId = {for (final r in rows) r[SqfExpense.id] as int: r};
      for (final id in [101, 102, 103]) {
        expect(byId[id]![SqfExpense.isConfirmed], 0, reason: '$id は未確定に戻る');
        expect(byId[id]![SqfExpense.price], isNull);
        expect(byId[id]![SqfExpense.estimatedPrice], 2200, reason: '$id の予想額は引き直し後の値');
      }
      // 本当の確定行は触らない
      expect(byId[104]![SqfExpense.isConfirmed], 1);
      expect(byId[104]![SqfExpense.price], 2200);
      // 未確定行の予想額も同期される
      expect(byId[105]![SqfExpense.estimatedPrice], 2200);
      // マスタの予想額は 55 → 2200
      final master = (await db.query(SqfFixedCost.tableName)).single;
      expect(master[SqfFixedCost.estimatedPrice], 2200);
    });

    test('確定行(price>0)が無いマスタは予想額の現在値を保持する', () async {
      final db = await createV11Database();
      await insertRow(db, id: 101, date: '20250210', price: 0, isConfirmed: 1);

      await DataBaseMigrate().toV12(db);

      final master = (await db.query(SqfFixedCost.tableName)).single;
      expect(master[SqfFixedCost.estimatedPrice], 55);
      final row = (await db.query(SqfExpense.tableName)).single;
      expect(row[SqfExpense.isConfirmed], 0);
      expect(row[SqfExpense.estimatedPrice], 55);
    });

    test('手動設定のマスタは予想額を引き直さない', () async {
      final db = await createV11Database();
      await db.update(SqfFixedCost.tableName, {SqfFixedCost.estimatedPriceIsManual: 1});
      await insertRow(db, id: 104, date: '20250510', price: 2200, isConfirmed: 1);

      await DataBaseMigrate().toV12(db);

      final master = (await db.query(SqfFixedCost.tableName)).single;
      expect(master[SqfFixedCost.estimatedPrice], 55);
    });

    test('確定型マスタの0円確定行は対象外', () async {
      final db = await createV11Database();
      await db.update(SqfFixedCost.tableName, {SqfFixedCost.variable: 0});
      await insertRow(db, id: 101, date: '20250210', price: 0, isConfirmed: 1);

      await DataBaseMigrate().toV12(db);

      final row = (await db.query(SqfExpense.tableName)).single;
      expect(row[SqfExpense.isConfirmed], 1);
    });

    test('2回実行しても結果が変わらない（冪等）', () async {
      final db = await createV11Database();
      await insertRow(db, id: 101, date: '20250210', price: 0, isConfirmed: 1);
      await insertRow(db, id: 104, date: '20250510', price: 2200, isConfirmed: 1);

      await DataBaseMigrate().toV12(db);
      final first = await db.query(SqfExpense.tableName, orderBy: SqfExpense.id);
      final firstMaster = await db.query(SqfFixedCost.tableName);
      await DataBaseMigrate().toV12(db);

      expect(await db.query(SqfExpense.tableName, orderBy: SqfExpense.id), first);
      expect(await db.query(SqfFixedCost.tableName), firstMaster);
    });
  });
  });

  // -------------------------------------------------------------------------
  // マイグレーションチェーン（本番のonUpgrade経路）
  // -------------------------------------------------------------------------
  group('マイグレーションチェーン v6 → v10', () {
    /// v6形状のDBファイルを DatabaseHelper のパスに作って閉じる
    ///
    /// テーブル定義はv6時点のもの（fixed_costはタイポ列 /
    /// fixed_cost_expenseはfixed_cost_id無し）。
    Future<void> createV6DatabaseFile(String path) async {
      final db = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 6,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE expense (
                _id INTEGER PRIMARY KEY AUTOINCREMENT,
                expense_small_category_id INTEGER NOT NULL,
                date TEXT NOT NULL,
                price INTEGER NOT NULL,
                memo TEXT,
                income_source_big_category INTEGER NOT NULL
              );
            ''');
            await db.execute('''
              CREATE TABLE income (
                _id INTEGER PRIMARY KEY AUTOINCREMENT,
                income_small_category_id INTEGER NOT NULL,
                date TEXT NOT NULL,
                price INTEGER NOT NULL,
                memo TEXT
              );
            ''');
            await db.execute('''
              CREATE TABLE budget (
                _id INTEGER PRIMARY KEY AUTOINCREMENT,
                expense_big_category_id INTEGER NOT NULL,
                month TEXT NOT NULL,
                price INTEGER
              );
            ''');
            await db.execute('''
              CREATE TABLE expense_big_category (
                _id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                color_code TEXT NOT NULL,
                resource_path TEXT NOT NULL,
                display_order INTEGER NOT NULL,
                is_displayed INTEGER NOT NULL
              );
            ''');
            // v7以前の色コード（出典: 90ea5e2^ 時点の sql_on_create.dart）
            await db.execute('''
              INSERT INTO expense_big_category (name, color_code, resource_path, display_order, is_displayed)
              VALUES('食費', 'FF7070', 'assets/images/icon_meal.svg', 0, 1),
                    ('日用品', '21D19F', 'assets/images/icon_commodity.svg', 1, 1),
                    ('遊び娯楽', 'ED112B', 'assets/images/icon_favo.svg', 2, 1),
                    ('交通費', '2596FF', 'assets/images/icon_transportation.svg', 3, 1),
                    ('衣服美容', 'FFC857', 'assets/images/icon_clothes.svg', 4, 1),
                    ('医療費', 'B118C8', 'assets/images/icon_medical.svg', 5, 1),
                    ('雑費', '3E2F5B', 'assets/images/icon_others.svg', 6, 1);
            ''');
            // v6当時から存在するテーブル（出典: 90ea5e2^ 時点の sql_on_create.dart）。
            // v10のカテゴリー移設先になるためチェーン検証に必要
            await db.execute('''
              CREATE TABLE expense_small_category (
                _id INTEGER PRIMARY KEY AUTOINCREMENT,
                big_category_key INTEGER NOT NULL,
                name TEXT NOT NULL,
                small_category_order_key INTEGER NOT NULL,
                displayed_order_in_big INTEGER NOT NULL,
                default_displayed INTEGER NOT NULL
              );
            ''');
            await db.execute('''
              INSERT INTO expense_small_category (big_category_key, name, small_category_order_key, displayed_order_in_big, default_displayed)
              VALUES(1, '食費', 0, 0, 1),
                    (2, '消耗品', 1, 0, 1),
                    (3, '遊び', 2, 0, 1),
                    (4, '交通費', 3, 0, 1),
                    (5, 'カット', 4, 0, 1),
                    (6, '医療費', 5, 0, 1),
                    (7, 'その他', 6, 0, 1);
            ''');
            await db.execute('''
              CREATE TABLE income_big_category (
                _id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                color_code TEXT NOT NULL,
                resource_path TEXT NOT NULL
              );
            ''');
            await db.execute('''
              INSERT INTO income_big_category (name, color_code, resource_path)
              VALUES ('月次収入', 'FFC857', 'assets/images/icon_regular_income.svg'),
                     ('ボーナス', 'ECB22D', 'assets/images/icon_extra_income.svg');
            ''');
            // 出典: sql_on_update.dart の toV6（カテゴリー順もv6当時のまま）
            await db.execute('''
              CREATE TABLE fixed_cost_category (
                _id INTEGER PRIMARY KEY AUTOINCREMENT,
                category_name TEXT NOT NULL,
                color_code TEXT NOT NULL,
                resource_path TEXT NOT NULL,
                display_order INTEGER NOT NULL,
                is_displayed INTEGER NOT NULL
              );
            ''');
            await db.execute('''
              INSERT INTO fixed_cost_category (category_name, color_code, resource_path, display_order, is_displayed)
              VALUES ('住居費', 'FF5722', 'assets/images/icon_home.svg', 0, 1),
                     ('通信費', '2196F3', 'assets/images/icon_phone.svg', 1, 1),
                     ('サブスク', '9C27B0', 'assets/images/icon_subscription.svg', 2, 1),
                     ('光熱費', 'FFC107', 'assets/images/icon_utility.svg', 3, 1),
                     ('その他', '607D8B', 'assets/images/icon_others.svg', 4, 1);
            ''');
            await db.execute('''
              CREATE TABLE batch_history (
                _id INTEGER PRIMARY KEY AUTOINCREMENT,
                start_date TEXT NOT NULL,
                end_date TEXT NOT NULL,
                status INTEGER NOT NULL
              );
            ''');
            await db.execute(_createFixedCostWithTypo);
            await db.execute(_createFixedCostExpenseWithoutFixedCostId);
            await db.execute('''
              INSERT INTO fixed_cost
                (name, variable, price, estimated_price, fixed_cost_category_id, interval_number, interval_unit, fiirst_payment_date, recent_payment_date, next_payment_date, delete_flag)
              VALUES ('ネット回線', 0, 4400, NULL, 2, 1, 1, '20241225', NULL, '20250125', 0);
            ''');
            await db.execute('''
              INSERT INTO fixed_cost_expense
                (fixed_cost_category_id, date, price, name, confirmed_cost_type, is_confirmed)
              VALUES (2, '20250125', 4400, 'ネット回線', 0, 1);
            ''');
          },
        ),
      );
      await db.close();
    }

    test('v6形状のDBを開くとonUpgradeでv7〜v12が順に適用されuser_versionが12になる', () async {
      final path = await currentDatabasePath();
      await createV6DatabaseFile(path);

      // 本番と同じ経路（DatabaseHelper.instance.database）で開く
      final db = await openTestDatabase();

      final rows = await db.rawQuery('PRAGMA user_version');
      expect(rows.first.values.first, 12);
      // v11 の列追加まで到達していること
      final columns = await _columnNames(db, SqfFixedCost.tableName);
      expect(columns.contains(SqfFixedCost.estimatedPriceIsManual), isTrue);
    });

    test('チェーン適用後はv7の色更新とv8の列追加・バックフィルとv10の統合が反映される', () async {
      final path = await currentDatabasePath();
      await createV6DatabaseFile(path);

      final db = await openTestDatabase();

      // v7: 色が現行パレットへ
      final bigCategories = await db.query(
        SqfExpenseBigCategory.tableName,
        orderBy: SqfExpenseBigCategory.id,
      );
      expect(
        bigCategories.first[SqfExpenseBigCategory.colorCode],
        CategoryPalette.expense1Hex,
      );
      // v7で統一した固定費カテゴリーの色は、v10の移設先大カテゴリーへ引き継がれる
      final movedCategories = await db.query(
        SqfExpenseBigCategory.tableName,
        where: '${SqfExpenseBigCategory.displayOrder} >= ?',
        whereArgs: [7],
      );
      expect(movedCategories, hasLength(5));
      for (final row in movedCategories) {
        expect(
          row[SqfExpenseBigCategory.colorCode],
          CategoryPalette.fixedCostHex,
        );
      }

      // v8: タイポ列の改名と fixed_cost_id の追加・バックフィル
      final fixedCostColumns = await _columnNames(db, SqfFixedCost.tableName);
      expect(fixedCostColumns.contains(SqfFixedCost.firstPaymentDate), isTrue);
      expect(fixedCostColumns.contains('fiirst_payment_date'), isFalse);

      // v8でバックフィルした fixed_cost_id を保ったまま v10 で expense へ移行される
      final migrated = await db.query(SqfExpense.tableName);
      expect(migrated, hasLength(1));
      expect(migrated[0][SqfExpense.fixedCostId], 1);
      expect(migrated[0][SqfExpense.price], 4400);
      expect(migrated[0][SqfExpense.memo], 'ネット回線');
      expect(migrated[0][SqfExpense.isConfirmed], 1);

      // v9: 会計種別の追加と既定値の付与
      final incomeBigCategories = await db.query(
        SqfIncomeBigCategory.tableName,
        orderBy: SqfIncomeBigCategory.id,
      );
      expect(incomeBigCategories[0][SqfIncomeBigCategory.accountType], 1);
      expect(incomeBigCategories[1][SqfIncomeBigCategory.accountType], 2);

      // v10: expenseの列追加と、固定費カテゴリーの支出カテゴリーへの移設
      final expenseColumns = await _columnNames(db, SqfExpense.tableName);
      expect(expenseColumns.contains(SqfExpense.fixedCostId), isTrue);
      expect(expenseColumns.contains(SqfExpense.isConfirmed), isTrue);
      expect(expenseColumns.contains(SqfExpense.estimatedPrice), isTrue);

      // v6フィクスチャの支出大カテゴリー7件＋固定費カテゴリー5件
      expect(
        await DatabaseHelper.instance.queryRowCount(
          SqfExpenseBigCategory.tableName,
        ),
        12,
      );
      // fixed_cost（1件）が移設先の小カテゴリーを参照している
      final fixedCosts = await db.query(SqfFixedCost.tableName);
      expect(fixedCosts, hasLength(1));
      expect(fixedCosts.first[SqfFixedCost.expenseSmallCategoryId], isNot(0));

      // 旧2テーブルはDROP済み
      final tables =
          (await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type = 'table'",
          )).map((row) => row['name'] as String).toSet();
      expect(tables.contains(SqfFixedCostExpense.tableName), isFalse);
      expect(tables.contains(SqfFixedCostCategory.tableName), isFalse);
    });
  });
}
