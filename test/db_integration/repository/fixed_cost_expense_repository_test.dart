// ImplementsFixedCostExpenseRepository のDB結合テスト
//
// 固定費支出は「確定（is_confirmed=1）はpriceを、未確定は紐づくfixed_costの
// estimated_priceを使う」という二重の金額源を持つ。どのSQLがどちらを見ているかを固定する。
// confirmExpense は「確定操作でIDを取り違える／awaitが漏れる」系の本番バグの最終防衛線なので、
// 対象行の更新内容と他行が不変であることの両方を張る。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_entity.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/repository/fixed_cost_expense_repository.dart';

import '../../helper/db_test_helper.dart';

/// 基準シナリオの集計期間（開始日25日設定で 2025/7/6 を選んだときの期間）
final _period = PeriodValue(
  startDatetime: DateTime(2025, 6, 25),
  endDatetime: DateTime(2025, 7, 24),
);

/// 固定費マスタ（estimated_price の参照元）
///
/// | id | 名前     | カテゴリー | 推定額 |
/// |----|----------|-----------|--------|
/// | 10 | 家賃     | 1         | 1500   |
/// | 20 | サブスク  | 2         | 2500   |
/// | 30 | 電気代   | 2         | 3500   |
/// | 40 | 水道代   | 3         | 4500   |
Future<void> _seedFixedCostMasters() async {
  await insertFixedCostRow(
    id: 10,
    name: '家賃',
    fixedCostCategoryId: 1,
    price: 80000,
    estimatedPrice: 1500,
  );
  await insertFixedCostRow(
    id: 20,
    name: 'サブスク',
    fixedCostCategoryId: 2,
    price: 1000,
    estimatedPrice: 2500,
  );
  await insertFixedCostRow(
    id: 30,
    name: '電気代',
    fixedCostCategoryId: 2,
    variable: 1,
    estimatedPrice: 3500,
  );
  await insertFixedCostRow(
    id: 40,
    name: '水道代',
    fixedCostCategoryId: 3,
    variable: 1,
    estimatedPrice: 4500,
  );
}

/// 期間境界・確定状態・カテゴリーを一度に検証できる標準フィクスチャ
///
/// | id | 固定費ID | カテゴリー | 日付       | 位置          | 金額 | 確定 |
/// |----|---------|-----------|------------|---------------|------|------|
/// | 1  | 10      | 1         | 2025-06-24 | 期間開始前日   | 1000 | 1    |
/// | 2  | 10      | 1         | 2025-06-25 | 期間開始日     | 2000 | 1    |
/// | 3  | 20      | 2         | 2025-07-01 | 期間中         | 3000 | 1    |
/// | 4  | 30      | 2         | 2025-07-10 | 期間中         | 0    | 0    |
/// | 5  | 40      | 3         | 2025-07-24 | 期間終了日     | 5000 | 1    |
/// | 6  | 10      | 1         | 2025-07-25 | 期間終了翌日   | 6000 | 1    |
Future<void> _seedStandardFixedCostExpenses() async {
  await insertFixedCostExpenseRow(
    id: 1,
    fixedCostId: 10,
    fixedCostCategoryId: 1,
    date: '20250624',
    price: 1000,
    name: '家賃',
    isConfirmed: 1,
  );
  await insertFixedCostExpenseRow(
    id: 2,
    fixedCostId: 10,
    fixedCostCategoryId: 1,
    date: '20250625',
    price: 2000,
    name: '家賃',
    isConfirmed: 1,
  );
  await insertFixedCostExpenseRow(
    id: 3,
    fixedCostId: 20,
    fixedCostCategoryId: 2,
    date: '20250701',
    price: 3000,
    name: 'サブスク',
    isConfirmed: 1,
  );
  await insertFixedCostExpenseRow(
    id: 4,
    fixedCostId: 30,
    fixedCostCategoryId: 2,
    date: '20250710',
    price: 0,
    name: '電気代',
    confirmedCostType: 1,
    isConfirmed: 0,
  );
  await insertFixedCostExpenseRow(
    id: 5,
    fixedCostId: 40,
    fixedCostCategoryId: 3,
    date: '20250724',
    price: 5000,
    name: '水道代',
    isConfirmed: 1,
  );
  await insertFixedCostExpenseRow(
    id: 6,
    fixedCostId: 10,
    fixedCostCategoryId: 1,
    date: '20250725',
    price: 6000,
    name: '家賃',
    isConfirmed: 1,
  );
}

