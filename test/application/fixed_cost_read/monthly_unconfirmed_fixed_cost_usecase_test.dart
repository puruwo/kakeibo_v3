import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_unconfirmed_fixed_cost_usecase.dart';
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

  // 30が未確定タイルの対象となる固定費マスタ。
  // 200は「固定費支出ID(=200)と同じidを持つ別マスタ」で、IDを取り違えると
  // こちらの情報がタイルに載ってしまう。
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
      nextPaymentDate: '20250801',
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
      nextPaymentDate: '20250805',
    ),
    FixedCostEntity(
      id: 200,
      name: '別の固定費',
      variable: 1,
      estimatedPrice: 999,
      fixedCostCategoryId: 2,
      intervalNumber: 2,
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

  // 未確定の電気代（固定費支出ID=200 / 固定費マスタID=30）
  const unconfirmedElectricity = FixedCostExpenseEntity(
    id: 200,
    fixedCostId: 30,
    fixedCostCategoryId: 2,
    date: '20250705',
    name: '電気代',
    confirmedCostType: 1,
    isConfirmed: 0,
  );

  group('MonthlyUnconfirmedFixedCostUsecaseNotifier', () {
    test('未確定（isConfirmed=0）の固定費支出だけタイル化される', () async {
      final container = createUsecaseContainer(
        fixedCostExpenses: const [
          FixedCostExpenseEntity(
            id: 100,
            fixedCostId: 10,
            fixedCostCategoryId: 1,
            date: '20250701',
            price: 80000,
            name: '家賃',
          ),
          unconfirmedElectricity,
        ],
      );

      final result = await container.read(
        monthlyUnconfirmedFixedCostNotifierProvider(period).future,
      );

      expect(result, hasLength(1));
      expect(result.first.id, 200);
      expect(result.first.name, '電気代');
      expect(result.first.date, DateTime(2025, 7, 5));
    });

    test('固定費マスタの想定額がタイルに載る', () async {
      final container = createUsecaseContainer(
        fixedCostExpenses: const [unconfirmedElectricity],
      );

      final result = await container.read(
        monthlyUnconfirmedFixedCostNotifierProvider(period).future,
      );

      expect(result.first.estimatedPrice, 6000);
      expect(result.first.categoryName, '光熱費');
      expect(result.first.frequencyLabel, '毎月');
    });

    test('タイルのfixedCostIdには固定費支出IDではなく固定費マスタIDが入る', () async {
      final container = createUsecaseContainer(
        fixedCostExpenses: const [unconfirmedElectricity],
      );

      final result = await container.read(
        monthlyUnconfirmedFixedCostNotifierProvider(period).future,
      );

      // 支出IDは200、マスタIDは30。確定操作はfixedCostIdで想定額を更新するため
      // ここに支出IDが入っていると別マスタ（id=200）を更新してしまう
      expect(result.first.id, 200);
      expect(result.first.fixedCostId, 30);
      expect(result.first.estimatedPrice, isNot(999));
    });

    test('期間内に未確定の固定費支出が無ければ空リストを返す', () async {
      final container = createUsecaseContainer(
        fixedCostExpenses: const [
          FixedCostExpenseEntity(
            id: 100,
            fixedCostId: 10,
            fixedCostCategoryId: 1,
            date: '20250701',
            price: 80000,
            name: '家賃',
          ),
        ],
      );

      final result = await container.read(
        monthlyUnconfirmedFixedCostNotifierProvider(period).future,
      );

      expect(result, isEmpty);
    });
  });
}
