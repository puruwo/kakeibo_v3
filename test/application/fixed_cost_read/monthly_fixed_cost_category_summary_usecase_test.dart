import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_fixed_cost_category_summary_usecase.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';

import 'fixed_cost_read_fixtures.dart';

void main() {
  // 集計期間は2025/6/25〜2025/7/24
  final period = PeriodValue(
    startDatetime: DateTime(2025, 6, 25),
    endDatetime: DateTime(2025, 7, 24),
  );

  // 確定済みの電気代（実額7,200円）。小カテゴリー21 → 大カテゴリー2（光熱費）
  const confirmedElectricity = ExpenseEntity(
    id: 105,
    date: '20250705',
    price: 7200,
    paymentCategoryId: 21,
    memo: '電気代',
    fixedCostId: 30,
    isConfirmed: 1,
    estimatedPrice: 6000,
  );

  group('MonthlyFixedCostCategorySummaryNotifier', () {
    test('支出大カテゴリーごとにグループ化される', () async {
      final container = createFixedCostReadContainer(
        expenses: const [
          fixtureConfirmedRent,
          confirmedElectricity,
          fixtureUnconfirmedElectricity,
        ],
      );

      final result = await container.read(
        monthlyFixedCostCategorySummaryNotifierProvider(period).future,
      );

      expect(result, hasLength(2));
      final housing = result.firstWhere((e) => e.fixedCostCategoryId == 1);
      final utility = result.firstWhere((e) => e.fixedCostCategoryId == 2);
      expect(housing.categoryName, '住居');
      expect(housing.colorCode, 'FFAA00');
      expect(housing.resourcePath, 'assets/images/icon_home.svg');
      expect(utility.categoryName, '光熱費');
    });

    test('カテゴリー内に未確定があればisAllConfirmedはfalseになる', () async {
      final container = createFixedCostReadContainer(
        expenses: const [
          fixtureConfirmedRent,
          confirmedElectricity,
          fixtureUnconfirmedElectricity,
        ],
      );

      final result = await container.read(
        monthlyFixedCostCategorySummaryNotifierProvider(period).future,
      );

      expect(
        result.firstWhere((e) => e.fixedCostCategoryId == 1).isAllConfirmed,
        isTrue,
      );
      expect(
        result.firstWhere((e) => e.fixedCostCategoryId == 2).isAllConfirmed,
        isFalse,
      );
    });

    test('totalAmountは確定済みの実額と未確定分の予想額の合計になる', () async {
      final container = createFixedCostReadContainer(
        expenses: const [
          fixtureConfirmedRent,
          confirmedElectricity,
          fixtureUnconfirmedElectricity,
        ],
      );

      final result = await container.read(
        monthlyFixedCostCategorySummaryNotifierProvider(period).future,
      );

      expect(
        result.firstWhere((e) => e.fixedCostCategoryId == 1).totalAmount,
        80000,
      );
      // 確定7200 + 未確定の予想額6000
      expect(
        result.firstWhere((e) => e.fixedCostCategoryId == 2).totalAmount,
        13200,
      );
    });

    test('同じ大カテゴリーの別の小カテゴリーは1グループにまとまる', () async {
      // 家賃（小11）と保険（小12）はどちらも大カテゴリー1（住居）
      final container = createFixedCostReadContainer(
        expenses: const [fixtureConfirmedRent, fixtureConfirmedInsurance],
      );

      final result = await container.read(
        monthlyFixedCostCategorySummaryNotifierProvider(period).future,
      );

      expect(result, hasLength(1));
      expect(result.single.fixedCostCategoryId, 1);
      expect(result.single.totalAmount, 110000);
    });

    test('期間内に固定費行が無ければ空リストを返す', () async {
      final container = createFixedCostReadContainer();

      final result = await container.read(
        monthlyFixedCostCategorySummaryNotifierProvider(period).future,
      );

      expect(result, isEmpty);
    });
  });
}
