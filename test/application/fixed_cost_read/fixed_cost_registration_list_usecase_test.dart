import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost_read/fixed_cost_registration_list_usecase.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  // カテゴリーマスタ（fetchAllの並び順がグループの並び順になる）
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
    FixedCostCategoryEntity(
      id: 3,
      categoryName: '通信費',
      colorCode: '00FF00',
      resourcePath: 'assets/images/icon_wifi.svg',
    ),
  ];

  ProviderContainer createUsecaseContainer({
    List<FixedCostEntity> fixedCosts = const [],
    List<FixedCostCategoryEntity> fixedCostCategories = categories,
  }) {
    return createContainer(
      overrides: [
        fixedCostRepositoryProvider.overrideWithValue(
          FakeFixedCostRepository(initialRecords: fixedCosts),
        ),
        fixedCostCategoryRepositoryProvider.overrideWithValue(
          FakeFixedCostCategoryRepository(initialRecords: fixedCostCategories),
        ),
      ],
    );
  }

  const rent = FixedCostEntity(
    id: 10,
    name: '家賃',
    variable: 0,
    price: 80000,
    fixedCostCategoryId: 1,
    intervalNumber: 1,
    intervalUnit: 1,
    firstPaymentDate: '20250101',
  );
  const electricity = FixedCostEntity(
    id: 20,
    name: '電気代',
    variable: 1,
    estimatedPrice: 6000,
    fixedCostCategoryId: 2,
    intervalNumber: 1,
    intervalUnit: 1,
    firstPaymentDate: '20250101',
  );
  // 削除済み（deleteFlag=1）の固定費
  const deletedSubscription = FixedCostEntity(
    id: 30,
    name: '解約済みサブスク',
    variable: 0,
    price: 500,
    fixedCostCategoryId: 3,
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
      expect(result.categoryGroups.any((e) => e.categoryId == 3), isFalse);
    });

    test('グループはカテゴリーマスタの並び順になる', () async {
      final container = createUsecaseContainer(
        fixedCosts: const [
          electricity,
          rent,
          FixedCostEntity(
            id: 40,
            name: '通信費',
            variable: 0,
            price: 4000,
            fixedCostCategoryId: 3,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20250101',
          ),
        ],
      );

      final result = await container.read(
        fixedCostRegistrationListNotifierProvider.future,
      );

      expect(result.categoryGroups.map((e) => e.categoryId), [1, 2, 3]);
      expect(result.categoryGroups.map((e) => e.categoryName), [
        '住居',
        '光熱費',
        '通信費',
      ]);
      expect(
        result.categoryGroups.first.categoryIconPath,
        'assets/images/icon_home.svg',
      );
      expect(result.categoryGroups.first.categoryColorCode, 'FFAA00');
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
      final container = createUsecaseContainer(fixedCostCategories: const []);

      final result = await container.read(
        fixedCostRegistrationListNotifierProvider.future,
      );

      expect(result.categoryGroups, isEmpty);
    });
  });
}
