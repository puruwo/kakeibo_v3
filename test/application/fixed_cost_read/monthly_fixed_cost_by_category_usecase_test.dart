import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_fixed_cost_by_category_usecase.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_confirmed_fixed_cost_tile_value/monthly_confirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';

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

  // 200は「固定費支出ID(=200)と同じidを持つ別マスタ」
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
    date: '20250710',
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

  group('MonthlyFixedCostByCategoryUsecaseNotifier', () {
    test('確定済みと未確定がタイルの型で区別されて同じグループに入る', () async {
      final container = createUsecaseContainer(
        fixedCostExpenses: const [
          confirmedRent,
          confirmedElectricity,
          unconfirmedElectricity,
        ],
      );

      final result = await container.read(
        monthlyFixedCostByCategoryNotifierProvider(period).future,
      );

      expect(result, hasLength(2));
      final utility = result.firstWhere((e) => e.fixedCostCategoryId == 2);
      expect(utility.items, hasLength(2));
      // 日付降順なので 7/10 の確定分が先、7/5 の未確定分が後
      expect(utility.items.first, isA<MonthlyConfirmedFixedCostTileValue>());
      expect(utility.items.last, isA<MonthlyUnconfirmedFixedCostTileValue>());

      final housing = result.firstWhere((e) => e.fixedCostCategoryId == 1);
      expect(housing.items, hasLength(1));
      expect(housing.items.first, isA<MonthlyConfirmedFixedCostTileValue>());
    });

    test('グループのカテゴリー情報は先頭アイテムから引き継がれる', () async {
      final container = createUsecaseContainer(
        fixedCostExpenses: const [confirmedRent, unconfirmedElectricity],
      );

      final result = await container.read(
        monthlyFixedCostByCategoryNotifierProvider(period).future,
      );

      final housing = result.firstWhere((e) => e.fixedCostCategoryId == 1);
      expect(housing.categoryName, housing.items.first.categoryName);
      expect(housing.colorCode, housing.items.first.colorCode);
      expect(housing.resourcePath, housing.items.first.resourcePath);
      expect(housing.categoryName, '住居');

      final utility = result.firstWhere((e) => e.fixedCostCategoryId == 2);
      expect(utility.categoryName, '光熱費');
      expect(utility.resourcePath, 'assets/images/icon_utility.svg');
    });

    test('未確定タイルのfixedCostIdには固定費マスタIDが入る', () async {
      final container = createUsecaseContainer(
        fixedCostExpenses: const [unconfirmedElectricity],
      );

      final result = await container.read(
        monthlyFixedCostByCategoryNotifierProvider(period).future,
      );

      final tile =
          result.single.items.single as MonthlyUnconfirmedFixedCostTileValue;
      expect(tile.id, 200);
      expect(tile.fixedCostId, 30);
      expect(tile.estimatedPrice, 6000);
    });

    test('期間内に固定費支出が無ければ空リストを返す', () async {
      final container = createUsecaseContainer();

      final result = await container.read(
        monthlyFixedCostByCategoryNotifierProvider(period).future,
      );

      expect(result, isEmpty);
    });
  });
}
