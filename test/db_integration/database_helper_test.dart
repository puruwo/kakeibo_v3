// DatabaseHelper（onCreate + 汎用メソッド）のDB結合テスト
//
// 本物のDDL（sql_on_create.dart）を sqflite_common_ffi 上で実行し、
// 「新規インストール直後のDBがどうなっているか」を仕様として固定する。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/theme/category_palette.dart';

import '../helper/db_test_helper.dart';

void main() {
  setUpDbTestEnvironment();

  group('onCreate: テーブル構成', () {
    test('全テーブルがonCreateで作成される', () async {
      final db = await openTestDatabase();
      final rows = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
      );
      final tableNames = rows.map((row) => row['name'] as String).toSet();

      expect(
        tableNames,
        containsAll(<String>[
          SqfExpense.tableName,
          SqfIncome.tableName,
          SqfBudget.tableName,
          SqfExpenseBigCategory.tableName,
          SqfExpenseSmallCategory.tableName,
          SqfIncomeBigCategory.tableName,
          SqfIncomeSmallCategory.tableName,
          SqfFixedCost.tableName,
          SqfBatchHistory.tableName,
        ]),
      );
    });

    test('新規作成直後のスキーマバージョンは10になる', () async {
      final db = await openTestDatabase();
      // DatabaseHelper._databaseVersion と一致していること
      final rows = await db.rawQuery('PRAGMA user_version');
      expect(rows.first.values.first, 10);
    });

    test('income_big_categoryは会計種別を持ち、月次収入=1・ボーナス=2で作成される', () async {
      // ADR-025: onCreate初期データの会計種別（1=生活収支, 2=特別枠）
      final db = await openTestDatabase();
      final rows = await db.query(
        SqfIncomeBigCategory.tableName,
        orderBy: SqfIncomeBigCategory.id,
      );
      expect(rows, hasLength(2));
      expect(rows[0][SqfIncomeBigCategory.accountType], 1);
      expect(rows[1][SqfIncomeBigCategory.accountType], 2);
    });
  });

  group('onCreate: カテゴリーマスタのシード', () {
    test('支出大カテゴリーは12件で、名前・色・表示順がパレット定義どおりになる', () async {
      final rows = await DatabaseHelper.instance.query(
        'SELECT * FROM ${SqfExpenseBigCategory.tableName} '
        'ORDER BY ${SqfExpenseBigCategory.id} ASC',
      );

      // v10（固定費カテゴリー統合）で固定費由来の5件が末尾に加わり12件になった
      expect(rows.length, 12);

      // 色は CategoryPalette の6桁HEX定数と照合する（DB側はalpha無しの6桁）
      final expected = <List<Object>>[
        ['食費', CategoryPalette.expense1Hex, 0],
        ['日用品', CategoryPalette.expense2Hex, 1],
        ['遊び娯楽', CategoryPalette.expense3Hex, 2],
        ['交通費', CategoryPalette.expense4Hex, 3],
        ['衣服美容', CategoryPalette.expense5Hex, 4],
        ['医療費', CategoryPalette.expense6Hex, 5],
        ['雑費', CategoryPalette.expense7Hex, 6],
        // 固定費由来（色は固定費色で統一。「その他」だけ名前が「固定費その他」）
        ['住居費', CategoryPalette.fixedCostHex, 7],
        ['サブスク', CategoryPalette.fixedCostHex, 8],
        ['通信費', CategoryPalette.fixedCostHex, 9],
        ['光熱費', CategoryPalette.fixedCostHex, 10],
        [
          FixedCostDerivedCategoryConstants.freshInstallFallbackCategoryName,
          CategoryPalette.fixedCostHex,
          11,
        ],
      ];
      for (var i = 0; i < expected.length; i++) {
        expect(rows[i][SqfExpenseBigCategory.id], i + 1);
        expect(rows[i][SqfExpenseBigCategory.name], expected[i][0]);
        expect(rows[i][SqfExpenseBigCategory.colorCode], expected[i][1]);
        expect(rows[i][SqfExpenseBigCategory.displayOrder], expected[i][2]);
        expect(rows[i][SqfExpenseBigCategory.isDisplayed], 1);
      }
    });

    test('支出小カテゴリーは20件で、それぞれ想定の大カテゴリーに紐付く', () async {
      final rows = await DatabaseHelper.instance.query(
        'SELECT * FROM ${SqfExpenseSmallCategory.tableName} '
        'ORDER BY ${SqfExpenseSmallCategory.id} ASC',
      );

      // v10（固定費カテゴリー統合）で固定費由来の5件が末尾に加わり20件になった
      expect(rows.length, 20);

      // 大カテゴリーキー（1:食費 2:日用品 3:遊び娯楽 4:交通費 5:衣服美容 6:医療費 7:雑費
      //                 8:住居費 9:サブスク 10:通信費 11:光熱費 12:固定費その他）
      const expectedBigKeys = [
        1, 1, 1, 1, 2, 2, 3, 3, 3, 3, 4, 4, 5, 6, 7, //
        8, 9, 10, 11, 12,
      ];
      const expectedNames = [
        '食費',
        'コンビニ',
        '外食',
        '社食',
        '消耗品',
        '雑貨',
        '遊び',
        '飲み',
        'ライブ',
        'ご褒美',
        '交通費',
        '帰省',
        'カット',
        '医療費',
        'その他',
        // 固定費由来（大カテゴリーと同名の小カテゴリーを1件ずつ）
        '住居費',
        'サブスク',
        '通信費',
        '光熱費',
        FixedCostDerivedCategoryConstants.freshInstallFallbackCategoryName,
      ];
      for (var i = 0; i < rows.length; i++) {
        expect(rows[i][SqfExpenseSmallCategory.id], i + 1);
        expect(rows[i][SqfExpenseSmallCategory.name], expectedNames[i]);
        expect(
          rows[i][SqfExpenseSmallCategory.bigCategoryKey],
          expectedBigKeys[i],
        );
        // 通番は0始まりの連番、既定表示はすべてON
        expect(rows[i][SqfExpenseSmallCategory.smallCategoryOrderKey], i);
        expect(rows[i][SqfExpenseSmallCategory.defaultDisplayed], 1);
      }
    });

    test('収入大カテゴリーは2件で、色がパレット定義どおりになる', () async {
      final rows = await DatabaseHelper.instance.query(
        'SELECT * FROM ${SqfIncomeBigCategory.tableName} '
        'ORDER BY ${SqfIncomeBigCategory.id} ASC',
      );

      expect(rows.length, 2);
      expect(rows[0][SqfIncomeBigCategory.name], '月次収入');
      expect(
        rows[0][SqfIncomeBigCategory.colorCode],
        CategoryPalette.income1Hex,
      );
      expect(rows[1][SqfIncomeBigCategory.name], 'ボーナス');
      expect(
        rows[1][SqfIncomeBigCategory.colorCode],
        CategoryPalette.income2Hex,
      );
    });

    test('収入小カテゴリーは4件で、ボーナスだけが大カテゴリー2に紐付く', () async {
      final rows = await DatabaseHelper.instance.query(
        'SELECT * FROM ${SqfIncomeSmallCategory.tableName} '
        'ORDER BY ${SqfIncomeSmallCategory.id} ASC',
      );

      expect(rows.length, 4);
      // 給与・小遣い・臨時収入は「月次収入(1)」、ボーナスだけ「ボーナス(2)」
      expect(rows[0][SqfIncomeSmallCategory.name], '給与');
      expect(rows[0][SqfIncomeSmallCategory.bigCategoryKey], 1);
      expect(rows[1][SqfIncomeSmallCategory.name], 'ボーナス');
      expect(rows[1][SqfIncomeSmallCategory.bigCategoryKey], 2);
      expect(rows[2][SqfIncomeSmallCategory.name], '小遣い');
      expect(rows[2][SqfIncomeSmallCategory.bigCategoryKey], 1);
      expect(rows[3][SqfIncomeSmallCategory.name], '臨時収入');
      expect(rows[3][SqfIncomeSmallCategory.bigCategoryKey], 1);
    });


    test('batch_historyの初期レコードは「インストール日を含む集計期間の開始日前日」1件になる', () async {
      final rows = await DatabaseHelper.instance.query(
        'SELECT * FROM ${SqfBatchHistory.tableName}',
      );

      expect(rows.length, 1);

      // sql_on_create.dart と同じ式で期待値を組み立てる
      // （初回起動時点の集計開始日は必ず既定値25日）
      const defaultAggregationStartDay = 25;
      final now = DateTime.now();
      final currentPeriodStart = now.day >= defaultAggregationStartDay
          ? DateTime(now.year, now.month, defaultAggregationStartDay)
          : DateTime(now.year, now.month - 1, defaultAggregationStartDay);
      final expectedDate = currentPeriodStart.subtract(const Duration(days: 1));
      final expected =
          '${expectedDate.year.toString().padLeft(4, '0')}'
          '${expectedDate.month.toString().padLeft(2, '0')}'
          '${expectedDate.day.toString().padLeft(2, '0')}';

      expect(rows[0][SqfBatchHistory.startDate], expected);
      expect(rows[0][SqfBatchHistory.endDate], expected);
      // status=1 は「実行済み」
      expect(rows[0][SqfBatchHistory.status], 1);
    });
  });

  group('onCreate: DebugSeeder無効時', () {
    test('取引系テーブルは全て0件になる', () async {
      // flutter test は kDebugMode = true のため、DebugSeeder.enabled を
      // 切らないとモックデータが約1500行入る。切れていることの回帰検知。
      expect(
        await DatabaseHelper.instance.queryRowCount(SqfExpense.tableName),
        0,
      );
      expect(
        await DatabaseHelper.instance.queryRowCount(SqfIncome.tableName),
        0,
      );
    });

    test('予算・固定費マスタも0件になる', () async {
      expect(
        await DatabaseHelper.instance.queryRowCount(SqfBudget.tableName),
        0,
      );
      expect(
        await DatabaseHelper.instance.queryRowCount(SqfFixedCost.tableName),
        0,
      );
    });
  });

  group('deleteDatabaseFile', () {
    test('削除後に再アクセスするとonCreateが走り、シードが復活し追加データは消える', () async {
      // 追加データを1件入れてから削除する
      await insertExpenseRow(date: '20250701', price: 1000);
      expect(
        await DatabaseHelper.instance.queryRowCount(SqfExpense.tableName),
        1,
      );

      await DatabaseHelper.instance.deleteDatabaseFile();

      // 次のアクセスでonCreateから再作成される
      expect(
        await DatabaseHelper.instance.queryRowCount(SqfExpense.tableName),
        0,
      );
      expect(
        await DatabaseHelper.instance.queryRowCount(
          SqfExpenseBigCategory.tableName,
        ),
        12,
      );
    });
  });

  group('汎用メソッド', () {
    test('insertは採番されたIDを返し、queryRowsで読み出せる', () async {
      final id = await DatabaseHelper.instance.insert(SqfExpense.tableName, {
        SqfExpense.expenseSmallCategoryId: 3,
        SqfExpense.date: '20250701',
        SqfExpense.price: 1234,
        SqfExpense.memo: 'ラーメン',
        SqfExpense.incomeSourceBigCategory: 1,
      });

      expect(id, 1); // AUTOINCREMENTの1件目

      final rows = await DatabaseHelper.instance.queryRows(
        SqfExpense.tableName,
      );
      expect(rows.length, 1);
      expect(rows[0][SqfExpense.price], 1234);
      expect(rows[0][SqfExpense.memo], 'ラーメン');
    });

    test('queryRowsWhereは条件に一致する行だけを返す', () async {
      await insertExpenseRow(date: '20250701', price: 100);
      await insertExpenseRow(date: '20250702', price: 200);

      final rows = await DatabaseHelper.instance.queryRowsWhere(
        SqfExpense.tableName,
        '${SqfExpense.date} = ?',
        ['20250702'],
      );

      expect(rows.length, 1);
      expect(rows[0][SqfExpense.price], 200);
    });

    test('queryRowCountはテーブルの行数を返す', () async {
      await insertExpenseRow(date: '20250701', price: 100);
      await insertExpenseRow(date: '20250702', price: 200);
      await insertExpenseRow(date: '20250703', price: 300);

      expect(
        await DatabaseHelper.instance.queryRowCount(SqfExpense.tableName),
        3,
      );
    });

    test('updateは_id指定の行だけを書き換える', () async {
      final targetId = await insertExpenseRow(date: '20250701', price: 100);
      final otherId = await insertExpenseRow(date: '20250702', price: 200);

      final updatedCount = await DatabaseHelper.instance.update(
        SqfExpense.tableName,
        {SqfExpense.price: 999},
        targetId,
      );

      expect(updatedCount, 1);
      final rows = await DatabaseHelper.instance.queryRows(
        SqfExpense.tableName,
      );
      expect(
        rows.firstWhere((r) => r[SqfExpense.id] == targetId)[SqfExpense.price],
        999,
      );
      expect(
        rows.firstWhere((r) => r[SqfExpense.id] == otherId)[SqfExpense.price],
        200,
      );
    });

    test('deleteは_id指定の行だけを消す', () async {
      final targetId = await insertExpenseRow(date: '20250701', price: 100);
      await insertExpenseRow(date: '20250702', price: 200);

      final deletedCount = await DatabaseHelper.instance.delete(
        SqfExpense.tableName,
        targetId,
      );

      expect(deletedCount, 1);
      final rows = await DatabaseHelper.instance.queryRows(
        SqfExpense.tableName,
      );
      expect(rows.length, 1);
      expect(rows[0][SqfExpense.price], 200);
    });

    test('hasDataはEXISTSの結果が1ならtrue・0ならfalseを返す', () async {
      final id = await insertExpenseRow(date: '20250701', price: 100);

      expect(
        await DatabaseHelper.instance.hasData(
          'SELECT EXISTS(SELECT 1 FROM ${SqfExpense.tableName} WHERE ${SqfExpense.id}=$id)',
        ),
        isTrue,
      );
      expect(
        await DatabaseHelper.instance.hasData(
          'SELECT EXISTS(SELECT 1 FROM ${SqfExpense.tableName} WHERE ${SqfExpense.id}=9999)',
        ),
        isFalse,
      );
    });

    test('queryとqueryFirstIntValueは生SQLの結果を返す', () async {
      await insertExpenseRow(date: '20250701', price: 100);
      await insertExpenseRow(date: '20250702', price: 250);

      final rows = await DatabaseHelper.instance.query(
        'SELECT ${SqfExpense.price} AS price FROM ${SqfExpense.tableName} '
        'ORDER BY ${SqfExpense.id} ASC',
      );
      expect(rows.map((r) => r['price']).toList(), [100, 250]);

      final total = await DatabaseHelper.instance.queryFirstIntValue(
        'SELECT SUM(${SqfExpense.price}) FROM ${SqfExpense.tableName}',
      );
      expect(total, 350);
    });
  });
}
