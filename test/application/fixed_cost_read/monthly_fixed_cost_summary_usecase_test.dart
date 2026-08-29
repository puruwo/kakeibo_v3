import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_fixed_cost_summary_usecase.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';

import 'fixed_cost_read_fixtures.dart';

void main() {
  // 集計期間は2025/6/25〜2025/7/24
  final period = PeriodValue(
    startDatetime: DateTime(2025, 6, 25),
    endDatetime: DateTime(2025, 7, 24),
  );

  // 未確定のガス代（予想額4,000円）。電気代6,000円と合わせて未確定合計10,000円
  const unconfirmedGas = ExpenseEntity(
    id: 103,
    date: '20250706',
    price: null,
    paymentCategoryId: 21,
    memo: 'ガス代',
    fixedCostId: 30,
    isConfirmed: 0,
    estimatedPrice: 4000,
  );

  group('MonthlyFixedCostSummaryNotifier', () {
    test('確定合計と未確定の予想額合計の和が支払予定額になる', () async {
      final container = createFixedCostReadContainer(
        expenses: const [
          fixtureConfirmedRent,
          fixtureUnconfirmedElectricity,
          unconfirmedGas,
        ],
      );

      final result = await container.read(
        monthlyFixedCostSummaryNotifierProvider(period).future,
      );

      expect(result.fixedCostSum, 80000);
      expect(result.unconfirmedFixedCostSum, 10000);
      expect(result.scheduledPaymentAmount, 90000);
    });

    test('全て確定済みなら未確定分は0になる', () async {
      final container = createFixedCostReadContainer(
        expenses: const [
          fixtureConfirmedRent,
          // 確定済みでも予想額は残る（予実乖離の記録）。合計には実額7,200円が入る
          ExpenseEntity(
            id: 104,
            date: '20250705',
            price: 7200,
            paymentCategoryId: 21,
            memo: '電気代',
            fixedCostId: 30,
            isConfirmed: 1,
            estimatedPrice: 6000,
          ),
        ],
      );

      final result = await container.read(
        monthlyFixedCostSummaryNotifierProvider(period).future,
      );

      expect(result.fixedCostSum, 87200);
      expect(result.unconfirmedFixedCostSum, 0);
      expect(result.scheduledPaymentAmount, 87200);
    });

    test('全て未確定なら確定分は0になる', () async {
      final container = createFixedCostReadContainer(
        expenses: const [fixtureUnconfirmedElectricity, unconfirmedGas],
      );

      final result = await container.read(
        monthlyFixedCostSummaryNotifierProvider(period).future,
      );

      expect(result.fixedCostSum, 0);
      expect(result.unconfirmedFixedCostSum, 10000);
      expect(result.scheduledPaymentAmount, 10000);
    });

    test('期間内に固定費行が無ければ全て0になる', () async {
      final container = createFixedCostReadContainer();

      final result = await container.read(
        monthlyFixedCostSummaryNotifierProvider(period).future,
      );

      expect(result.fixedCostSum, 0);
      expect(result.unconfirmedFixedCostSum, 0);
      expect(result.scheduledPaymentAmount, 0);
    });
  });

  group('集計開始日の変更後の期間で再集計される（KP-005 D-4-1）', () {
    test('開始日 25→1 の期間 8/1〜8/31 には支払日10日の固定費行も25日の行も入る', () async {
      // 旧期間（8/25〜9/24）では f2(8/10) は前月扱い。暦月に変えると同じ月に揃う
      final calendarAugust = PeriodValue(
        startDatetime: DateTime(2026, 8, 1),
        endDatetime: DateTime(2026, 8, 31),
      );
      const rentOn25 = ExpenseEntity(
        id: 201,
        date: '20260825',
        price: 5000,
        paymentCategoryId: 11,
        fixedCostId: 10,
        isConfirmed: 1,
      );
      const electricityOn10 = ExpenseEntity(
        id: 202,
        date: '20260810',
        price: null,
        paymentCategoryId: 21,
        fixedCostId: 30,
        isConfirmed: 0,
        estimatedPrice: 3000,
      );
      final container = createFixedCostReadContainer(
        expenses: const [rentOn25, electricityOn10],
      );

      final oldPeriodResult = await container.read(
        monthlyFixedCostSummaryNotifierProvider(
          PeriodValue(
            startDatetime: DateTime(2026, 8, 25),
            endDatetime: DateTime(2026, 9, 24),
          ),
        ).future,
      );
      final newPeriodResult = await container.read(
        monthlyFixedCostSummaryNotifierProvider(calendarAugust).future,
      );

      // 旧区切り: 25日の家賃のみ
      expect(oldPeriodResult.fixedCostSum, 5000);
      expect(oldPeriodResult.unconfirmedFixedCostSum, 0);
      // 新区切り: 家賃＋未確定の電気代（予想額）
      expect(newPeriodResult.fixedCostSum, 5000);
      expect(newPeriodResult.unconfirmedFixedCostSum, 3000);
      expect(newPeriodResult.scheduledPaymentAmount, 8000);
    });
  });
}
