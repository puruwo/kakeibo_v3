// 実効金額の共通式 COALESCE(price, estimated_price) を使った集計のDB結合テスト
//
// v10で固定費実績も expense に入るようになり、未確定行は price が NULL・
// estimated_price に予想額を持つ（仕様 §3）。集計SQLがこの共通式を使い、
// 未確定行を予想額で合算することを本物のSQLで固定する。
// 旧 FixedCostService.getFixedCostTotal（後付け合算）を廃止した置き換え先。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_entity.dart';
import 'package:kakeibo/repository/category_repository.dart';
import 'package:kakeibo/repository/daily_expense_repository.dart';
import 'package:kakeibo/repository/expense_repository.dart';

import '../../helper/db_test_helper.dart';

/// 基準シナリオの集計期間（開始日25日設定で 2025/7/6 を選んだときの期間）
final _fromDate = DateTime(2025, 6, 25);
final _toDate = DateTime(2025, 7, 24);

/// 通常支出・確定固定費・未確定固定費を1件ずつ含むフィクスチャ
///
/// | id | 日付       | 種別           | price | estimated_price | 実効金額 |
/// |----|------------|----------------|-------|-----------------|----------|
/// | 1  | 2025-07-01 | 通常支出       | 1000  | NULL            | 1000     |
/// | 2  | 2025-07-05 | 固定費・確定   | 8000  | 7500            | 8000     |
/// | 3  | 2025-07-10 | 固定費・未確定 | NULL  | 3000            | 3000     |
///
/// 実効金額の合計は 12000 円。
/// id=2 は「予想7500円→実際8000円」の予実乖離を残したまま確定した行で、
/// 集計に使われるのが estimated_price ではなく price であることを見分けられる。
Future<void> _seedMixedExpenses({int smallCategoryId = 1}) async {
  await insertExpenseRow(
    id: 1,
    date: '20250701',
    price: 1000,
    smallCategoryId: smallCategoryId,
  );
  await insertExpenseRow(
    id: 2,
    date: '20250705',
    price: 8000,
    smallCategoryId: smallCategoryId,
    fixedCostId: 1,
    isConfirmed: 1,
    estimatedPrice: 7500,
  );
  await insertExpenseRow(
    id: 3,
    date: '20250710',
    price: null,
    smallCategoryId: smallCategoryId,
    fixedCostId: 2,
    isConfirmed: 0,
    estimatedPrice: 3000,
  );
}

void main() {
  setUpDbTestEnvironment();

  final expenseRepository = ImplementsExpenseRepository();
  final categoryRepository = ImplementsCategoryAccountingRepository();
  final dailyExpenseRepository = ImplementsDailyExpenseRepository();

  group('ImplementsExpenseRepository の合計系', () {
    test('未確定の固定費行は予想額で合算される（確定行は実額）', () async {
      await _seedMixedExpenses();

      final total = await expenseRepository.fetchTotalExpenseByPeriod(
        fromDate: _fromDate,
        toDate: _toDate,
      );

      // 1000（通常）+ 8000（確定・実額）+ 3000（未確定・予想額）
      expect(total, 12000);
    });

    test('拠出元指定の合計も実効金額で集計される', () async {
      await _seedMixedExpenses();

      final total = await expenseRepository
          .fetchTotalExpenseByPeriodWithBigCategory(
            incomeSourceBigCategory: 1,
            fromDate: _fromDate,
            toDate: _toDate,
          );

      expect(total, 12000);
    });

    test('小カテゴリー指定の合計も実効金額で集計される', () async {
      await _seedMixedExpenses(smallCategoryId: 3);

      final total = await expenseRepository
          .fetchTotalExpenseByPeriodWithSmallCategoryAndSource(
            incomeSourceBigCategory: 1,
            smallCategoryId: 3,
            fromDate: _fromDate,
            toDate: _toDate,
          );

      expect(total, 12000);
    });

    test('priceもestimated_priceもNULLの行は0円として扱われる', () async {
      // COALESCE が両方NULLならNULLを返すため、SUM対象から外れて合計が壊れないこと
      await insertExpenseRow(
        id: 1,
        date: '20250701',
        price: null,
        fixedCostId: 1,
        isConfirmed: 0,
        estimatedPrice: null,
      );
      await insertExpenseRow(id: 2, date: '20250701', price: 500);

      final total = await expenseRepository.fetchTotalExpenseByPeriod(
        fromDate: _fromDate,
        toDate: _toDate,
      );

      expect(total, 500);
    });

    test('日別合計も実効金額で集計される', () async {
      await _seedMixedExpenses();

      final unconfirmedDay = await expenseRepository.fetchDailyExpenseByPeriod(
        date: DateTime(2025, 7, 10),
      );

      // 未確定行だけの日は予想額がそのまま日別合計になる
      expect(unconfirmedDay, 3000);
    });
  });

  group('ImplementsCategoryAccountingRepository の大カテゴリー別集計', () {
    test('固定費行も同じ大カテゴリーの支出として実効金額で合算される', () async {
      // onCreate のシードで小カテゴリー1は大カテゴリー1に属する
      await _seedMixedExpenses(smallCategoryId: 1);

      final results = await categoryRepository.fetchAll(
        incomeSourceBigCategoryId: 1,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      final target = results.firstWhere(
        (CategoryAccountingEntity e) => e.id == 1,
      );
      expect(target.totalExpenseByBigCategory, 12000);
    });
  });

  group('ImplementsDailyExpenseRepository の日別集計', () {
    test('固定費行は単一テーブル集計に含まれ、二重計上されない', () async {
      await _seedMixedExpenses();

      final results = await dailyExpenseRepository.fetchDailyTotalsByPeriod(
        fromDate: _fromDate,
        toDate: _toDate,
      );

      final totalsByDate = {
        for (final e in results) e.date: e.totalExpense,
      };
      expect(totalsByDate[DateTime(2025, 7, 1)], 1000);
      expect(totalsByDate[DateTime(2025, 7, 5)], 8000);
      expect(totalsByDate[DateTime(2025, 7, 10)], 3000);
    });
  });
}
