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
}
