import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/monthly_category_card/moothly_category_card_usecase.dart';
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

  // 大カテゴリー（1:食費 / 2:日用品 / 3:趣味）
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

  // 小カテゴリータイル（この合計がカードの支出額になる）
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
      recordCount: expense == 0 ? 0 : 1,
    );
  }

  ProviderContainer createCardContainer({
    required List<CategoryAccountingEntity> categories,
    required Map<int, List<SmallCategoryTileEntity>> tilesByBigCategoryId,
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

  group('MonthlyCategoryCardUsecaseNotifier', () {
    test('予算があり支出が予算以内ならhasBudgetで比率は支出/予算', () async {
      final container = createCardContainer(
        categories: [buildCategory(id: 1, name: '食費', totalExpense: 20000)],
        tilesByBigCategoryId: {
          1: [buildTile(id: 11, name: '外食', expense: 20000)],
        },
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
        monthlyCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.single.graphType, GraphType.hasBudget);
      expect(result.single.monthlyBudget, 30000);
      expect(result.single.graphRatio, closeTo(20000 / 30000, 1e-9));
    });

    test('予算があり支出が予算を超えていればhasBudgetButOverで比率は予算/支出', () async {
      final container = createCardContainer(
        categories: [buildCategory(id: 1, name: '食費', totalExpense: 40000)],
        tilesByBigCategoryId: {
          1: [buildTile(id: 11, name: '外食', expense: 40000)],
        },
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
        monthlyCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.single.graphType, GraphType.hasBudgetButOver);
      expect(result.single.graphRatio, closeTo(30000 / 40000, 1e-9));
    });

    test('予算も支出も無ければnoExpenseNoBudgetで比率は0', () async {
      final container = createCardContainer(
        categories: [
          buildCategory(id: 1, name: '食費', totalExpense: 20000),
          buildCategory(id: 2, name: '日用品'),
        ],
        tilesByBigCategoryId: {
          1: [buildTile(id: 11, name: '外食', expense: 20000)],
          2: [buildTile(id: 21, name: '消耗品', expense: 0)],
        },
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
        monthlyCategoryCardNotifierProvider(dateScope).future,
      );

      final daily = result.firstWhere(
        (e) => e.monthlyExpenseByCategoryEntity.id == 2,
      );
      expect(daily.graphType, GraphType.noExpenseNoBudget);
      expect(daily.graphRatio, 0.0);
    });

    test('他カテゴリーに予算があり自分に予算が無ければnoBudgetOtherHasBudget', () async {
      final container = createCardContainer(
        categories: [
          buildCategory(id: 1, name: '食費', totalExpense: 20000),
          buildCategory(id: 2, name: '日用品', totalExpense: 5000),
        ],
        tilesByBigCategoryId: {
          1: [buildTile(id: 11, name: '外食', expense: 20000)],
          2: [buildTile(id: 21, name: '消耗品', expense: 5000)],
        },
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
        monthlyCategoryCardNotifierProvider(dateScope).future,
      );

      final daily = result.firstWhere(
        (e) => e.monthlyExpenseByCategoryEntity.id == 2,
      );
      expect(daily.graphType, GraphType.noBudgetOtherHasBudget);
      expect(daily.graphRatio, 0.0);
    });

    test('全カテゴリーに予算が無ければallNoBudgetになり最大支出を分母に比率を再計算する', () async {
      final container = createCardContainer(
        categories: [
          buildCategory(id: 1, name: '食費', totalExpense: 20000),
          buildCategory(id: 2, name: '日用品', totalExpense: 5000),
        ],
        tilesByBigCategoryId: {
          1: [buildTile(id: 11, name: '外食', expense: 20000)],
          2: [buildTile(id: 21, name: '消耗品', expense: 5000)],
        },
      );

      final result = await container.read(
        monthlyCategoryCardNotifierProvider(dateScope).future,
      );

      expect(
        result.map((e) => e.graphType),
        everyElement(GraphType.allNoBudget),
      );
      // 最大支出（20000）が分母になる
      expect(result.first.graphRatio, closeTo(1.0, 1e-9));
      expect(result.last.graphRatio, closeTo(5000 / 20000, 1e-9));
    });

    test('全カテゴリーに予算が無くても支出0のカテゴリーはnoExpenseNoBudgetのまま', () async {
      final container = createCardContainer(
        categories: [
          buildCategory(id: 1, name: '食費', totalExpense: 20000),
          buildCategory(id: 2, name: '日用品'),
        ],
        tilesByBigCategoryId: {
          1: [buildTile(id: 11, name: '外食', expense: 20000)],
          2: [buildTile(id: 21, name: '消耗品', expense: 0)],
        },
      );

      final result = await container.read(
        monthlyCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.first.graphType, GraphType.allNoBudget);
      expect(result.last.graphType, GraphType.noExpenseNoBudget);
      expect(result.last.graphRatio, 0.0);
    });

    test('カードの支出額は小カテゴリータイルの合計になる', () async {
      final container = createCardContainer(
        categories: [
          // 大カテゴリー側の集計値ではなく小カテゴリーの合計が使われる
          buildCategory(id: 1, name: '食費', totalExpense: 999999),
        ],
        tilesByBigCategoryId: {
          1: [
            buildTile(id: 11, name: '外食', expense: 12000),
            buildTile(id: 12, name: '食料品', expense: 8000),
            buildTile(id: 13, name: 'カフェ', expense: 0),
          ],
        },
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
        monthlyCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.single.monthlyExpense, 20000);
      expect(result.single.smallCategoryList, hasLength(3));
    });

    test('graphDenomiratorRatioは予算ありのカードだけ1.0で他はnull', () async {
      final container = createCardContainer(
        categories: [
          buildCategory(id: 1, name: '食費', totalExpense: 20000),
          buildCategory(id: 2, name: '日用品', totalExpense: 40000),
          buildCategory(id: 3, name: '趣味', totalExpense: 5000),
        ],
        tilesByBigCategoryId: {
          1: [buildTile(id: 11, name: '外食', expense: 20000)],
          2: [buildTile(id: 21, name: '消耗品', expense: 40000)],
          3: [buildTile(id: 31, name: '書籍', expense: 5000)],
        },
        budgets: const [
          BudgetEntity(
            id: 1,
            expenseBigCategoryId: 1,
            month: '202506',
            price: 30000,
          ),
          BudgetEntity(
            id: 2,
            expenseBigCategoryId: 2,
            month: '202506',
            price: 30000,
          ),
        ],
      );

      final result = await container.read(
        monthlyCategoryCardNotifierProvider(dateScope).future,
      );

      // 予算内(hasBudget) / 予算超過(hasBudgetButOver) はどちらも1.0
      expect(result[0].graphType, GraphType.hasBudget);
      expect(result[0].graphDenomiratorRatio, 1.0);
      expect(result[1].graphType, GraphType.hasBudgetButOver);
      expect(result[1].graphDenomiratorRatio, 1.0);
      // 予算なしのカードはnull
      expect(result[2].graphType, GraphType.noBudgetOtherHasBudget);
      expect(result[2].graphDenomiratorRatio, isNull);
    });
  });
}
