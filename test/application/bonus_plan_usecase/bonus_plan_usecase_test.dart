import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/bonus_plan_usecase/bonus_plan_usecase.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/ui_value/bonus_plan_value/bonus_plan_value.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  // 年度は2025/4/25〜2026/4/24
  final yearPeriod = PeriodValue(
    startDatetime: DateTime(2025, 4, 25),
    endDatetime: DateTime(2026, 4, 24),
  );

  // 収入小カテゴリーID → 大カテゴリーID（1:給与 / 2:賞与→ボーナス / 3:副業）
  const smallCategoryToBigCategory = {1: 1, 2: 2, 3: 1};

  Future<BonusPlanValue> fetchBonusPlan({
    List<IncomeEntity> incomes = const [],
    int bonusExpense = 0,
  }) {
    final container = createContainer(
      overrides: [
        incomeRepositoryProvider.overrideWithValue(
          FakeIncomeRepository(
            initialRecords: incomes,
            smallCategoryToBigCategory: smallCategoryToBigCategory,
          ),
        ),
        expenseRepositoryProvider.overrideWithValue(
          FakeExpenseRepository()
            ..totalExpenseByPeriodWithBigCategoryResult = bonusExpense,
        ),
      ],
    );
    return container.read(bonusPlanNotifierProvider(yearPeriod).future);
  }

  group('BonusPlanUsecaseNotifier', () {
    test('ボーナス（大カテゴリー2）の収入と充当支出を合計し残額を返す', () async {
      final result = await fetchBonusPlan(
        incomes: const [
          // 賞与（大カテゴリー2）は集計対象
          IncomeEntity(id: 1, categoryId: 2, date: '20250625', price: 400000),
          IncomeEntity(id: 2, categoryId: 2, date: '20251215', price: 500000),
          // 給与（大カテゴリー1）はボーナスに含めない
          IncomeEntity(id: 3, categoryId: 1, date: '20250625', price: 300000),
          // 期間外の賞与も含めない
          IncomeEntity(id: 4, categoryId: 2, date: '20260525', price: 100000),
        ],
        bonusExpense: 250000,
      );

      expect(result.yearlyBonusIncome, 900000);
      expect(result.yearlyBonusExpense, 250000);
      expect(result.lastBonusPrice, 650000);
    });

    test('収入も支出も0なら残額は0', () async {
      final result = await fetchBonusPlan();

      expect(result.yearlyBonusIncome, 0);
      expect(result.yearlyBonusExpense, 0);
      expect(result.lastBonusPrice, 0);
    });

    test('支出が収入を上回れば残額は負になる', () async {
      final result = await fetchBonusPlan(
        incomes: const [
          IncomeEntity(id: 1, categoryId: 2, date: '20250625', price: 300000),
        ],
        bonusExpense: 500000,
      );

      expect(result.lastBonusPrice, -200000);
    });
  });
}
