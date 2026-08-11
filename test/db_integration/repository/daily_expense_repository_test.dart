// ImplementsDailyExpenseRepository のDB結合テスト
//
// カレンダーの日別サマリー。expense / fixed_cost_expense / income を UNION ALL して
// 1日分に畳む。固定費は「確定なら実績price・未確定なら固定費マスタのestimated_price」を
// 使い分けるため、その分岐をここで固定する。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/repository/daily_expense_repository.dart';

import '../../helper/db_test_helper.dart';

void main() {
  setUpDbTestEnvironment();

  final repository = ImplementsDailyExpenseRepository();

  group('fetchWithCategory', () {
    test('その日の支出・固定費・収入をまとめて集計する', () async {
      await insertFixedCostRow(
        id: 10,
        name: '家賃',
        fixedCostCategoryId: 1,
        price: 80000,
        estimatedPrice: 80000,
      );
      await insertExpenseRow(id: 1, date: '20250701', price: 100);
      await insertExpenseRow(id: 2, date: '20250701', price: 200);
      await insertFixedCostExpenseRow(
        id: 1,
        fixedCostId: 10,
        fixedCostCategoryId: 1,
        date: '20250701',
        price: 80000,
        name: '家賃',
        isConfirmed: 1,
      );
      await insertIncomeRow(id: 1, date: '20250701', price: 300000);

      final result = await repository.fetchWithCategory(
        incomeSourceBigId: 1,
        dateTime: DateTime(2025, 7, 1),
      );

      expect(result.date, DateTime(2025, 7, 1));
      expect(result.totalExpense, 80300);
      expect(result.totalIncome, 300000);
    });

    test('未確定の固定費は実績priceではなく固定費マスタのestimated_priceで集計する', () async {
      await insertFixedCostRow(
        id: 30,
        name: '電気代',
        fixedCostCategoryId: 4,
        variable: 1,
        estimatedPrice: 7800,
      );
      await insertFixedCostExpenseRow(
        id: 1,
        fixedCostId: 30,
        fixedCostCategoryId: 4,
        date: '20250701',
        price: 999999, // 未確定行のpriceは使われないことを示す極端な値
        name: '電気代',
        confirmedCostType: 1,
        isConfirmed: 0,
      );

      final result = await repository.fetchWithCategory(
        incomeSourceBigId: 1,
        dateTime: DateTime(2025, 7, 1),
      );

      expect(result.totalExpense, 7800);
    });

    test('確定済みの固定費は実績priceで集計する', () async {
      await insertFixedCostRow(
        id: 30,
        name: '電気代',
        fixedCostCategoryId: 4,
        variable: 1,
        estimatedPrice: 7800,
      );
      await insertFixedCostExpenseRow(
        id: 1,
        fixedCostId: 30,
        fixedCostCategoryId: 4,
        date: '20250701',
        price: 9200,
        name: '電気代',
        confirmedCostType: 1,
        isConfirmed: 1,
      );

      final result = await repository.fetchWithCategory(
        incomeSourceBigId: 1,
        dateTime: DateTime(2025, 7, 1),
      );

      expect(result.totalExpense, 9200);
    });

    test('引数のincomeSourceBigIdは絞り込みに使われずボーナス拠出の支出も合算される（実装準拠）', () async {
      await insertExpenseRow(
        id: 1,
        date: '20250701',
        price: 100,
        incomeSourceBigCategory: 1,
      );
      await insertExpenseRow(
        id: 2,
        date: '20250701',
        price: 300,
        incomeSourceBigCategory: 2,
      );

      final salary = await repository.fetchWithCategory(
        incomeSourceBigId: 1,
        dateTime: DateTime(2025, 7, 1),
      );
      final bonus = await repository.fetchWithCategory(
        incomeSourceBigId: 2,
        dateTime: DateTime(2025, 7, 1),
      );

      // SQLに income_source_big_category の条件が無いため、どちらも全額が返る
      expect(salary.totalExpense, 400);
      expect(bonus.totalExpense, 400);
    });

    test('前日・翌日のデータは合算しない', () async {
      await insertExpenseRow(id: 1, date: '20250630', price: 100);
      await insertExpenseRow(id: 2, date: '20250701', price: 200);
      await insertExpenseRow(id: 3, date: '20250702', price: 300);
      await insertIncomeRow(id: 1, date: '20250630', price: 1000);

      final result = await repository.fetchWithCategory(
        incomeSourceBigId: 1,
        dateTime: DateTime(2025, 7, 1),
      );

      expect(result.totalExpense, 200);
      expect(result.totalIncome, 0);
    });

    test('紐づく固定費マスタが無い未確定行はNULL扱いで合計されない', () async {
      // マスタを投入しないまま未確定の固定費支出だけを作る（LEFT JOINでNULLになる）
      await insertFixedCostExpenseRow(
        id: 1,
        fixedCostId: 999,
        fixedCostCategoryId: 1,
        date: '20250701',
        price: 5000,
        name: '孤立レコード',
        isConfirmed: 0,
      );

      final result = await repository.fetchWithCategory(
        incomeSourceBigId: 1,
        dateTime: DateTime(2025, 7, 1),
      );

      expect(result.totalExpense, 0);
    });

    test('その日にデータが1件も無いなら0円のエンティティを返す', () async {
      final result = await repository.fetchWithCategory(
        incomeSourceBigId: 1,
        dateTime: DateTime(2025, 7, 1),
      );

      // GROUP BY の結果が0行なので、引数の日付で組み立てた0円エンティティが返る
      expect(result.date, DateTime(2025, 7, 1));
      expect(result.totalExpense, 0);
      expect(result.totalIncome, 0);
    });
  });
}
