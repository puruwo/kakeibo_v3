// ImplementsExpenseRepository のDB結合テスト
//
// 本物のSQLを sqflite_common_ffi 上で実行し、WHERE条件・ORDER BY・
// 日付境界（yyyyMMdd文字列比較）の挙動を仕様として固定する。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/repository/expense_repository.dart';

import '../../helper/db_test_helper.dart';

/// 基準シナリオの集計期間（開始日25日設定で 2025/7/6 を選んだときの期間）
final _period = PeriodValue(
  startDatetime: DateTime(2025, 6, 25),
  endDatetime: DateTime(2025, 7, 24),
);

/// 期間境界・拠出元・小カテゴリーを一度に検証できる標準フィクスチャ
///
/// | id | 日付       | 位置        | 拠出元 | 小カテゴリー | 金額 |
/// |----|------------|-------------|--------|--------------|------|
/// | 1  | 2025-06-24 | 期間開始前日 | 給与   | 1            | 1    |
/// | 2  | 2025-06-25 | 期間開始日   | 給与   | 1            | 100  |
/// | 3  | 2025-07-01 | 期間中       | 給与   | 2            | 200  |
/// | 4  | 2025-07-01 | 期間中(同日) | ボーナス | 2          | 300  |
/// | 5  | 2025-07-24 | 期間終了日   | 給与   | 3            | 400  |
/// | 6  | 2025-07-25 | 期間終了翌日 | 給与   | 1            | 2    |
Future<void> _seedStandardExpenses() async {
  await insertExpenseRow(id: 1, date: '20250624', price: 1, smallCategoryId: 1);
  await insertExpenseRow(
    id: 2,
    date: '20250625',
    price: 100,
    smallCategoryId: 1,
  );
  await insertExpenseRow(
    id: 3,
    date: '20250701',
    price: 200,
    smallCategoryId: 2,
  );
  await insertExpenseRow(
    id: 4,
    date: '20250701',
    price: 300,
    smallCategoryId: 2,
    incomeSourceBigCategory: 2,
  );
  await insertExpenseRow(
    id: 5,
    date: '20250724',
    price: 400,
    smallCategoryId: 3,
  );
  await insertExpenseRow(id: 6, date: '20250725', price: 2, smallCategoryId: 1);
}

