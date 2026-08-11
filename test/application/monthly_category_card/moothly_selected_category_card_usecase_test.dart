import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/monthly_category_card/moothly_selected_category_card_usecase.dart';
import 'package:kakeibo/application/monthly_category_card/request_moothly_category_card.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_entity.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_repository.dart';
import 'package:kakeibo/domain/db/budget/budget_entity.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/category_card_entity.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_entity.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_repository.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  // 集計期間は2025/6/25〜2025/7/24、代表月は202506
  final dateScope = buildDateScope();

  CategoryAccountingEntity buildCategory({
    required int id,
    required String name,
    int totalExpense = 0,
  }) {
    return CategoryAccountingEntity(
      id: id,
      categoryColor: 'FFAA00',
      bigCategoryName: name,
      categoryIconPath: 'assets/images/icon_$id.svg',
      totalExpenseByBigCategory: totalExpense,
    );
  }

  SmallCategoryTileEntity buildTile({
    required int id,
    required String name,
    required int expense,
  }) {
    return SmallCategoryTileEntity(
      id: id,
      displeyOrder: id,
      smallCategoryName: name,
      totalExpenseBySmallCategory: expense,
      recordCount: 1,
    );
  }

  // 1:食費（支出20000） / 2:日用品（支出5000）
  final categories = [
    buildCategory(id: 1, name: '食費', totalExpense: 20000),
    buildCategory(id: 2, name: '日用品', totalExpense: 5000),
  ];
  final tilesByBigCategoryId = {
    1: [
      buildTile(id: 11, name: '外食', expense: 12000),
      buildTile(id: 12, name: '食料品', expense: 8000),
    ],
    2: [buildTile(id: 21, name: '消耗品', expense: 5000)],
  };

  ProviderContainer createCardContainer({
    List<BudgetEntity> budgets = const [],
  }) {
    return createContainer(
      overrides: [
        categoryAccountingRepositoryProvider.overrideWithValue(
          FakeCategoryAccountingRepository(categories: categories),
        ),
        smallCategoryTileRepositoryProvider.overrideWithValue(
          FakeSmallCategoryTileRepository(
            tilesByBigCategoryId: tilesByBigCategoryId,
          ),
        ),
        budgetRepositoryProvider.overrideWithValue(
          FakeBudgetRepository(initialRecords: budgets),
        ),
      ],
    );
  }

  group('MonthlySelectedCategoryCardUsecaseNotifier', () {
    test('予算内ならhasBudgetで比率は支出/予算', () async {
      final container = createCardContainer(
        budgets: const [
          BudgetEntity(
            id: 1,
            expenseBigCategoryId: 1,
            month: '202506',
            price: 30000,
          ),
        ],
      );

      final result = await container.read(
        monthlySelectedCategoryCardNotifierProvider(
          RequestMonthlyCateoryCard(bigId: 1, dateScope: dateScope),
        ).future,
      );

      expect(result.graphType, GraphType.hasBudget);
      expect(result.graphRatio, closeTo(20000 / 30000, 1e-9));
    });

    test('予算超過ならhasBudgetButOverで比率は予算/支出', () async {
      final container = createCardContainer(
        budgets: const [
          BudgetEntity(
            id: 1,
            expenseBigCategoryId: 1,
            month: '202506',
            price: 15000,
          ),
        ],
      );

      final result = await container.read(
        monthlySelectedCategoryCardNotifierProvider(
          RequestMonthlyCateoryCard(bigId: 1, dateScope: dateScope),
        ).future,
      );

      // バー上の予算到達点の比率（予算/支出）が入る
      expect(result.graphType, GraphType.hasBudgetButOver);
      expect(result.graphRatio, closeTo(15000 / 20000, 1e-9));
    });

    test('予算が無ければnoBudgetで比率は0', () async {
      final container = createCardContainer();

      final result = await container.read(
        monthlySelectedCategoryCardNotifierProvider(
          RequestMonthlyCateoryCard(bigId: 1, dateScope: dateScope),
        ).future,
      );

      expect(result.graphType, GraphType.noBudget);
      expect(result.graphRatio, 0.0);
      expect(result.monthlyBudget, 0);
    });

    test('指定した大カテゴリーの情報と小カテゴリーリストを取得する', () async {
      final container = createCardContainer(
        budgets: const [
          BudgetEntity(
            id: 2,
            expenseBigCategoryId: 2,
            month: '202506',
            price: 8000,
          ),
        ],
      );

      final result = await container.read(
        monthlySelectedCategoryCardNotifierProvider(
          RequestMonthlyCateoryCard(bigId: 2, dateScope: dateScope),
        ).future,
      );

      expect(result.monthlyExpenseByCategoryEntity.id, 2);
      expect(result.monthlyExpenseByCategoryEntity.bigCategoryName, '日用品');
      expect(result.monthlyExpense, 5000);
      expect(result.monthlyBudget, 8000);
      expect(result.smallCategoryList.map((e) => e.smallCategoryName), ['消耗品']);
    });

    test('graphDenomiratorRatioは予算あり・予算超過のどちらでも1.0', () async {
      final withinBudgetContainer = createCardContainer(
        budgets: const [
          BudgetEntity(
            id: 1,
            expenseBigCategoryId: 1,
            month: '202506',
            price: 30000,
          ),
        ],
      );
      final overBudgetContainer = createCardContainer(
        budgets: const [
          BudgetEntity(
            id: 1,
            expenseBigCategoryId: 1,
            month: '202506',
            price: 15000,
          ),
        ],
      );
      final noBudgetContainer = createCardContainer();

      final withinBudget = await withinBudgetContainer.read(
        monthlySelectedCategoryCardNotifierProvider(
          RequestMonthlyCateoryCard(bigId: 1, dateScope: dateScope),
        ).future,
      );
      final overBudget = await overBudgetContainer.read(
        monthlySelectedCategoryCardNotifierProvider(
          RequestMonthlyCateoryCard(bigId: 1, dateScope: dateScope),
        ).future,
      );
      final noBudget = await noBudgetContainer.read(
        monthlySelectedCategoryCardNotifierProvider(
          RequestMonthlyCateoryCard(bigId: 1, dateScope: dateScope),
        ).future,
      );

      expect(withinBudget.graphDenomiratorRatio, 1.0);
      expect(overBudget.graphDenomiratorRatio, 1.0);
      expect(noBudget.graphDenomiratorRatio, 0.0);
    });
  });
}
