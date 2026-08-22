import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost_read/fixed_cost_registration_list_usecase.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';
import 'fixed_cost_read_fixtures.dart';

void main() {
  // 大カテゴリー3（通信費）を足した3カテゴリー構成
  // fetchAllの並び順（表示順）がそのままグループの並び順になる
  const bigCategories = [
    ...fixtureBigCategories,
    ExpenseBigCategoryEntity(
      id: 3,
      colorCode: '00FF00',
      bigCategoryName: '通信費',
      resourcePath: 'assets/images/icon_wifi.svg',
      displayOrder: 3,
      isDisplayed: 1,
    ),
  ];

  ProviderContainer createUsecaseContainer({
    List<FixedCostEntity> fixedCosts = const [],
    List<ExpenseBigCategoryEntity> expenseBigCategories = bigCategories,
  }) {
    return createContainer(
      overrides: [
        fixedCostRepositoryProvider.overrideWithValue(
          FakeFixedCostRepository(initialRecords: fixedCosts),
        ),
        expenseSmallCategoryRepositoryProvider.overrideWithValue(
          FakeExpenseSmallCategoryRepository(
            initialRecords: fixtureSmallCategories,
          ),
        ),
        expensebigCategoryRepositoryProvider.overrideWithValue(
          FakeExpenseBigCategoryRepository(
            initialRecords: expenseBigCategories,
          ),
        ),
      ],
    );
  }

  // 家賃（小11 → 大1）
  const rent = FixedCostEntity(
    id: 10,
    name: '家賃',
    variable: 0,
    price: 80000,
    fixedCostCategoryId: 1,
    expenseSmallCategoryId: 11,
    intervalNumber: 1,
    intervalUnit: 1,
    firstPaymentDate: '20250101',
  );
  // 電気代（小21 → 大2）
  const electricity = FixedCostEntity(
    id: 20,
    name: '電気代',
    variable: 1,
    estimatedPrice: 6000,
    fixedCostCategoryId: 2,
    expenseSmallCategoryId: 21,
    intervalNumber: 1,
    intervalUnit: 1,
    firstPaymentDate: '20250101',
  );
  // 削除済み（deleteFlag=1）の固定費（小12 → 大1）
  const deletedSubscription = FixedCostEntity(
    id: 30,
    name: '解約済みサブスク',
    variable: 0,
    price: 500,
    fixedCostCategoryId: 3,
    expenseSmallCategoryId: 12,
    intervalNumber: 1,
    intervalUnit: 1,
    firstPaymentDate: '20250101',
    deleteFlag: 1,
  );

  group('FixedCostRegistrationListUsecaseNotifier', () {
    test('削除済みの固定費は一覧に含まれない', () async {
      final container = createUsecaseContainer(
        fixedCosts: const [rent, electricity, deletedSubscription],
      );

      final result = await container.read(
        fixedCostRegistrationListNotifierProvider.future,
      );

      final allItems = result.categoryGroups.expand((e) => e.items).toList();
      expect(allItems.map((e) => e.id), [10, 20]);
    });

    test('グループは支出大カテゴリーの並び順になる', () async {
      final container = createUsecaseContainer(
        fixedCosts: const [
          electricity,
          rent,
          // 小カテゴリー参照が解決できない固定費は一覧に出せないため、
          // 大3のグループは通信費の小カテゴリーを持つマスタで作る
        ],
      );

      final result = await container.read(
        fixedCostRegistrationListNotifierProvider.future,
      );

      // 登録順は電気代（大2）が先だが、グループは大カテゴリーの表示順で並ぶ
      expect(result.categoryGroups.map((e) => e.categoryId), [1, 2]);
      expect(result.categoryGroups.map((e) => e.categoryName), ['住居', '光熱費']);
      expect(
        result.categoryGroups.first.categoryIconPath,
        'assets/images/icon_home.svg',
      );
      expect(result.categoryGroups.first.categoryColorCode, 'FFAA00');
    });

    test('同じ大カテゴリーの別の小カテゴリーは1グループにまとまる', () async {
      // 家賃（小11）と保険（小12）はどちらも大カテゴリー1
      const insurance = FixedCostEntity(
        id: 40,
        name: '保険',
        variable: 0,
        price: 30000,
        fixedCostCategoryId: 1,
        expenseSmallCategoryId: 12,
        intervalNumber: 1,
        intervalUnit: 2,
        firstPaymentDate: '20250101',
      );
      final container = createUsecaseContainer(
        fixedCosts: const [rent, insurance],
      );

      final result = await container.read(
        fixedCostRegistrationListNotifierProvider.future,
      );

      expect(result.categoryGroups, hasLength(1));
      expect(result.categoryGroups.single.categoryId, 1);
      expect(result.categoryGroups.single.items.map((e) => e.id), [10, 40]);
    });

    test('固定費が1件も無いカテゴリーはグループに含まれない', () async {
      final container = createUsecaseContainer(fixedCosts: const [rent]);

      final result = await container.read(
        fixedCostRegistrationListNotifierProvider.future,
      );

      expect(result.categoryGroups, hasLength(1));
      expect(result.categoryGroups.single.categoryId, 1);
      expect(result.categoryGroups.single.items, hasLength(1));
    });

    test('固定費もカテゴリーも無ければ空のValueを返す', () async {
      final container = createUsecaseContainer(
        expenseBigCategories: const [],
      );

      final result = await container.read(
        fixedCostRegistrationListNotifierProvider.future,
      );

      expect(result.categoryGroups, isEmpty);
    });
  });
}
