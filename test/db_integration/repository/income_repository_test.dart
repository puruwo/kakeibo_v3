// ImplementsIncomeRepository のDB結合テスト
//
// 収入系SQLはカテゴリーマスタとのINNER JOINを含むため、
// 「マスタに紐付かない行が落ちる」ところまで本物のSQLで確かめる。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/repository/income_repository.dart';

import '../../helper/db_test_helper.dart';

/// 基準シナリオの集計期間（開始日25日設定で 2025/7/6 を選んだときの期間）
final _period = PeriodValue(
  startDatetime: DateTime(2025, 6, 25),
  endDatetime: DateTime(2025, 7, 24),
);

/// 期間境界と大/小カテゴリーの紐付けを一度に検証できる標準フィクスチャ
///
/// onCreateの収入小カテゴリー: 1=給与(大1) 2=ボーナス(大2) 3=小遣い(大1) 4=臨時収入(大1)
///
/// | id | 日付       | 位置        | 小カテゴリー | 大カテゴリー | 金額 |
/// |----|------------|-------------|--------------|--------------|------|
/// | 1  | 2025-06-24 | 期間開始前日 | 1 給与        | 1            | 1    |
/// | 2  | 2025-06-25 | 期間開始日   | 1 給与        | 1            | 100  |
/// | 3  | 2025-07-01 | 期間中       | 3 小遣い      | 1            | 200  |
/// | 4  | 2025-07-01 | 期間中       | 2 ボーナス    | 2            | 300  |
/// | 5  | 2025-07-24 | 期間終了日   | 4 臨時収入    | 1            | 400  |
/// | 6  | 2025-07-25 | 期間終了翌日 | 1 給与        | 1            | 2    |
Future<void> _seedStandardIncomes() async {
  await insertIncomeRow(id: 1, date: '20250624', price: 1, smallCategoryId: 1);
  await insertIncomeRow(
    id: 2,
    date: '20250625',
    price: 100,
    smallCategoryId: 1,
  );
  await insertIncomeRow(
    id: 3,
    date: '20250701',
    price: 200,
    smallCategoryId: 3,
  );
  await insertIncomeRow(
    id: 4,
    date: '20250701',
    price: 300,
    smallCategoryId: 2,
  );
  await insertIncomeRow(
    id: 5,
    date: '20250724',
    price: 400,
    smallCategoryId: 4,
  );
  await insertIncomeRow(id: 6, date: '20250725', price: 2, smallCategoryId: 1);
}

/// SQLにORDER BYが無いクエリの結果を、比較しやすいようid昇順に整える
List<int> _sortedIds(List<IncomeEntity> results) =>
    results.map((e) => e.id).toList()..sort();

