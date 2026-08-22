import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/yearly_balance_usecase/yearly_balance_usecase.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/ui_value/yearly_balance_value/yearly_balance_value.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

/// テスト対象のリポジトリ一式
typedef Repositories = ({
  FakeIncomeRepository income,
  FakeExpenseRepository expense,
});

void main() {
  // 年度は2025/4/25〜2026/4/24（buildDateScopeの既定値）
  final dateScope = buildDateScope();

  // 年度の開始日（＝Fakeの期間別返却値のキー）
  const yearKey = '20250425';

  /// [expense] は年度期間の支出合計
  ///
  /// v10で固定費実績もexpenseに入り、未確定行は予想額で合算されるため
  /// （実効金額の共通式。仕様 §7.1）、固定費ぶんもこの1つの値に含まれる。
  Repositories buildRepositories({int income = 0, int expense = 0}) {
    return (
      income: FakeIncomeRepository()
        ..sumWithPeriodResultByPeriodStart[yearKey] = income,
      expense: FakeExpenseRepository()
        ..totalExpenseByPeriodResultByPeriodStart[yearKey] = expense,
    );
  }

  ProviderContainer createBalanceContainer(Repositories repositories) {
    return createContainer(
      overrides: [
        incomeRepositoryProvider.overrideWithValue(repositories.income),
        expenseRepositoryProvider.overrideWithValue(repositories.expense),
      ],
    );
  }

  Future<YearlyBalanceValue> fetchBalance({int income = 0, int expense = 0}) {
    final container = createBalanceContainer(
      buildRepositories(income: income, expense: expense),
    );
    return container.read(yearlyBalanceNotifierProvider(dateScope).future);
  }

  group('YearlyBalanceUsecaseNotifier', () {
    test('年間支出はexpenseの単一テーブル集計をそのまま使う（後付け合算なし）', () async {
      // 1000000（通常）+ 900000（確定固定費）+ 72000（未確定固定費の予想額）が
      // すでにSQL側で合算された値として返る
      final result = await fetchBalance(income: 3000000, expense: 1972000);

      expect(result.yearlyExpense, 1972000);
    });

    test('savingsは年間収入から年間支出を引いた額になる', () async {
      final result = await fetchBalance(income: 3000000, expense: 1972000);

      expect(result.yearlyIncome, 3000000);
      expect(result.savings, 1028000);
    });

    test('記録が欠けているときのステータス（noRecorod/noIncome/noExpense）', () async {
      final noRecord = await fetchBalance();
      final noIncome = await fetchBalance(expense: 1000000);
      final noExpense = await fetchBalance(income: 3000000);

      expect(noRecord.yearlyBalanceType, YearlyBalanceType.noRecorod);
      expect(noIncome.yearlyBalanceType, YearlyBalanceType.noIncome);
      expect(noExpense.yearlyBalanceType, YearlyBalanceType.noExpense);
    });

    test('黒字ならsurplus', () async {
      final result = await fetchBalance(
        income: 3000000,
        expense: 1000000,
      );

      expect(result.yearlyBalanceType, YearlyBalanceType.surplus);
    });

    test('赤字ならdeficit（収支差0もdeficit）', () async {
      final same = await fetchBalance(income: 1000000, expense: 1000000);
      final over = await fetchBalance(income: 1000000, expense: 1500000);

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
    });
  });
}
