import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_fixed_cost_usecase.dart';
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

  // 固定費カテゴリーマスタ
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

  // 固定費マスタ（10:毎月の家賃 / 20:毎年の保険 / 30:変動する電気代）
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
      id: 20,
      name: '保険',
      variable: 0,
      price: 30000,
      fixedCostCategoryId: 1,
      intervalNumber: 1,
      intervalUnit: 2,
      firstPaymentDate: '20250101',
      nextPaymentDate: '20260701',
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

  group('MonthlyFixedCostUsecaseNotifier', () {
    test('確定済み（isConfirmed=1）の固定費支出だけタイル化される', () async {
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
          FixedCostExpenseEntity(
            id: 101,
            fixedCostId: 30,
            fixedCostCategoryId: 2,
            date: '20250705',
            name: '電気代',
            confirmedCostType: 1,
            isConfirmed: 0,
          ),
        ],
      );

      final result = await container.read(
        monthlyFixedCostNotifierProvider(period).future,
      );

      expect(result, hasLength(1));
      expect(result.first.id, 100);
      expect(result.first.name, '家賃');
      expect(result.first.price, 80000);
    });

    test('固定費マスタとカテゴリーマスタの情報が結合される', () async {
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
          FixedCostExpenseEntity(
            id: 102,
            fixedCostId: 20,
            fixedCostCategoryId: 1,
            date: '20250630',
            price: 30000,
            name: '保険',
          ),
        ],
      );

      final result = await container.read(
        monthlyFixedCostNotifierProvider(period).future,
      );

      // 日付降順で返るため 7/1 の家賃が先頭
      expect(result, hasLength(2));
      final rent = result.first;
      expect(rent.variable, 0);
      expect(rent.intervalNumber, 1);
      expect(rent.intervalUnit, 1);
      expect(rent.nextPaymentDate, '20250801');
      expect(rent.categoryName, '住居');
      expect(rent.colorCode, 'FFAA00');
      expect(rent.resourcePath, 'assets/images/icon_home.svg');
      // 支払い頻度はマスタの間隔からラベル化される
      expect(rent.frequencyLabel, '毎月');
      expect(result.last.frequencyLabel, '毎年');
    });

    test('yyyyMMddの日付文字列がDateTimeに変換される', () async {
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
        monthlyFixedCostNotifierProvider(period).future,
      );

      expect(result.first.date, DateTime(2025, 7, 1));
    });

    test('期間内に固定費支出が無ければ空リストを返す', () async {
      final container = createUsecaseContainer();

      final result = await container.read(
        monthlyFixedCostNotifierProvider(period).future,
      );

      expect(result, isEmpty);
    });
  });
}
