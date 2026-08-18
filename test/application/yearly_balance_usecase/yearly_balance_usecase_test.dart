import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/yearly_balance_usecase/yearly_balance_usecase.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/ui_value/yearly_balance_value/yearly_balance_value.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

/// テスト対象のリポジトリ一式
typedef Repositories = ({
  FakeIncomeRepository income,
  FakeExpenseRepository expense,
  FakeFixedCostExpenseRepository fixedCostExpense,
});

void main() {
  // 年度は2025/4/25〜2026/4/24（buildDateScopeの既定値）
  final dateScope = buildDateScope();

  // 年度の開始日（＝Fakeの期間別返却値のキー）
  const yearKey = '20250425';

  Repositories buildRepositories({
    int income = 0,
    int regularExpense = 0,
    int confirmedFixedCost = 0,
    int unconfirmedFixedCost = 0,
  }) {
    return (
      income: FakeIncomeRepository()
        ..sumWithPeriodResultByPeriodStart[yearKey] = income,
      expense: FakeExpenseRepository()
        ..totalExpenseByPeriodResultByPeriodStart[yearKey] = regularExpense,
      fixedCostExpense: FakeFixedCostExpenseRepository()
        ..confirmedTotalByPeriodStart[yearKey] = confirmedFixedCost
        ..unconfirmedEstimatedTotalByPeriodStart[yearKey] =
            unconfirmedFixedCost,
    );
  }

  ProviderContainer createBalanceContainer(Repositories repositories) {
    return createContainer(
      overrides: [
        incomeRepositoryProvider.overrideWithValue(repositories.income),
        expenseRepositoryProvider.overrideWithValue(repositories.expense),
        fixedCostExpenseRepositoryProvider.overrideWithValue(
          repositories.fixedCostExpense,
        ),
      ],
    );
  }

  Future<YearlyBalanceValue> fetchBalance({
    int income = 0,
    int regularExpense = 0,
    int confirmedFixedCost = 0,
    int unconfirmedFixedCost = 0,
  }) {
    final container = createBalanceContainer(
      buildRepositories(
        income: income,
        regularExpense: regularExpense,
        confirmedFixedCost: confirmedFixedCost,
        unconfirmedFixedCost: unconfirmedFixedCost,
      ),
    );
    return container.read(yearlyBalanceNotifierProvider(dateScope).future);
  }

  group('YearlyBalanceUsecaseNotifier', () {
    test('年間支出は一般支出＋確定固定費＋未確定固定費の推定額になる', () async {
      final result = await fetchBalance(
        income: 3000000,
        regularExpense: 1000000,
        confirmedFixedCost: 900000,
        unconfirmedFixedCost: 72000,
      );

      expect(result.yearlyExpense, 1972000);
    });

    test('savingsは年間収入から年間支出を引いた額になる', () async {
      final result = await fetchBalance(
        income: 3000000,
        regularExpense: 1000000,
        confirmedFixedCost: 900000,
        unconfirmedFixedCost: 72000,
      );

      expect(result.yearlyIncome, 3000000);
      expect(result.savings, 1028000);
    });

    test('記録が欠けているときのステータス（noRecorod/noIncome/noExpense）', () async {
      final noRecord = await fetchBalance();
      final noIncome = await fetchBalance(regularExpense: 1000000);
      final noExpense = await fetchBalance(income: 3000000);

      expect(noRecord.yearlyBalanceType, YearlyBalanceType.noRecorod);
      expect(noIncome.yearlyBalanceType, YearlyBalanceType.noIncome);
      expect(noExpense.yearlyBalanceType, YearlyBalanceType.noExpense);
    });

    test('黒字ならsurplus', () async {
      final result = await fetchBalance(
        income: 3000000,
        regularExpense: 1000000,
      );

      expect(result.yearlyBalanceType, YearlyBalanceType.surplus);
    });

    test('赤字ならdeficit（収支差0もdeficit）', () async {
      final same = await fetchBalance(income: 1000000, regularExpense: 1000000);
      final over = await fetchBalance(income: 1000000, regularExpense: 1500000);

      expect(same.yearlyBalanceType, YearlyBalanceType.deficit);
      expect(same.savings, 0);
      expect(over.yearlyBalanceType, YearlyBalanceType.deficit);
      expect(over.savings, -500000);
    });

    test('各リポジトリへ年度の期間が渡る', () async {
      final repositories = buildRepositories();
      final container = createBalanceContainer(repositories);

      await container.read(yearlyBalanceNotifierProvider(dateScope).future);

      final yearPeriod = dateScope.yearPeriod;
      expect(repositories.income.sumWithPeriodPeriods, [yearPeriod]);
      expect(repositories.expense.totalExpenseByPeriodRanges, [
        (fromDate: yearPeriod.startDatetime, toDate: yearPeriod.endDatetime),
      ]);
      expect(repositories.fixedCostExpense.confirmedTotalPeriods, [yearPeriod]);
      expect(repositories.fixedCostExpense.unconfirmedEstimatedTotalPeriods, [
        yearPeriod,
      ]);
    });
  });
}