void main() {
  setUpDbTestEnvironment();

  final repository = ImplementsExpenseRepository();

  group('fetchAll', () {
    test('全ての支出をid昇順で返す', () async {
      await _seedStandardExpenses();

      final results = await repository.fetchAll();

      expect(results.map((e) => e.id).toList(), [1, 2, 3, 4, 5, 6]);
    });

    test('期間・拠出元・カテゴリーで絞り込まず全件返す', () async {
      await _seedStandardExpenses();

      final results = await repository.fetchAll();

      // 期間外(id=1,6)もボーナス拠出(id=4)も含まれる
      expect(results.length, 6);
      expect(results.map((e) => e.price).toList(), [1, 100, 200, 300, 400, 2]);
    });

    test('1件も無いなら空リストを返す', () async {
      final results = await repository.fetchAll();

      expect(results, isEmpty);
    });

    test('memoと拠出元がエンティティへ正しくマッピングされる', () async {
      await insertExpenseRow(
        id: 1,
        date: '20250701',
        price: 1234,
        smallCategoryId: 7,
        memo: 'ラーメン',
        incomeSourceBigCategory: 2,
      );

      final results = await repository.fetchAll();

      expect(
        results.single,
        const ExpenseEntity(
          id: 1,
          date: '20250701',
          price: 1234,
          paymentCategoryId: 7,
          memo: 'ラーメン',
          incomeSourceBigCategory: 2,
        ),
      );
    });
  });

  group('fetchWithSourceCategory', () {
    test('期間内かつ指定拠出元の支出だけをid降順で返す', () async {
      await _seedStandardExpenses();

      final results = await repository.fetchWithSourceCategory(
        incomeSourceBigId: 1,
        period: _period,
      );

      // ORDER BY _id DESC
      expect(results.map((e) => e.id).toList(), [5, 3, 2]);
    });

    test('期間開始日ちょうどの支出を含む（date >= 開始日）', () async {
      await _seedStandardExpenses();

      final results = await repository.fetchWithSourceCategory(
        incomeSourceBigId: 1,
        period: _period,
      );

      expect(results.map((e) => e.date), contains('20250625'));
    });

    test('期間終了日ちょうどの支出を含む（date <= 終了日）', () async {
      await _seedStandardExpenses();

      final results = await repository.fetchWithSourceCategory(
        incomeSourceBigId: 1,
        period: _period,
      );

      expect(results.map((e) => e.date), contains('20250724'));
    });

    test('期間開始前日・期間終了翌日の支出は含まない', () async {
      await _seedStandardExpenses();

      final results = await repository.fetchWithSourceCategory(
        incomeSourceBigId: 1,
        period: _period,
      );

      expect(results.map((e) => e.date), isNot(contains('20250624')));
      expect(results.map((e) => e.date), isNot(contains('20250725')));
    });

    test('指定と違う拠出元の支出は含まない', () async {
      await _seedStandardExpenses();

      final results = await repository.fetchWithSourceCategory(
        incomeSourceBigId: 2,
        period: _period,
      );

      // ボーナス拠出は id=4 だけ
      expect(results.map((e) => e.id).toList(), [4]);
    });

    test('年跨ぎの期間（12/25〜1/24）でも取得できる', () async {
      await insertExpenseRow(id: 1, date: '20241224', price: 1);
      await insertExpenseRow(id: 2, date: '20241225', price: 100);
      await insertExpenseRow(id: 3, date: '20250101', price: 200);
      await insertExpenseRow(id: 4, date: '20250124', price: 300);
      await insertExpenseRow(id: 5, date: '20250125', price: 2);

      final results = await repository.fetchWithSourceCategory(
        incomeSourceBigId: 1,
        period: PeriodValue(
          startDatetime: DateTime(2024, 12, 25),
          endDatetime: DateTime(2025, 1, 24),
        ),
      );

      expect(results.map((e) => e.id).toList(), [4, 3, 2]);
    });

    test('該当が無いなら空リストを返す', () async {
      await _seedStandardExpenses();

      final results = await repository.fetchWithSourceCategory(
        incomeSourceBigId: 1,
        period: PeriodValue(
          startDatetime: DateTime(2020, 1, 1),
          endDatetime: DateTime(2020, 1, 31),
        ),
      );

      expect(results, isEmpty);
    });
  });

  group('fetchWithSmallCategory', () {
    test('期間・拠出元・小カテゴリーの3条件すべてに一致する支出をid降順で返す', () async {
      await _seedStandardExpenses();
      // 同じ小カテゴリー2・給与拠出の支出を期間内にもう1件足して降順を確かめる
      await insertExpenseRow(
        id: 7,
        date: '20250710',
        price: 500,
        smallCategoryId: 2,
      );

      final results = await repository.fetchWithSmallCategory(
        incomeSourceBigId: 1,
        period: _period,
        smallCategoryId: 2,
      );

      expect(results.map((e) => e.id).toList(), [7, 3]);
    });

    test('小カテゴリーが違う支出は含まない', () async {
      await _seedStandardExpenses();

      final results = await repository.fetchWithSmallCategory(
        incomeSourceBigId: 1,
        period: _period,
        smallCategoryId: 3,
      );

      // 小カテゴリー3は id=5 だけ
      expect(results.map((e) => e.id).toList(), [5]);
    });

    test('小カテゴリーが一致しても拠出元が違えば含まない', () async {
      await _seedStandardExpenses();

      final results = await repository.fetchWithSmallCategory(
        incomeSourceBigId: 1,
        period: _period,
        smallCategoryId: 2,
      );

      // id=4 は小カテゴリー2だがボーナス拠出なので除外される
      expect(results.map((e) => e.id).toList(), [3]);
    });

    test('該当が無いなら空リストを返す', () async {
      await _seedStandardExpenses();

      final results = await repository.fetchWithSmallCategory(
        incomeSourceBigId: 1,
        period: _period,
        smallCategoryId: 99,
      );

      expect(results, isEmpty);
    });
  });

  group('fetchTotalExpenseByPeriod', () {
    test('期間内の支出を拠出元に関係なく合計する', () async {
      await _seedStandardExpenses();

      final total = await repository.fetchTotalExpenseByPeriod(
        fromDate: DateTime(2025, 6, 25),
        toDate: DateTime(2025, 7, 24),
      );

      // 100 + 200 + 300(ボーナス拠出) + 400
      expect(total, 1000);
    });

    test('開始日・終了日ちょうどの支出を合計に含む', () async {
      await insertExpenseRow(id: 1, date: '20250625', price: 100);
      await insertExpenseRow(id: 2, date: '20250724', price: 400);

      final total = await repository.fetchTotalExpenseByPeriod(
        fromDate: DateTime(2025, 6, 25),
        toDate: DateTime(2025, 7, 24),
      );

      expect(total, 500);
    });

    test('期間外の支出は合計しない', () async {
      await _seedStandardExpenses();

      final total = await repository.fetchTotalExpenseByPeriod(
        fromDate: DateTime(2025, 6, 26),
        toDate: DateTime(2025, 7, 23),
      );

      // 期間開始日(100)と終了日(400)を外すと 200 + 300
      expect(total, 500);
    });

    test('該当が無いならCOALESCEで0を返す', () async {
      final total = await repository.fetchTotalExpenseByPeriod(
        fromDate: DateTime(2025, 6, 25),
        toDate: DateTime(2025, 7, 24),
      );

      expect(total, 0);
    });
  });

  group('fetchTotalExpenseByPeriodWithBigCategory', () {
    test('指定した拠出元大カテゴリーの支出だけを合計する', () async {
      await _seedStandardExpenses();

      final total = await repository.fetchTotalExpenseByPeriodWithBigCategory(
        incomeSourceBigCategory: 1,
        fromDate: DateTime(2025, 6, 25),
        toDate: DateTime(2025, 7, 24),
      );

      // 100 + 200 + 400（ボーナス拠出の300は除外）
      expect(total, 700);
    });

    test('別の拠出元を指定するとその分だけを合計する', () async {
      await _seedStandardExpenses();

      final total = await repository.fetchTotalExpenseByPeriodWithBigCategory(
        incomeSourceBigCategory: 2,
        fromDate: DateTime(2025, 6, 25),
        toDate: DateTime(2025, 7, 24),
      );

      expect(total, 300);
    });

    test('開始日・終了日ちょうどを含み、期間外は合計しない', () async {
      await _seedStandardExpenses();

      final total = await repository.fetchTotalExpenseByPeriodWithBigCategory(
        incomeSourceBigCategory: 1,
        fromDate: DateTime(2025, 6, 25),
        toDate: DateTime(2025, 6, 25),
      );

      // 期間開始日の100だけ（前日の1は含まない）
      expect(total, 100);
    });

    test('該当が無いならCOALESCEで0を返す', () async {
      await _seedStandardExpenses();

      final total = await repository.fetchTotalExpenseByPeriodWithBigCategory(
        incomeSourceBigCategory: 99,
        fromDate: DateTime(2025, 6, 25),
        toDate: DateTime(2025, 7, 24),
      );

      expect(total, 0);
    });
  });

  group('fetchTotalExpenseByPeriodWithSmallCategoryAndSource', () {
    test('拠出元と小カテゴリーの両方に一致する支出だけを合計する', () async {
      await _seedStandardExpenses();
      await insertExpenseRow(
        id: 7,
        date: '20250710',
        price: 500,
        smallCategoryId: 2,
      );

      final total = await repository
          .fetchTotalExpenseByPeriodWithSmallCategoryAndSource(
            incomeSourceBigCategory: 1,
            smallCategoryId: 2,
            fromDate: DateTime(2025, 6, 25),
            toDate: DateTime(2025, 7, 24),
          );

      // 200 + 500（id=4は小カテゴリー2だがボーナス拠出なので除外）
      expect(total, 700);
    });

    test('小カテゴリーだけ一致する支出は合計しない', () async {
      await _seedStandardExpenses();

      final total = await repository
          .fetchTotalExpenseByPeriodWithSmallCategoryAndSource(
            incomeSourceBigCategory: 2,
            smallCategoryId: 2,
            fromDate: DateTime(2025, 6, 25),
            toDate: DateTime(2025, 7, 24),
          );

      // ボーナス拠出かつ小カテゴリー2は id=4 だけ
      expect(total, 300);
    });

    test('該当が無いならCOALESCEで0を返す', () async {
      await _seedStandardExpenses();

      final total = await repository
          .fetchTotalExpenseByPeriodWithSmallCategoryAndSource(
            incomeSourceBigCategory: 1,
            smallCategoryId: 99,
            fromDate: DateTime(2025, 6, 25),
            toDate: DateTime(2025, 7, 24),
          );

      expect(total, 0);
    });
  });

  group('fetchDailyExpenseByPeriod', () {
    test('指定日かつ給与拠出の支出だけを合計する', () async {
      await _seedStandardExpenses();

      final total = await repository.fetchDailyExpenseByPeriod(
        date: DateTime(2025, 7, 1),
      );

      // 同日にはid=3(給与200)とid=4(ボーナス300)があるが給与分のみ
      expect(total, 200);
    });

    test('同じ日の給与拠出が複数あれば合算する', () async {
      await insertExpenseRow(id: 1, date: '20250701', price: 200);
      await insertExpenseRow(id: 2, date: '20250701', price: 350);

      final total = await repository.fetchDailyExpenseByPeriod(
        date: DateTime(2025, 7, 1),
      );

      expect(total, 550);
    });

    test('前日・翌日の支出は合計しない', () async {
      await insertExpenseRow(id: 1, date: '20250630', price: 100);
      await insertExpenseRow(id: 2, date: '20250701', price: 200);
      await insertExpenseRow(id: 3, date: '20250702', price: 300);

      final total = await repository.fetchDailyExpenseByPeriod(
        date: DateTime(2025, 7, 1),
      );

      expect(total, 200);
    });

    test('その日にボーナス拠出しか無いなら0を返す', () async {
      await insertExpenseRow(
        id: 1,
        date: '20250701',
        price: 300,
        incomeSourceBigCategory: 2,
      );

      final total = await repository.fetchDailyExpenseByPeriod(
        date: DateTime(2025, 7, 1),
      );

      // GROUP BY の結果が0行になるため0
      expect(total, 0);
    });

    test('その日に支出が無いなら0を返す', () async {
      final total = await repository.fetchDailyExpenseByPeriod(
        date: DateTime(2025, 7, 1),
      );

      expect(total, 0);
    });
  });

  group('fetchDailyExpenseListByDate', () {
    test('指定日かつ給与拠出の支出だけをid昇順で返す', () async {
      await insertExpenseRow(id: 10, date: '20250701', price: 200);
      await insertExpenseRow(id: 20, date: '20250701', price: 350);
      await insertExpenseRow(
        id: 30,
        date: '20250701',
        price: 300,
        incomeSourceBigCategory: 2,
      );
      await insertExpenseRow(id: 40, date: '20250702', price: 400);

      final results = await repository.fetchDailyExpenseListByDate(
        date: DateTime(2025, 7, 1),
      );

      expect(results.map((e) => e.id).toList(), [10, 20]);
    });

    test('その日に給与拠出の支出が無いなら空リストを返す', () async {
      await insertExpenseRow(
        id: 1,
        date: '20250701',
        price: 300,
        incomeSourceBigCategory: 2,
      );

      final results = await repository.fetchDailyExpenseListByDate(
        date: DateTime(2025, 7, 1),
      );

      expect(results, isEmpty);
    });
  });

  group('insert', () {
    test('1件追加され、指定した値がそのまま保存される', () async {
      repository.insert(
        const ExpenseEntity(
          date: '20250701',
          price: 1500,
          paymentCategoryId: 3,
          memo: '外食',
          incomeSourceBigCategory: 1,
        ),
      );
      await waitUntilRowCount(SqfExpense.tableName, 1);

      final results = await repository.fetchAll();
      expect(results.single.date, '20250701');
      expect(results.single.price, 1500);
      expect(results.single.paymentCategoryId, 3);
      expect(results.single.memo, '外食');
      expect(results.single.incomeSourceBigCategory, 1);
    });

    test('idはエンティティの値ではなくAUTOINCREMENTで採番される', () async {
      // ExpenseEntity.id の既定値は1だが、insert時のカラムには渡していない
      await insertExpenseRow(id: 50, date: '20250601', price: 10);

      repository.insert(
        const ExpenseEntity(id: 1, date: '20250701', price: 20),
      );
      await waitUntilRowCount(SqfExpense.tableName, 2);

      final results = await repository.fetchAll();
      expect(results.map((e) => e.id).toList(), [50, 51]);
    });

    test('memoが空文字でも保存できる', () async {
      repository.insert(
        const ExpenseEntity(date: '20250701', price: 100, memo: ''),
      );
      await waitUntilRowCount(SqfExpense.tableName, 1);

      final results = await repository.fetchAll();
      expect(results.single.memo, '');
    });
  });

  group('update', () {
    test('指定idの行だけが書き換わる', () async {
      await _seedStandardExpenses();

      repository.update(
        const ExpenseEntity(
          id: 3,
          date: '20250705',
          price: 999,
          paymentCategoryId: 5,
          memo: '修正後',
          incomeSourceBigCategory: 2,
        ),
      );
      await settleDbWrites();
      await waitUntil(() async {
        final rows = await DatabaseHelper.instance.queryRowsWhere(
          SqfExpense.tableName,
          '${SqfExpense.id} = ?',
          [3],
        );
        return rows.first[SqfExpense.price] == 999;
      }, description: 'id=3の支出が更新されること');

      final results = await repository.fetchAll();
      final updated = results.firstWhere((e) => e.id == 3);
      expect(updated.date, '20250705');
      expect(updated.price, 999);
      expect(updated.paymentCategoryId, 5);
      expect(updated.memo, '修正後');
      expect(updated.incomeSourceBigCategory, 2);

      // 他の行は変化しない
      expect(results.firstWhere((e) => e.id == 2).price, 100);
      expect(results.firstWhere((e) => e.id == 5).price, 400);
      expect(results.length, 6);
    });

    test('存在しないidを指定しても他の行は変わらない', () async {
      await _seedStandardExpenses();

      repository.update(
        const ExpenseEntity(id: 999, date: '20250705', price: 1),
      );
      await settleDbWrites();

      final results = await repository.fetchAll();
      expect(results.length, 6);
      expect(results.map((e) => e.price).toList(), [1, 100, 200, 300, 400, 2]);
    });
  });

  group('delete', () {
    test('指定idの行だけが削除される', () async {
      await _seedStandardExpenses();

      repository.delete(3);
      await waitUntilRowCount(SqfExpense.tableName, 5);

      final results = await repository.fetchAll();
      expect(results.map((e) => e.id).toList(), [1, 2, 4, 5, 6]);
    });

    test('存在しないidを指定しても何も削除されない', () async {
      await _seedStandardExpenses();

      repository.delete(999);
      await settleDbWrites();

      expect(
        await DatabaseHelper.instance.queryRowCount(SqfExpense.tableName),
        6,
      );
    });
  });

  // ---------------------------------------------------------------------
  // 固定費系のクエリ（v10で fixed_cost_record から移管）
  // ---------------------------------------------------------------------

  /// 固定費マスタ10・20に紐づく実績と通常支出を混在させた標準フィクスチャ
  ///
  /// | id | 固定費 | 日付       | 確定 | 実額  | 予想額 |
  /// |----|-------|------------|------|-------|--------|
  /// | 10 | 10    | 2025-06-25 | 1    | 6000  | NULL   |
  /// | 11 | 10    | 2025-07-01 | 1    | 8000  | 5000   |
  /// | 12 | 10    | 2025-07-10 | 0    | NULL  | 5000   |
  /// | 13 | 20    | 2025-07-10 | 0    | NULL  | 3000   |
  /// | 14 | NULL  | 2025-07-10 | 1    | 999   | NULL   |
  Future<void> seedFixedCostRows() async {
    await insertExpenseRow(
      id: 10,
      date: '20250625',
      price: 6000,
      fixedCostId: 10,
    );
    await insertExpenseRow(
      id: 11,
      date: '20250701',
      price: 8000,
      fixedCostId: 10,
      estimatedPrice: 5000,
    );
    await insertExpenseRow(
      id: 12,
      date: '20250710',
      price: null,
      fixedCostId: 10,
      isConfirmed: 0,
      estimatedPrice: 5000,
    );
    await insertExpenseRow(
      id: 13,
      date: '20250710',
      price: null,
      fixedCostId: 20,
      isConfirmed: 0,
      estimatedPrice: 3000,
    );
    // 固定費に紐づかない通常支出（どのクエリの対象にもならない）
    await insertExpenseRow(id: 14, date: '20250710', price: 999);
  }

  group('fetchById', () {
    test('指定idの行を返す', () async {
      await seedFixedCostRows();

      final result = await repository.fetchById(id: 12);

      expect(result?.id, 12);
      expect(result?.price, isNull);
      expect(result?.isConfirmed, 0);
      expect(result?.estimatedPrice, 5000);
    });

    test('存在しないidならnullを返す', () async {
      await seedFixedCostRows();

      expect(await repository.fetchById(id: 999), isNull);
    });
  });

  group('insertFixedCostRecord', () {
    test('固定費列つきで挿入され、採番されたidが返る', () async {
      final id = await repository.insertFixedCostRecord(
        const ExpenseEntity(
          date: '20250710',
          price: null,
          paymentCategoryId: 2,
          memo: '電気代',
          fixedCostId: 10,
          isConfirmed: 0,
          estimatedPrice: 5000,
        ),
      );

      final inserted = await repository.fetchById(id: id);
      expect(inserted?.fixedCostId, 10);
      expect(inserted?.isConfirmed, 0);
      // 実額はNULLのまま保存される（price NULL許容化。仕様 §4.1）
      expect(inserted?.price, isNull);
      expect(inserted?.estimatedPrice, 5000);
      expect(inserted?.memo, '電気代');
    });
  });

  group('existsByFixedCostIdAndDate', () {
    test('固定費IDと支払い日が一致する行があればtrue', () async {
      await seedFixedCostRows();

      expect(
        await repository.existsByFixedCostIdAndDate(
          fixedCostId: 10,
          date: '20250701',
        ),
        isTrue,
      );
    });

    test('日付が一致しなければfalse', () async {
      await seedFixedCostRows();

      expect(
        await repository.existsByFixedCostIdAndDate(
          fixedCostId: 10,
          date: '20250702',
        ),
        isFalse,
      );
    });

    test('別マスタの同じ日付は重複とみなさない', () async {
      await seedFixedCostRows();

      expect(
        await repository.existsByFixedCostIdAndDate(
          fixedCostId: 30,
          date: '20250710',
        ),
        isFalse,
      );
    });
  });

  group('fetchUnconfirmedFixedCostRecordByPeriod', () {
    test('期間内の未確定の固定費行だけを返す', () async {
      await seedFixedCostRows();

      final results = await repository
          .fetchUnconfirmedFixedCostRecordByPeriod(period: _period);

      // 確定行(10,11)・通常支出(14)は含まれない
      expect(results.map((e) => e.id).toList()..sort(), [12, 13]);
    });

    test('期間外の未確定行は含まれない', () async {
      await insertExpenseRow(
        id: 20,
        date: '20250725',
        price: null,
        fixedCostId: 10,
        isConfirmed: 0,
        estimatedPrice: 5000,
      );

      final results = await repository
          .fetchUnconfirmedFixedCostRecordByPeriod(period: _period);

      expect(results, isEmpty);
    });
  });

  group('confirmFixedCostRecord', () {
    test('実額が入りis_confirmedが1になる（予想額は残る）', () async {
      await seedFixedCostRows();

      await repository.confirmFixedCostRecord(id: 12, price: 7200);

      final row = await repository.fetchById(id: 12);
      expect(row?.price, 7200);
      expect(row?.isConfirmed, 1);
      // 予実の乖離を行に残すため予想額は消さない（仕様 §3）
      expect(row?.estimatedPrice, 5000);
    });
  });

  group('fetchConfirmedFixedCostPriceAverage', () {
    test('確定行の実額の平均を返す', () async {
      await seedFixedCostRows();

      // 6000と8000の平均
      expect(
        await repository.fetchConfirmedFixedCostPriceAverage(fixedCostId: 10),
        7000,
      );
    });

    test('確定行が0件ならnullを返す', () async {
      // 未確定行しか無いマスタ20。nullは「更新しない」の判定に使う（仕様 §6.5）
      await seedFixedCostRows();

      expect(
        await repository.fetchConfirmedFixedCostPriceAverage(fixedCostId: 20),
        isNull,
      );
    });

    test('該当マスタが無い場合もnullを返す', () async {
      await seedFixedCostRows();

      expect(
        await repository.fetchConfirmedFixedCostPriceAverage(fixedCostId: 999),
        isNull,
      );
    });
  });

  group('updateEstimatedPriceOfUnconfirmedRows', () {
    test('同じマスタの未確定行だけ予想額が更新される', () async {
      await seedFixedCostRows();

      await repository.updateEstimatedPriceOfUnconfirmedRows(
        fixedCostId: 10,
        estimatedPrice: 7000,
      );

      expect((await repository.fetchById(id: 12))?.estimatedPrice, 7000);
      // 確定行は据え置き（予実の記録なので上書きしない）
      expect((await repository.fetchById(id: 11))?.estimatedPrice, 5000);
      // 別マスタの未確定行も据え置き
      expect((await repository.fetchById(id: 13))?.estimatedPrice, 3000);
    });

    test('実額priceには書き込まない', () async {
      await seedFixedCostRows();

      await repository.updateEstimatedPriceOfUnconfirmedRows(
        fixedCostId: 10,
        estimatedPrice: 7000,
      );

      expect((await repository.fetchById(id: 12))?.price, isNull);
      expect((await repository.fetchById(id: 11))?.price, 8000);
    });
  });

  group('deleteUnpaidFixedCostRecords', () {
    // 運用日付。この日を境に「支払日が到来済みか」を判定する
    const today = '20250706';

    test('未確定行と支払日未到来の確定行だけが消える', () async {
      await seedFixedCostRows();
      // 支払日未到来の確定行（消える）
      await insertExpenseRow(
        id: 15,
        date: '20250707',
        price: 6000,
        fixedCostId: 10,
      );
      // 運用日付ちょうどの確定行（境界値・残る）
      await insertExpenseRow(
        id: 16,
        date: '20250706',
        price: 6000,
        fixedCostId: 10,
      );

      await repository.deleteUnpaidFixedCostRecords(
        fixedCostId: 10,
        today: today,
      );

      final results = await repository.fetchAll();
      // 10・11（到来済みの確定行）と16（当日）が残り、別マスタ13・通常支出14も残る
      expect(results.map((e) => e.id).toList(), [10, 11, 13, 14, 16]);
    });

    test('残った確定行のfixed_cost_idは保持される', () async {
      // 通常支出化しない（マスタは論理削除のため参照は切れない。仕様 §6.4）
      await seedFixedCostRows();

      await repository.deleteUnpaidFixedCostRecords(
        fixedCostId: 10,
        today: today,
      );

      expect((await repository.fetchById(id: 10))?.fixedCostId, 10);
    });
  });

  group('updateSmallCategoryByFixedCostId', () {
    test('同じマスタの行だけカテゴリーが一括変更される', () async {
      await seedFixedCostRows();

      await repository.updateSmallCategoryByFixedCostId(
        fixedCostId: 10,
        expenseSmallCategoryId: 7,
      );

      final results = await repository.fetchAll();
      expect(
        results.map((e) => e.paymentCategoryId).toList(),
        // id順 10,11,12（変更）／13,14（据え置き＝フィクスチャ既定の1）
        [7, 7, 7, 1, 1],
      );
    });
  });

  group('fetchByFixedCostId', () {
    test('指定マスタの行だけを日付降順（同日はid降順）で返す', () async {
      await seedFixedCostRows();
      // 10と同じ日付の行を足して、同日の並び（id降順）を確定させる
      await insertExpenseRow(
        id: 15,
        date: '20250710',
        price: 7000,
        fixedCostId: 10,
      );

      final results = await repository.fetchByFixedCostId(
        fixedCostId: 10,
        limit: 10,
      );

      // 固定費20の行(13)と通常支出(14)は含まない
      expect(results.map((e) => e.id).toList(), [15, 12, 11, 10]);
    });

    test('limitで件数が絞られる（新しい順に切り取られる）', () async {
      await seedFixedCostRows();

      final results = await repository.fetchByFixedCostId(
        fixedCostId: 10,
        limit: 2,
      );

      expect(results.map((e) => e.id).toList(), [12, 11]);
    });

    test('未確定行はpriceがNULLのまま返り、予想額を保持する', () async {
      await seedFixedCostRows();

      final results = await repository.fetchByFixedCostId(
        fixedCostId: 10,
        limit: 10,
      );

      final unconfirmed = results.firstWhere((e) => e.id == 12);
      expect(unconfirmed.price, isNull);
      expect(unconfirmed.isConfirmed, 0);
      expect(unconfirmed.estimatedPrice, 5000);
    });

    test('該当する実績が無ければ空リストを返す', () async {
      await seedFixedCostRows();

      final results = await repository.fetchByFixedCostId(
        fixedCostId: 999,
        limit: 10,
      );

      expect(results, isEmpty);
    });
  });
}
