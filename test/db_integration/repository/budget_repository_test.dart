// ImplementsBudgetRepository のDB結合テスト
//
// 予算は「同じ月・同じカテゴリーに複数行が積み上がる」設計なので、
// どの行が採用されるか（MAX(_id) か ORDER BY _id ASC か）を本物のSQLで固定する。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/month_value/month_value.dart';
import 'package:kakeibo/domain/db/budget/budget_entity.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/repository/budget_repository.dart';

import '../../helper/db_test_helper.dart';

/// 基準シナリオの代表月（2025/7/6 を選んだときの集計期間 6/25〜7/24 の代表月）
const _month = MonthValue(month: '202506');
const _otherMonth = MonthValue(month: '202507');

void main() {
  setUpDbTestEnvironment();

  final repository = ImplementsBudgetRepository();

  group('fetchMonthlyByBigCategory', () {
    test('該当する予算があればその行を返す', () async {
      await insertBudgetRow(
        id: 1,
        expenseBigCategoryId: 1,
        month: '202506',
        price: 35000,
      );

      final result = await repository.fetchMonthlyByBigCategory(
        month: _month,
        expenseBigCategoryId: 1,
      );

      expect(
        result,
        const BudgetEntity(
          id: 1,
          expenseBigCategoryId: 1,
          month: '202506',
          price: 35000,
        ),
      );
    });

    test('同じ月・同じカテゴリーの予算が複数あればMAX(_id)の行を返す', () async {
      // 予算変更は上書きではなく行追加で積まれるため、最後に登録した行が有効になる
      await insertBudgetRow(
        id: 1,
        expenseBigCategoryId: 1,
        month: '202506',
        price: 35000,
      );
      await insertBudgetRow(
        id: 5,
        expenseBigCategoryId: 1,
        month: '202506',
        price: 40000,
      );

      final result = await repository.fetchMonthlyByBigCategory(
        month: _month,
        expenseBigCategoryId: 1,
      );

      expect(result.id, 5);
      expect(result.price, 40000);
    });

    test('該当が無ければid=-1・price=0のデフォルト値を返す', () async {
      final result = await repository.fetchMonthlyByBigCategory(
        month: _month,
        expenseBigCategoryId: 3,
      );

      // 月とカテゴリーIDは引数の値がそのまま入る
      expect(
        result,
        const BudgetEntity(
          id: -1,
          expenseBigCategoryId: 3,
          month: '202506',
          price: 0,
        ),
      );
    });

    test('別の月の予算は拾わない', () async {
      await insertBudgetRow(
        id: 1,
        expenseBigCategoryId: 1,
        month: '202507',
        price: 35000,
      );

      final result = await repository.fetchMonthlyByBigCategory(
        month: _month,
        expenseBigCategoryId: 1,
      );

      expect(result.id, -1);
      expect(result.price, 0);
    });

    test('別のカテゴリーの予算は拾わない', () async {
      await insertBudgetRow(
        id: 1,
        expenseBigCategoryId: 2,
        month: '202506',
        price: 5000,
      );

      final result = await repository.fetchMonthlyByBigCategory(
        month: _month,
        expenseBigCategoryId: 1,
      );

      expect(result.id, -1);
      expect(result.price, 0);
    });
  });

  group('fetchMonthlyAll', () {
    test('指定月の全カテゴリーの予算を合計する', () async {
      await insertBudgetRow(
        id: 1,
        expenseBigCategoryId: 1,
        month: '202506',
        price: 35000,
      );
      await insertBudgetRow(
        id: 2,
        expenseBigCategoryId: 2,
        month: '202506',
        price: 5000,
      );
      await insertBudgetRow(
        id: 3,
        expenseBigCategoryId: 3,
        month: '202506',
        price: 32000,
      );

      final total = await repository.fetchMonthlyAll(month: _month);

      expect(total, 72000);
    });

    test('同じカテゴリーに複数行あれば全て合計される（MAX(_id)では絞らない）', () async {
      await insertBudgetRow(
        id: 1,
        expenseBigCategoryId: 1,
        month: '202506',
        price: 35000,
      );
      await insertBudgetRow(
        id: 2,
        expenseBigCategoryId: 1,
        month: '202506',
        price: 40000,
      );

      final total = await repository.fetchMonthlyAll(month: _month);

      // fetchMonthlyByBigCategory と違い、履歴行がそのまま足し込まれる
      expect(total, 75000);
    });

    test('別の月の予算は合計に含まない', () async {
      await insertBudgetRow(
        id: 1,
        expenseBigCategoryId: 1,
        month: '202506',
        price: 35000,
      );
      await insertBudgetRow(
        id: 2,
        expenseBigCategoryId: 1,
        month: '202507',
        price: 99999,
      );

      final total = await repository.fetchMonthlyAll(month: _month);

      expect(total, 35000);
    });

    test('予算が1件も無いなら0を返す', () async {
      final total = await repository.fetchMonthlyAll(month: _month);

      expect(total, 0);
    });
  });

  group('fetchMonthly', () {
    test('指定月・指定カテゴリーの予算額を返す', () async {
      await insertBudgetRow(
        id: 1,
        expenseBigCategoryId: 4,
        month: '202506',
        price: 9000,
      );

      final price = await repository.fetchMonthly(id: 4, month: _month);

      expect(price, 9000);
    });

    test('同じ月・同じカテゴリーが複数あるとid昇順の先頭を返す', () async {
      await insertBudgetRow(
        id: 1,
        expenseBigCategoryId: 1,
        month: '202506',
        price: 35000,
      );
      await insertBudgetRow(
        id: 5,
        expenseBigCategoryId: 1,
        month: '202506',
        price: 40000,
      );

      final price = await repository.fetchMonthly(id: 1, month: _month);

      // fetchMonthlyByBigCategory は MAX(_id) の 40000 を返すのに対し、
      // こちらは ORDER BY _id ASC の先頭（最初に登録した行）を返す
      expect(price, 35000);
    });

    test('別の月の予算は拾わない', () async {
      await insertBudgetRow(
        id: 1,
        expenseBigCategoryId: 1,
        month: '202507',
        price: 35000,
      );

      final price = await repository.fetchMonthly(id: 1, month: _month);

      expect(price, 0);
    });

    test('該当が無いなら0を返す', () async {
      final price = await repository.fetchMonthly(id: 1, month: _month);

      expect(price, 0);
    });

    test('priceがNULLの行なら0を返す', () async {
      // budget.price は NOT NULL ではないためNULLを保存できる
      await DatabaseHelper.instance.insert(SqfBudget.tableName, {
        SqfBudget.id: 1,
        SqfBudget.expenseBigCategoryId: 1,
        SqfBudget.month: '202506',
        SqfBudget.price: null,
      });

      final price = await repository.fetchMonthly(id: 1, month: _month);

      expect(price, 0);
    });
  });

  group('hasData', () {
    test('同じidの行が存在するならtrueを返す', () async {
      await insertBudgetRow(
        id: 1,
        expenseBigCategoryId: 1,
        month: '202506',
        price: 35000,
      );

      final exists = await repository.hasData(
        const BudgetEntity(
          id: 1,
          expenseBigCategoryId: 1,
          month: '202506',
          price: 35000,
        ),
      );

      expect(exists, isTrue);
    });

    test('存在しないidならfalseを返す', () async {
      await insertBudgetRow(
        id: 1,
        expenseBigCategoryId: 1,
        month: '202506',
        price: 35000,
      );

      final exists = await repository.hasData(
        const BudgetEntity(
          id: 999,
          expenseBigCategoryId: 1,
          month: '202506',
          price: 35000,
        ),
      );

      expect(exists, isFalse);
    });
  });

  group('insert', () {
    test('1件追加され、指定した値がそのまま保存される', () async {
      repository.insert(
        const BudgetEntity(
          expenseBigCategoryId: 5,
          month: '202506',
          price: 15000,
        ),
      );
      await waitUntilRowCount(SqfBudget.tableName, 1);

      final result = await repository.fetchMonthlyByBigCategory(
        month: _month,
        expenseBigCategoryId: 5,
      );
      expect(result.expenseBigCategoryId, 5);
      expect(result.month, '202506');
      expect(result.price, 15000);
    });

    test('別の月の予算を追加しても既存の月には影響しない', () async {
      await insertBudgetRow(
        id: 1,
        expenseBigCategoryId: 1,
        month: '202506',
        price: 35000,
      );

      repository.insert(
        const BudgetEntity(
          expenseBigCategoryId: 1,
          month: '202507',
          price: 40000,
        ),
      );
      await waitUntilRowCount(SqfBudget.tableName, 2);

      expect(await repository.fetchMonthlyAll(month: _month), 35000);
      expect(await repository.fetchMonthlyAll(month: _otherMonth), 40000);
    });
  });

  group('update', () {
    test('指定idの行だけが書き換わる', () async {
      await insertBudgetRow(
        id: 1,
        expenseBigCategoryId: 1,
        month: '202506',
        price: 35000,
      );
      await insertBudgetRow(
        id: 2,
        expenseBigCategoryId: 2,
        month: '202506',
        price: 5000,
      );

      repository.update(
        const BudgetEntity(
          id: 1,
          expenseBigCategoryId: 1,
          month: '202506',
          price: 50000,
        ),
      );
      await settleDbWrites();
      await waitUntil(
        () async =>
            (await repository.fetchMonthly(id: 1, month: _month)) == 50000,
        description: 'id=1の予算が更新されること',
      );

      expect(await repository.fetchMonthly(id: 2, month: _month), 5000);
      expect(
        await DatabaseHelper.instance.queryRowCount(SqfBudget.tableName),
        2,
      );
    });
  });

  group('delete', () {
    test('指定idの行だけが削除される', () async {
      await insertBudgetRow(
        id: 1,
        expenseBigCategoryId: 1,
        month: '202506',
        price: 35000,
      );
      await insertBudgetRow(
        id: 2,
        expenseBigCategoryId: 2,
        month: '202506',
        price: 5000,
      );

      repository.delete(1);
      await waitUntilRowCount(SqfBudget.tableName, 1);

      expect(await repository.fetchMonthlyAll(month: _month), 5000);
    });

    test('存在しないidを指定しても何も削除されない', () async {
      await insertBudgetRow(
        id: 1,
        expenseBigCategoryId: 1,
        month: '202506',
        price: 35000,
      );

      repository.delete(999);
      await settleDbWrites();

      expect(
        await DatabaseHelper.instance.queryRowCount(SqfBudget.tableName),
        1,
      );
    });
  });
}