void main() {
  setUpDbTestEnvironment();

  final repository = ImplementsIncomeRepository();

  group('fetchAll', () {
    test('全ての収入をid昇順で返す', () async {
      await _seedStandardIncomes();

      final results = await repository.fetchAll();

      expect(results.map((e) => e.id).toList(), [1, 2, 3, 4, 5, 6]);
    });

    test('1件も無いなら空リストを返す', () async {
      final results = await repository.fetchAll();

      expect(results, isEmpty);
    });

    test('小カテゴリーIDがcategoryIdとしてエンティティへマッピングされる', () async {
      await insertIncomeRow(
        id: 1,
        date: '20250625',
        price: 250000,
        smallCategoryId: 2,
        memo: '夏ボーナス',
      );

      final results = await repository.fetchAll();

      expect(
        results.single,
        const IncomeEntity(
          id: 1,
          categoryId: 2,
          date: '20250625',
          price: 250000,
          memo: '夏ボーナス',
        ),
      );
    });
  });

  group('fetchWithoutCategory', () {
    test('カテゴリーで絞らず期間内の収入を全て返す', () async {
      await _seedStandardIncomes();

      final results = await repository.fetchWithoutCategory(period: _period);

      // 大カテゴリー1も2も混在して返る
      expect(_sortedIds(results), [2, 3, 4, 5]);
    });

    test('期間開始日・終了日ちょうどを含み、前日・翌日は含まない', () async {
      await _seedStandardIncomes();

      final results = await repository.fetchWithoutCategory(period: _period);

      final dates = results.map((e) => e.date).toList();
      expect(dates, contains('20250625'));
      expect(dates, contains('20250724'));
      expect(dates, isNot(contains('20250624')));
      expect(dates, isNot(contains('20250725')));
    });

    test('マスタに無い小カテゴリーIDの収入もJOINしないので返る', () async {
      // fetchWithAccountTypeAndPeriod（JOINで落ちる）との違いを固定する
      await insertIncomeRow(
        id: 1,
        date: '20250701',
        price: 999,
        smallCategoryId: 99,
      );

      final results = await repository.fetchWithoutCategory(period: _period);

      expect(_sortedIds(results), [1]);
    });

    test('該当が無いなら空リストを返す', () async {
      final results = await repository.fetchWithoutCategory(period: _period);

      expect(results, isEmpty);
    });
  });

  group('fetchWithAccountTypeAndPeriod', () {
    test('会計種別=生活収支なら特別枠（ボーナス）以外の期間内収入を返す', () async {
      await _seedStandardIncomes();

      final results = await repository.fetchWithAccountTypeAndPeriod(
        period: _period,
        accountType: 1,
      );

      // 給与(2)・小遣い(3)・臨時収入(5)。ボーナス(4)と期間外(1,6)は含まない
      expect(_sortedIds(results), [2, 3, 5]);
    });

    test('会計種別=特別枠ならボーナスの期間内収入だけを返す', () async {
      await _seedStandardIncomes();

      final results = await repository.fetchWithAccountTypeAndPeriod(
        period: _period,
        accountType: 2,
      );

      expect(_sortedIds(results), [4]);
    });

    test('ユーザー追加の第3カテゴリーは会計種別に応じたスコープに含まれる', () async {
      await _seedStandardIncomes();
      // 特別枠のユーザー追加カテゴリー「副業」（大id=3・小id=5）を作る
      await insertIncomeBigCategoryRow(id: 3, name: '副業', accountType: 2);
      await insertIncomeSmallCategoryRow(id: 5, bigCategoryKey: 3, name: '案件A');
      await insertIncomeRow(
        id: 7,
        date: '20250710',
        price: 500,
        smallCategoryId: 5,
      );

      final special = await repository.fetchWithAccountTypeAndPeriod(
        period: _period,
        accountType: 2,
      );
      final living = await repository.fetchWithAccountTypeAndPeriod(
        period: _period,
        accountType: 1,
      );

      // 副業(7)はボーナス(4)と同じ特別枠スコープに入り、生活収支には混入しない
      expect(_sortedIds(special), [4, 7]);
      expect(_sortedIds(living), [2, 3, 5]);
    });
  });

  group('calcurateSumWithAccountTypeAndPeriod', () {
    test('会計種別=生活収支の期間内収入を合計する', () async {
      await _seedStandardIncomes();

      final total = await repository.calcurateSumWithAccountTypeAndPeriod(
        period: _period,
        accountType: 1,
      );

      // 100(給与) + 200(小遣い) + 400(臨時収入)
      expect(total, 700);
    });

    test('会計種別=特別枠は第3カテゴリーの収入も合算する', () async {
      await _seedStandardIncomes();
      await insertIncomeBigCategoryRow(id: 3, name: '副業', accountType: 2);
      await insertIncomeSmallCategoryRow(id: 5, bigCategoryKey: 3, name: '案件A');
      await insertIncomeRow(
        id: 7,
        date: '20250710',
        price: 500,
        smallCategoryId: 5,
      );

      final total = await repository.calcurateSumWithAccountTypeAndPeriod(
        period: _period,
        accountType: 2,
      );

      // 300(ボーナス) + 500(副業)
      expect(total, 800);
    });

    test('該当が無いなら0を返す（SUMのNULLを0へフォールバック）', () async {
      final total = await repository.calcurateSumWithAccountTypeAndPeriod(
        period: _period,
        accountType: 2,
      );

      expect(total, 0);
    });
  });

  group('calcurateSumWithSmallCategoryAndPeriod', () {
    test('指定した小カテゴリーの期間内収入を合計する', () async {
      await _seedStandardIncomes();
      await insertIncomeRow(
        id: 7,
        date: '20250710',
        price: 500,
        smallCategoryId: 1,
      );

      final total = await repository.calcurateSumWithSmallCategoryAndPeriod(
        period: _period,
        smallCategoryId: 1,
      );

      // 期間内の給与は 100 + 500（前日・翌日の給与は除外）
      expect(total, 600);
    });

    test('期間終了日ちょうどの収入を合計に含む', () async {
      await _seedStandardIncomes();

      final total = await repository.calcurateSumWithSmallCategoryAndPeriod(
        period: _period,
        smallCategoryId: 4,
      );

      // 臨時収入は期間終了日(7/24)の400のみ
      expect(total, 400);
    });

    test('該当が無いなら0を返す', () async {
      await _seedStandardIncomes();

      final total = await repository.calcurateSumWithSmallCategoryAndPeriod(
        period: _period,
        smallCategoryId: 99,
      );

      expect(total, 0);
    });
  });

  group('calcurateSumWithPeriod', () {
    test('期間内の収入をカテゴリー問わず合計する', () async {
      await _seedStandardIncomes();

      final total = await repository.calcurateSumWithPeriod(period: _period);

      // 100 + 200 + 300 + 400
      expect(total, 1000);
    });

    test('期間外の収入は合計しない', () async {
      await _seedStandardIncomes();

      final total = await repository.calcurateSumWithPeriod(
        period: PeriodValue(
          startDatetime: DateTime(2025, 6, 26),
          endDatetime: DateTime(2025, 7, 23),
        ),
      );

      // 開始日(100)と終了日(400)を外すと 200 + 300
      expect(total, 500);
    });

    test('年跨ぎの期間（12/25〜1/24）でも合計できる', () async {
      await insertIncomeRow(id: 1, date: '20241224', price: 1);
      await insertIncomeRow(id: 2, date: '20241225', price: 100);
      await insertIncomeRow(id: 3, date: '20250124', price: 200);
      await insertIncomeRow(id: 4, date: '20250125', price: 2);

      final total = await repository.calcurateSumWithPeriod(
        period: PeriodValue(
          startDatetime: DateTime(2024, 12, 25),
          endDatetime: DateTime(2025, 1, 24),
        ),
      );

      expect(total, 300);
    });

    test('該当が無いなら0を返す', () async {
      final total = await repository.calcurateSumWithPeriod(period: _period);

      expect(total, 0);
    });
  });

  group('insert', () {
    test('1件追加され、指定した値がそのまま保存される', () async {
      repository.insert(
        const IncomeEntity(
          categoryId: 3,
          date: '20250701',
          price: 40000,
          memo: 'こづかい',
        ),
      );
      await waitUntilRowCount(SqfIncome.tableName, 1);

      final results = await repository.fetchAll();
      expect(results.single.categoryId, 3);
      expect(results.single.date, '20250701');
      expect(results.single.price, 40000);
      expect(results.single.memo, 'こづかい');
    });

    test('idはエンティティの値ではなくAUTOINCREMENTで採番される', () async {
      await insertIncomeRow(id: 50, date: '20250601', price: 10);

      repository.insert(const IncomeEntity(id: 1, date: '20250701', price: 20));
      await waitUntilRowCount(SqfIncome.tableName, 2);

      final results = await repository.fetchAll();
      expect(results.map((e) => e.id).toList(), [50, 51]);
    });
  });

  group('update', () {
    test('指定idの行だけが書き換わる', () async {
      await _seedStandardIncomes();

      repository.update(
        const IncomeEntity(
          id: 3,
          categoryId: 4,
          date: '20250705',
          price: 999,
          memo: '修正後',
        ),
      );
      await settleDbWrites();
      await waitUntil(() async {
        final rows = await DatabaseHelper.instance.queryRowsWhere(
          SqfIncome.tableName,
          '${SqfIncome.id} = ?',
          [3],
        );
        return rows.first[SqfIncome.price] == 999;
      }, description: 'id=3の収入が更新されること');

      final results = await repository.fetchAll();
      final updated = results.firstWhere((e) => e.id == 3);
      expect(updated.categoryId, 4);
      expect(updated.date, '20250705');
      expect(updated.memo, '修正後');

      expect(results.firstWhere((e) => e.id == 2).price, 100);
      expect(results.length, 6);
    });

    test('存在しないidを指定しても他の行は変わらない', () async {
      await _seedStandardIncomes();

      repository.update(
        const IncomeEntity(id: 999, date: '20250705', price: 1),
      );
      await settleDbWrites();

      final results = await repository.fetchAll();
      expect(results.length, 6);
      expect(results.map((e) => e.price).toList(), [1, 100, 200, 300, 400, 2]);
    });
  });

  group('delete', () {
    test('指定idの行だけが削除される', () async {
      await _seedStandardIncomes();

      repository.delete(3);
      await waitUntilRowCount(SqfIncome.tableName, 5);

      final results = await repository.fetchAll();
      expect(results.map((e) => e.id).toList(), [1, 2, 4, 5, 6]);
    });

    test('存在しないidを指定しても何も削除されない', () async {
      await _seedStandardIncomes();

      repository.delete(999);
      await settleDbWrites();

      expect(
        await DatabaseHelper.instance.queryRowCount(SqfIncome.tableName),
        6,
      );
    });
  });
}
