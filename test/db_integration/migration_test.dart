// マイグレーション（sql_on_update.dart）のDB結合テスト
//
// 旧形状のDBを実際に作ってから本物のマイグレーションを流し、
// 「列構成がどう変わるか・データが引き継がれるか」を仕様として固定する。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/sql_on_update.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/theme/category_palette.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helper/db_test_helper.dart';

// ---------------------------------------------------------------------------
// 旧形状のDDL（歴史上のスキーマなので、現在の定数ではなく当時の字面をそのまま置く）
// ---------------------------------------------------------------------------

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
      expect(rows.map((row) => row[SqfExpenseBigCategory.colorCode]).toList(), [
        CategoryPalette.expense1Hex,
        CategoryPalette.expense2Hex,
        CategoryPalette.expense3Hex,
        CategoryPalette.expense4Hex,
        CategoryPalette.expense5Hex,
        CategoryPalette.expense6Hex,
        CategoryPalette.expense7Hex,
      ]);
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
  // マイグレーションチェーン（本番のonUpgrade経路）
  // -------------------------------------------------------------------------
  group('マイグレーションチェーン v6 → v9', () {
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

    test('v6形状のDBを開くとonUpgradeでv7・v8・v9が順に適用されuser_versionが9になる', () async {
      final path = await currentDatabasePath();
      await createV6DatabaseFile(path);

      // 本番と同じ経路（DatabaseHelper.instance.database）で開く
      final db = await openTestDatabase();

      final rows = await db.rawQuery('PRAGMA user_version');
      expect(rows.first.values.first, 9);
    });

    test('チェーン適用後はv7の色更新とv8の列追加・バックフィルが両方反映される', () async {
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
      final fixedCostCategories = await db.query(
        SqfFixedCostCategory.tableName,
      );
      for (final row in fixedCostCategories) {
        expect(
          row[SqfFixedCostCategory.colorCode],
          CategoryPalette.fixedCostHex,
        );
      }

      // v8: タイポ列の改名と fixed_cost_id の追加・バックフィル
      final fixedCostColumns = await _columnNames(db, SqfFixedCost.tableName);
      expect(fixedCostColumns.contains(SqfFixedCost.firstPaymentDate), isTrue);
      expect(fixedCostColumns.contains('fiirst_payment_date'), isFalse);

      final expenses = await db.query(SqfFixedCostExpense.tableName);
      expect(expenses.length, 1);
      expect(expenses[0][SqfFixedCostExpense.fixedCostId], 1);

      // v9: 会計種別の追加と既定値の付与
      final incomeBigCategories = await db.query(
        SqfIncomeBigCategory.tableName,
        orderBy: SqfIncomeBigCategory.id,
      );
      expect(incomeBigCategories[0][SqfIncomeBigCategory.accountType], 1);
      expect(incomeBigCategories[1][SqfIncomeBigCategory.accountType], 2);
    });
  });
}
