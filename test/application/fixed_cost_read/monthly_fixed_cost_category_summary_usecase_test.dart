import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_fixed_cost_category_summary_usecase.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
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

  const categories = [
    FixedCostCategoryEntity(
      id: 1,
      categoryName: '住居',
      colorCode: 'FFAA00',
      resourcePath: 'assets/images/icon_home.svg',
    ),
    FixedCostCategoryEntity(
      id: 2,
      categoryName: '光熱費',
      colorCode: '00AAFF',
      resourcePath: 'assets/images/icon_utility.svg',
    ),
  ];

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
  ];

  ProviderContainer createUsecaseContainer({
    List<FixedCostExpenseEntity> fixedCostExpenses = const [],
  }) {
    return createContainer(
      overrides: [
        fixedCostExpenseRepositoryProvider.overrideWithValue(
          FakeFixedCostExpenseRepository(initialRecords: fixedCostExpenses),
        ),
        fixedCostCategoryRepositoryProvider.overrideWithValue(
          FakeFixedCostCategoryRepository(initialRecords: categories),
        ),
        fixedCostRepositoryProvider.overrideWithValue(
          FakeFixedCostRepository(initialRecords: fixedCosts),
        ),
      ],
    );
  }

  const confirmedRent = FixedCostExpenseEntity(
    id: 100,
    fixedCostId: 10,
    fixedCostCategoryId: 1,
    date: '20250701',
    price: 80000,
    name: '家賃',
  );
  const confirmedElectricity = FixedCostExpenseEntity(
    id: 101,
    fixedCostId: 30,
    fixedCostCategoryId: 2,
    date: '20250705',
    price: 7200,
    name: '電気代',
    confirmedCostType: 1,
  );
  const unconfirmedElectricity = FixedCostExpenseEntity(
    id: 200,
    fixedCostId: 30,
    fixedCostCategoryId: 2,
    date: '20250705',
    name: '電気代',
    confirmedCostType: 1,
    isConfirmed: 0,
  );

  group('MonthlyFixedCostCategorySummaryNotifier', () {
    test('カテゴリーIDごとにグループ化される', () async {
      final container = createUsecaseContainer(
        fixedCostExpenses: const [
          confirmedRent,
          confirmedElectricity,
          unconfirmedElectricity,
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
      final container = createUsecaseContainer(
        fixedCostExpenses: const [
          confirmedRent,
          confirmedElectricity,
          unconfirmedElectricity,
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

    test('totalAmountは確定済みの金額と未確定分の推定額の合計になる', () async {
      final container = createUsecaseContainer(
        fixedCostExpenses: const [
          confirmedRent,
          confirmedElectricity,
          unconfirmedElectricity,
        ],
      );

      final result = await container.read(
        monthlyFixedCostCategorySummaryNotifierProvider(period).future,
      );

      expect(
        result.firstWhere((e) => e.fixedCostCategoryId == 1).totalAmount,
        80000,
      );
      // 確定7200 + 未確定の推定額6000
      expect(
        result.firstWhere((e) => e.fixedCostCategoryId == 2).totalAmount,
        13200,
      );
    });

    test('期間内に固定費支出が無ければ空リストを返す', () async {
      final container = createUsecaseContainer();

      final result = await container.read(
        monthlyFixedCostCategorySummaryNotifierProvider(period).future,
      );

      expect(result, isEmpty);
    });
  });
}
