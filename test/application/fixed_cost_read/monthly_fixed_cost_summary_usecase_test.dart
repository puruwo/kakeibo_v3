import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_fixed_cost_summary_usecase.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  // 集計期間は2025/6/25〜2025/7/24
  final period = PeriodValue(
    startDatetime: DateTime(2025, 6, 25),
    endDatetime: DateTime(2025, 7, 24),
  );

  // 固定費マスタ（想定額つき）
  const fixedCosts = [
    FixedCostEntity(
      id: 10,
      name: '家賃',
      variable: 0,
      price: 80000,
      fixedCostCategoryId: 1,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
    ),
    FixedCostEntity(
      id: 30,
      name: '電気代',
      variable: 1,
      estimatedPrice: 6000,
      fixedCostCategoryId: 2,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
    ),
    FixedCostEntity(
      id: 40,
      name: 'ガス代',
      variable: 1,
      estimatedPrice: 4000,
      fixedCostCategoryId: 2,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
    ),
  ];

  ProviderContainer createUsecaseContainer({
    List<FixedCostExpenseEntity> fixedCostExpenses = const [],
  }) {
    return createContainer(
      overrides: [
        fixedCostExpenseRepositoryProvider.overrideWithValue(
          FakeFixedCostExpenseRepository(initialRecords: fixedCostExpenses),
        ),
        fixedCostRepositoryProvider.overrideWithValue(
          FakeFixedCostRepository(initialRecords: fixedCosts),
        ),
      ],
    );
  }

  // 確定済みの家賃
  const confirmedRent = FixedCostExpenseEntity(
    id: 100,
    fixedCostId: 10,
    fixedCostCategoryId: 1,
    date: '20250701',
    price: 80000,
    name: '家賃',
  );
  // 未確定の電気代（想定額6000）
  const unconfirmedElectricity = FixedCostExpenseEntity(
    id: 200,
    fixedCostId: 30,
    fixedCostCategoryId: 2,
    date: '20250705',
    name: '電気代',
    confirmedCostType: 1,
    isConfirmed: 0,
  );
  // 未確定のガス代（想定額4000）
  const unconfirmedGas = FixedCostExpenseEntity(
    id: 201,
    fixedCostId: 40,
    fixedCostCategoryId: 2,
    date: '20250706',
    name: 'ガス代',
    confirmedCostType: 1,
    isConfirmed: 0,
  );

  group('MonthlyFixedCostSummaryNotifier', () {
    test('確定合計と未確定の推定合計の和が支払予定額になる', () async {
      final container = createUsecaseContainer(
        fixedCostExpenses: const [
          confirmedRent,
          unconfirmedElectricity,
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
      final container = createUsecaseContainer(
        fixedCostExpenses: const [
          confirmedRent,
          FixedCostExpenseEntity(
            id: 101,
            fixedCostId: 30,
            fixedCostCategoryId: 2,
            date: '20250705',
            price: 7200,
            name: '電気代',
            confirmedCostType: 1,
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
      final container = createUsecaseContainer(
        fixedCostExpenses: const [unconfirmedElectricity, unconfirmedGas],
      );

      final result = await container.read(
        monthlyFixedCostSummaryNotifierProvider(period).future,
      );

      expect(result.fixedCostSum, 0);
      expect(result.unconfirmedFixedCostSum, 10000);
      expect(result.scheduledPaymentAmount, 10000);
    });

    test('期間内に固定費支出が無ければ全て0になる', () async {
      final container = createUsecaseContainer();

      final result = await container.read(
        monthlyFixedCostSummaryNotifierProvider(period).future,
      );

      expect(result.fixedCostSum, 0);
      expect(result.unconfirmedFixedCostSum, 0);
      expect(result.scheduledPaymentAmount, 0);
    });
  });
}