/// ORDER BYが無いクエリ用。id昇順に並べ替えてから比較する
List<int> _sortedIds(List<FixedCostExpenseEntity> list) =>
    list.map((e) => e.id).toList()..sort();

void main() {
  setUpDbTestEnvironment();

  final repository = ImplementsFixedCostExpenseRepository();

  group('insert', () {
    test('1件追加され、採番されたidと保存値が一致する', () async {
      final id = await repository.insert(
        const FixedCostExpenseEntity(
          fixedCostId: 10,
          fixedCostCategoryId: 1,
          date: '20250701',
          price: 80000,
          name: '家賃',
          confirmedCostType: 0,
          isConfirmed: 1,
        ),
      );

      final results = await repository.fetchAll();
      expect(
        results.single,
        FixedCostExpenseEntity(
          id: id,
          fixedCostId: 10,
          fixedCostCategoryId: 1,
          date: '20250701',
          price: 80000,
          name: '家賃',
          confirmedCostType: 0,
          isConfirmed: 1,
        ),
      );
    });

    test('idはエンティティの値ではなくAUTOINCREMENTで採番される', () async {
      await insertFixedCostExpenseRow(
        id: 50,
        fixedCostId: 10,
        fixedCostCategoryId: 1,
        date: '20250601',
        price: 100,
        name: '既存',
      );

      final id = await repository.insert(
        const FixedCostExpenseEntity(
          id: 1,
          fixedCostId: 10,
          fixedCostCategoryId: 1,
          date: '20250701',
          price: 200,
          name: '新規',
        ),
      );

      expect(id, 51);
    });
  });

  group('fetchAll', () {
    test('期間・確定状態で絞らず全件返す', () async {
      await _seedStandardFixedCostExpenses();

      final results = await repository.fetchAll();

      // ORDER BYが無いので順序は保証されない。集合として比較する
      expect(_sortedIds(results), [1, 2, 3, 4, 5, 6]);
    });

    test('1件も無いなら空リストを返す', () async {
      final results = await repository.fetchAll();

      expect(results, isEmpty);
    });

    test('全カラムがエンティティへ正しくマッピングされる', () async {
      await insertFixedCostExpenseRow(
        id: 1,
        fixedCostId: 30,
        fixedCostCategoryId: 2,
        date: '20250710',
        price: 7800,
        name: '電気代',
        confirmedCostType: 1,
        isConfirmed: 0,
      );

      final results = await repository.fetchAll();

      expect(
        results.single,
        const FixedCostExpenseEntity(
          id: 1,
          fixedCostId: 30,
          fixedCostCategoryId: 2,
          date: '20250710',
          price: 7800,
          name: '電気代',
          confirmedCostType: 1,
          isConfirmed: 0,
        ),
      );
    });
  });

  group('fetchByPeriod', () {
    test('期間内の固定費支出を日付降順で返す', () async {
      await _seedStandardFixedCostExpenses();

      final results = await repository.fetchByPeriod(period: _period);

      // ORDER BY date DESC。未確定(id=4)も含まれる
      expect(results.map((e) => e.id).toList(), [5, 4, 3, 2]);
    });

    test('期間開始日ちょうど・期間終了日ちょうどを含む', () async {
      await _seedStandardFixedCostExpenses();

      final results = await repository.fetchByPeriod(period: _period);

      expect(results.map((e) => e.date), contains('20250625'));
      expect(results.map((e) => e.date), contains('20250724'));
    });

    test('期間開始前日・期間終了翌日は含まない', () async {
      await _seedStandardFixedCostExpenses();

      final results = await repository.fetchByPeriod(period: _period);

      expect(results.map((e) => e.date), isNot(contains('20250624')));
      expect(results.map((e) => e.date), isNot(contains('20250725')));
    });

    test('年跨ぎの期間（12/25〜1/24）でも取得できる', () async {
      await insertFixedCostExpenseRow(
        id: 1,
        fixedCostId: 10,
        fixedCostCategoryId: 1,
        date: '20241224',
        price: 1,
        name: '期間前',
      );
      await insertFixedCostExpenseRow(
        id: 2,
        fixedCostId: 10,
        fixedCostCategoryId: 1,
        date: '20241225',
        price: 2,
        name: '開始日',
      );
      await insertFixedCostExpenseRow(
        id: 3,
        fixedCostId: 10,
        fixedCostCategoryId: 1,
        date: '20250124',
        price: 3,
        name: '終了日',
      );
      await insertFixedCostExpenseRow(
        id: 4,
        fixedCostId: 10,
        fixedCostCategoryId: 1,
        date: '20250125',
        price: 4,
        name: '期間後',
      );

      final results = await repository.fetchByPeriod(
        period: PeriodValue(
          startDatetime: DateTime(2024, 12, 25),
          endDatetime: DateTime(2025, 1, 24),
        ),
      );

      expect(results.map((e) => e.id).toList(), [3, 2]);
    });

    test('該当が無いなら空リストを返す', () async {
      await _seedStandardFixedCostExpenses();

      final results = await repository.fetchByPeriod(
        period: PeriodValue(
          startDatetime: DateTime(2020, 1, 1),
          endDatetime: DateTime(2020, 1, 31),
        ),
      );

      expect(results, isEmpty);
    });
  });

  group('fetchTotalConfirmedFixedCostExpenseWithPeriod', () {
    test('期間内の確定分だけを合計する', () async {
      await _seedStandardFixedCostExpenses();

      final total = await repository
          .fetchTotalConfirmedFixedCostExpenseWithPeriod(period: _period);

      // 2000 + 3000 + 5000（未確定のid=4と期間外のid=1,6は除外）
      expect(total, 10000);
    });

    test('期間開始日・終了日ちょうどを含み、期間外は合計しない', () async {
      await _seedStandardFixedCostExpenses();

      final total = await repository
          .fetchTotalConfirmedFixedCostExpenseWithPeriod(
            period: PeriodValue(
              startDatetime: DateTime(2025, 6, 25),
              endDatetime: DateTime(2025, 6, 25),
            ),
          );

      // 期間開始日の2000だけ（前日の1000は含まない）
      expect(total, 2000);
    });

    test('該当が無いならCOALESCEで0を返す', () async {
      final total = await repository
          .fetchTotalConfirmedFixedCostExpenseWithPeriod(period: _period);

      expect(total, 0);
    });
  });

  group('fetchTotalConfirmedFixedCostExpenseWithPeriodAndCategory', () {
    test('指定カテゴリーの確定分だけを合計する', () async {
      await _seedStandardFixedCostExpenses();

      final total = await repository
          .fetchTotalConfirmedFixedCostExpenseWithPeriodAndCategory(
            period: _period,
            fixedCostCategoryId: 2,
          );

      // カテゴリー2は id=3(3000・確定) と id=4(未確定) → 3000のみ
      expect(total, 3000);
    });

    test('別のカテゴリーを指定するとその分だけを合計する', () async {
      await _seedStandardFixedCostExpenses();

      final total = await repository
          .fetchTotalConfirmedFixedCostExpenseWithPeriodAndCategory(
            period: _period,
            fixedCostCategoryId: 1,
          );

      // 期間内のカテゴリー1は id=2 だけ（id=1,6は期間外）
      expect(total, 2000);
    });

    test('該当カテゴリーが無いならCOALESCEで0を返す', () async {
      await _seedStandardFixedCostExpenses();

      final total = await repository
          .fetchTotalConfirmedFixedCostExpenseWithPeriodAndCategory(
            period: _period,
            fixedCostCategoryId: 99,
          );

      expect(total, 0);
    });
  });

  group('fetchTotalUnconfirmedFixedCostEstimatedWithPeriod', () {
    test('未確定行に紐づくfixed_cost.estimated_priceを合計する（支出のpriceではない）', () async {
      await _seedFixedCostMasters();
      await _seedStandardFixedCostExpenses();
      // 期間内の未確定をもう1件追加（固定費40 → 推定4500）
      await insertFixedCostExpenseRow(
        id: 7,
        fixedCostId: 40,
        fixedCostCategoryId: 3,
        date: '20250715',
        price: 999999, // 未確定行のpriceは合計に使われないことを示す極端な値
        name: '水道代',
        confirmedCostType: 1,
        isConfirmed: 0,
      );

      final total = await repository
          .fetchTotalUnconfirmedFixedCostEstimatedWithPeriod(period: _period);

      // 3500（固定費30） + 4500（固定費40）
      expect(total, 8000);
    });

    test('確定済みの行は合計しない', () async {
      await _seedFixedCostMasters();
      // 期間内の確定行のみ
      await insertFixedCostExpenseRow(
        id: 1,
        fixedCostId: 10,
        fixedCostCategoryId: 1,
        date: '20250701',
        price: 80000,
        name: '家賃',
        isConfirmed: 1,
      );

      final total = await repository
          .fetchTotalUnconfirmedFixedCostEstimatedWithPeriod(period: _period);

      expect(total, 0);
    });

    test('紐づく固定費マスタが無い未確定行はINNER JOINで落ちる', () async {
      // マスタを投入しないまま未確定行だけを作る
      await insertFixedCostExpenseRow(
        id: 1,
        fixedCostId: 999,
        fixedCostCategoryId: 1,
        date: '20250701',
        price: 0,
        name: '孤立レコード',
        isConfirmed: 0,
      );

      final total = await repository
          .fetchTotalUnconfirmedFixedCostEstimatedWithPeriod(period: _period);

      expect(total, 0);
    });

    test('期間外の未確定行は合計しない', () async {
      await _seedFixedCostMasters();
      await insertFixedCostExpenseRow(
        id: 1,
        fixedCostId: 30,
        fixedCostCategoryId: 2,
        date: '20250624', // 期間開始前日
        price: 0,
        name: '電気代',
        isConfirmed: 0,
      );
      await insertFixedCostExpenseRow(
        id: 2,
        fixedCostId: 30,
        fixedCostCategoryId: 2,
        date: '20250625', // 期間開始日
        price: 0,
        name: '電気代',
        isConfirmed: 0,
      );

      final total = await repository
          .fetchTotalUnconfirmedFixedCostEstimatedWithPeriod(period: _period);

      // 期間開始日の1件分のみ
      expect(total, 3500);
    });

    test('未確定行が1件も無いならCOALESCEで0を返す', () async {
      await _seedFixedCostMasters();

      final total = await repository
          .fetchTotalUnconfirmedFixedCostEstimatedWithPeriod(period: _period);

      expect(total, 0);
    });
  });

  group('fetchUnconfirmedFixedCostExpenseWithPeriod', () {
    test('期間内の未確定行だけを日付降順で返す', () async {
      // 未確定リストはfixed_costとINNER JOINするためマスタが要る
      await _seedFixedCostMasters();
      await _seedStandardFixedCostExpenses();
      await insertFixedCostExpenseRow(
        id: 7,
        fixedCostId: 40,
        fixedCostCategoryId: 3,
        date: '20250715',
        price: 0,
        name: '水道代',
        isConfirmed: 0,
      );

      final results = await repository
          .fetchUnconfirmedFixedCostExpenseWithPeriod(period: _period);

      // 07-15 → 07-10 の順（ORDER BY date DESC）
      expect(results.map((e) => e.id).toList(), [7, 4]);
    });

    test('期間外の未確定行は含まない', () async {
      // 未確定リストはfixed_costとINNER JOINするためマスタが要る
      await _seedFixedCostMasters();
      await insertFixedCostExpenseRow(
        id: 1,
        fixedCostId: 10,
        fixedCostCategoryId: 1,
        date: '20250624',
        price: 0,
        name: '期間前',
        isConfirmed: 0,
      );
      await insertFixedCostExpenseRow(
        id: 2,
        fixedCostId: 10,
        fixedCostCategoryId: 1,
        date: '20250625',
        price: 0,
        name: '開始日',
        isConfirmed: 0,
      );
      await insertFixedCostExpenseRow(
        id: 3,
        fixedCostId: 10,
        fixedCostCategoryId: 1,
        date: '20250725',
        price: 0,
        name: '期間後',
        isConfirmed: 0,
      );

      final results = await repository
          .fetchUnconfirmedFixedCostExpenseWithPeriod(period: _period);

      expect(results.map((e) => e.id).toList(), [2]);
    });

    test('未確定が無いなら空リストを返す', () async {
      await insertFixedCostExpenseRow(
        id: 1,
        fixedCostId: 10,
        fixedCostCategoryId: 1,
        date: '20250701',
        price: 100,
        name: '確定済み',
        isConfirmed: 1,
      );

      final results = await repository
          .fetchUnconfirmedFixedCostExpenseWithPeriod(period: _period);

      expect(results, isEmpty);
    });
  });

  group('fetchUnconfirmedFixedCostExpenseWithPeriodAndCategory', () {
    test('指定カテゴリーの未確定行だけを返す', () async {
      // 未確定リストはfixed_costとINNER JOINするためマスタが要る
      await _seedFixedCostMasters();
      await _seedStandardFixedCostExpenses();
      await insertFixedCostExpenseRow(
        id: 7,
        fixedCostId: 40,
        fixedCostCategoryId: 3,
        date: '20250715',
        price: 0,
        name: '水道代',
        isConfirmed: 0,
      );

      final results = await repository
          .fetchUnconfirmedFixedCostExpenseWithPeriodAndCategory(
            period: _period,
            fixedCostCategoryId: 2,
          );

      // カテゴリー2の未確定は id=4 だけ（id=7はカテゴリー3）
      expect(results.map((e) => e.id).toList(), [4]);
    });

    test('カテゴリーが一致しても確定済みなら含まない', () async {
      await _seedStandardFixedCostExpenses();

      final results = await repository
          .fetchUnconfirmedFixedCostExpenseWithPeriodAndCategory(
            period: _period,
            fixedCostCategoryId: 1,
          );

      // カテゴリー1の期間内(id=2)は確定済みなので0件
      expect(results, isEmpty);
    });
  });

  group('fetchByFixedCostId', () {
    test('fixed_cost_id で絞り込む', () async {
      // かつては引数名に反してfixed_cost_category_idで絞り込んでいたため、
      // 別カテゴリーの実績を巻き込んでいた。その回帰検知
      await _seedStandardFixedCostExpenses();

      final results = await repository.fetchByFixedCostId(fixedCostId: 10);

      // 固定費ID=10の行（id=1,2,6）が返る
      expect(_sortedIds(results), [1, 2, 6]);
    });

    test('カテゴリーIDが一致するだけの行は含まない', () async {
      await _seedStandardFixedCostExpenses();

      // 2はカテゴリーIDとしては存在する（id=3,4）が、固定費IDとしては存在しない
      final results = await repository.fetchByFixedCostId(fixedCostId: 2);

      expect(results, isEmpty);
    });

    test('該当する固定費IDが無いなら空リストを返す', () async {
      await _seedStandardFixedCostExpenses();

      final results = await repository.fetchByFixedCostId(fixedCostId: 999);

      expect(results, isEmpty);
    });
  });

  group('fetchFixedCostExpenseWithCostId', () {
    test('fixed_cost_id で絞り込む', () async {
      await _seedStandardFixedCostExpenses();

      final results = await repository.fetchFixedCostExpenseWithCostId(
        fixedCostId: 10,
      );

      // 固定費10の支払実績（期間内外・確定未確定を問わない）
      expect(_sortedIds(results), [1, 2, 6]);
    });

    test('該当が無いなら空リストを返す', () async {
      await _seedStandardFixedCostExpenses();

      final results = await repository.fetchFixedCostExpenseWithCostId(
        fixedCostId: 999,
      );

      expect(results, isEmpty);
    });
  });

  group('update', () {
    test('指定idの行だけが書き換わる', () async {
      await _seedStandardFixedCostExpenses();

      await repository.update(
        const FixedCostExpenseEntity(
          id: 3,
          fixedCostId: 20,
          fixedCostCategoryId: 5,
          date: '20250705',
          price: 9999,
          name: '変更後',
          confirmedCostType: 1,
          isConfirmed: 0,
        ),
      );

      final results = await repository.fetchAll();
      final updated = results.firstWhere((e) => e.id == 3);
      expect(updated.fixedCostCategoryId, 5);
      expect(updated.date, '20250705');
      expect(updated.price, 9999);
      expect(updated.name, '変更後');
      expect(updated.isConfirmed, 0);

      // 他の行は変化しない
      expect(results.firstWhere((e) => e.id == 2).price, 2000);
      expect(results.length, 6);
    });

    test('存在しないidを指定しても何も変わらない', () async {
      await _seedStandardFixedCostExpenses();

      await repository.update(
        const FixedCostExpenseEntity(
          id: 999,
          fixedCostId: 10,
          fixedCostCategoryId: 1,
          date: '20250705',
          price: 1,
          name: '存在しない',
        ),
      );

      final results = await repository.fetchAll();
      expect(results.length, 6);
      expect(results.firstWhere((e) => e.id == 3).price, 3000);
    });
  });

  group('delete', () {
    test('指定idの行が物理削除される', () async {
      await _seedStandardFixedCostExpenses();

      await repository.delete(3);

      expect(
        await DatabaseHelper.instance.queryRowCount(
          SqfFixedCostExpense.tableName,
        ),
        5,
      );
      final results = await repository.fetchAll();
      expect(_sortedIds(results), [1, 2, 4, 5, 6]);
    });

    test('存在しないidを指定しても何も削除されない', () async {
      await _seedStandardFixedCostExpenses();

      await repository.delete(999);

      expect(
        await DatabaseHelper.instance.queryRowCount(
          SqfFixedCostExpense.tableName,
        ),
        6,
      );
    });
  });

  group('confirmExpense', () {
    test('指定idの行がis_confirmed=1になり、priceが指定額へ更新される', () async {
      await _seedStandardFixedCostExpenses();

      await repository.confirmExpense(id: 4, price: 7800);

      final results = await repository.fetchAll();
      final confirmed = results.firstWhere((e) => e.id == 4);
      expect(confirmed.isConfirmed, 1);
      expect(confirmed.price, 7800);
    });

    test('price以外のカラム（固定費ID・カテゴリー・日付・名称・種別）は保持される', () async {
      await _seedStandardFixedCostExpenses();

      await repository.confirmExpense(id: 4, price: 7800);

      final results = await repository.fetchAll();
      final confirmed = results.firstWhere((e) => e.id == 4);
      expect(confirmed.fixedCostId, 30);
      expect(confirmed.fixedCostCategoryId, 2);
      expect(confirmed.date, '20250710');
      expect(confirmed.name, '電気代');
      expect(confirmed.confirmedCostType, 1);
    });

    test('他の行は一切変化しない', () async {
      await _seedStandardFixedCostExpenses();

      await repository.confirmExpense(id: 4, price: 7800);

      final results = await repository.fetchAll();
      expect(results.length, 6);
      for (final e in results.where((e) => e.id != 4)) {
        // 確定操作でIDを取り違えると他行のpriceやis_confirmedが書き換わる
        expect(e.isConfirmed, 1, reason: 'id=${e.id} の確定状態が変わっている');
      }
      expect(results.firstWhere((e) => e.id == 3).price, 3000);
      expect(results.firstWhere((e) => e.id == 5).price, 5000);
    });

    test('確定額を0で確定するとpriceが0になる', () async {
      await _seedStandardFixedCostExpenses();

      await repository.confirmExpense(id: 3, price: 0);

      final results = await repository.fetchAll();
      final confirmed = results.firstWhere((e) => e.id == 3);
      expect(confirmed.price, 0);
      expect(confirmed.isConfirmed, 1);
    });

    test('存在しないidなら例外を投げる', () async {
      await _seedStandardFixedCostExpenses();

      await expectLater(
        () => repository.confirmExpense(id: 999, price: 100),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('999'),
          ),
        ),
      );
    });
  });

  group('fetchFixedCostEstimatedPriceById', () {
    test('確定済みの支払実績の平均額を返す', () async {
      await insertFixedCostExpenseRow(
        id: 1,
        fixedCostId: 30,
        fixedCostCategoryId: 2,
        date: '20250501',
        price: 7000,
        name: '電気代',
        isConfirmed: 1,
      );
      await insertFixedCostExpenseRow(
        id: 2,
        fixedCostId: 30,
        fixedCostCategoryId: 2,
        date: '20250601',
        price: 8000,
        name: '電気代',
        isConfirmed: 1,
      );

      final average = await repository.fetchFixedCostEstimatedPriceById(
        fixedCostId: 30,
      );

      expect(average, 7500.0);
    });

    test('未確定の行は平均に含めない', () async {
      await insertFixedCostExpenseRow(
        id: 1,
        fixedCostId: 30,
        fixedCostCategoryId: 2,
        date: '20250501',
        price: 7000,
        name: '電気代',
        isConfirmed: 1,
      );
      await insertFixedCostExpenseRow(
        id: 2,
        fixedCostId: 30,
        fixedCostCategoryId: 2,
        date: '20250701',
        price: 100000, // 未確定。平均に混ざると7000から大きくずれる
        name: '電気代',
        isConfirmed: 0,
      );

      final average = await repository.fetchFixedCostEstimatedPriceById(
        fixedCostId: 30,
      );

      expect(average, 7000.0);
    });

    test('別の固定費の実績は平均に含めない', () async {
      await insertFixedCostExpenseRow(
        id: 1,
        fixedCostId: 30,
        fixedCostCategoryId: 2,
        date: '20250501',
        price: 7000,
        name: '電気代',
        isConfirmed: 1,
      );
      await insertFixedCostExpenseRow(
        id: 2,
        fixedCostId: 40,
        fixedCostCategoryId: 3,
        date: '20250501',
        price: 3000,
        name: '水道代',
        isConfirmed: 1,
      );

      final average = await repository.fetchFixedCostEstimatedPriceById(
        fixedCostId: 30,
      );

      expect(average, 7000.0);
    });

    test('確定済みの実績が無いなら0.0を返す（AVGがNULLになるため）', () async {
      await insertFixedCostExpenseRow(
        id: 1,
        fixedCostId: 30,
        fixedCostCategoryId: 2,
        date: '20250701',
        price: 100,
        name: '電気代',
        isConfirmed: 0,
      );

      final average = await repository.fetchFixedCostEstimatedPriceById(
        fixedCostId: 30,
      );

      expect(average, 0.0);
    });
  });

  group('fetchDailyFixedCostExpenseByPeriod', () {
    test('指定日の固定費支出を確定・未確定を問わずpriceで合計する', () async {
      await _seedFixedCostMasters();
      await insertFixedCostExpenseRow(
        id: 1,
        fixedCostId: 10,
        fixedCostCategoryId: 1,
        date: '20250701',
        price: 80000,
        name: '家賃',
        isConfirmed: 1,
      );
      await insertFixedCostExpenseRow(
        id: 2,
        fixedCostId: 30,
        fixedCostCategoryId: 2,
        date: '20250701',
        price: 5000,
        name: '電気代',
        isConfirmed: 0,
      );

      final total = await repository.fetchDailyFixedCostExpenseByPeriod(
        date: DateTime(2025, 7, 1),
      );

      // 未確定でも estimated_price ではなく fixed_cost_expense.price を使う
      expect(total, 85000);
    });

    test('前日・翌日の固定費支出は合計しない', () async {
      await insertFixedCostExpenseRow(
        id: 1,
        fixedCostId: 10,
        fixedCostCategoryId: 1,
        date: '20250630',
        price: 100,
        name: '前日',
        isConfirmed: 1,
      );
      await insertFixedCostExpenseRow(
        id: 2,
        fixedCostId: 10,
        fixedCostCategoryId: 1,
        date: '20250701',
        price: 200,
        name: '当日',
        isConfirmed: 1,
      );
      await insertFixedCostExpenseRow(
        id: 3,
        fixedCostId: 10,
        fixedCostCategoryId: 1,
        date: '20250702',
        price: 300,
        name: '翌日',
        isConfirmed: 1,
      );

      final total = await repository.fetchDailyFixedCostExpenseByPeriod(
        date: DateTime(2025, 7, 1),
      );

      expect(total, 200);
    });

    test('その日に固定費支出が無いなら0を返す', () async {
      final total = await repository.fetchDailyFixedCostExpenseByPeriod(
        date: DateTime(2025, 7, 1),
      );

      // GROUP BY の結果が0行になるため0
      expect(total, 0);
    });
  });
}
