import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/category/category_selection_provider.dart';
import 'package:kakeibo/domain/core/category_entity/expense_category_entity/expense_category_entity.dart';
import 'package:kakeibo/domain/core/category_entity/i_category_entity.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  /// getButtonStatus に渡す支出カテゴリーを1件作る
  ExpenseCategoryEntity buildExpenseCategory({
    required int id,
    required String name,
  }) {
    return ExpenseCategoryEntity(
      id: id,
      smallCategoryOrderKey: id,
      bigCategoryKey: 1,
      displaydOrderInBig: 1,
      categoryName: name,
      defaultDisplayed: 1,
      bigCategoryName: '生活費',
      colorCode: 'FFAA00',
      resourcePath: 'assets/images/icon_life.svg',
      displayOrder: 1,
      isDisplayed: 1,
    );
  }

  // ボタン3枠に対してカテゴリーは3件
  final List<ICategoryEntity> categories = [
    buildExpenseCategory(id: 11, name: '日用品'),
    buildExpenseCategory(id: 10, name: '食費'),
    buildExpenseCategory(id: 12, name: '交通費'),
  ];

  // 支出小カテゴリー（表示順は smallCategoryOrderKey の昇順＝日用品→食費→交通費）
  const expenseSmallCategories = [
    ExpenseSmallCategoryEntity(
      id: 10,
      smallCategoryOrderKey: 2,
      bigCategoryKey: 1,
      displayedOrderInBig: 1,
      smallCategoryName: '食費',
      defaultDisplayed: 1,
    ),
    ExpenseSmallCategoryEntity(
      id: 11,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 1,
      displayedOrderInBig: 2,
      smallCategoryName: '日用品',
      defaultDisplayed: 1,
    ),
    ExpenseSmallCategoryEntity(
      id: 12,
      smallCategoryOrderKey: 3,
      bigCategoryKey: 2,
      displayedOrderInBig: 1,
      smallCategoryName: '交通費',
      defaultDisplayed: 1,
    ),
  ];

  // 支出大カテゴリー（1:生活費 / 2:交通）
  const expenseBigCategories = [
    ExpenseBigCategoryEntity(
      id: 1,
      colorCode: 'FFAA00',
      bigCategoryName: '生活費',
      resourcePath: 'assets/images/icon_life.svg',
      displayOrder: 1,
      isDisplayed: 1,
    ),
    ExpenseBigCategoryEntity(
      id: 2,
      colorCode: '00AAFF',
      bigCategoryName: '交通',
      resourcePath: 'assets/images/icon_train.svg',
      displayOrder: 2,
      isDisplayed: 1,
    ),
  ];

  // 固定費カテゴリー
  const fixedCostCategories = [
    FixedCostCategoryEntity(
      id: 1,
      categoryName: '住居',
      colorCode: 'FFAA00',
      resourcePath: 'assets/images/icon_home.svg',
    ),
  ];

  // 収入カテゴリー（小1:給与→大1）
  const incomeSmallCategories = [
    IncomeSmallCategoryEntity(
      id: 1,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 1,
      displayedOrderInBig: 1,
      smallCategoryName: '給与',
      defaultDisplayed: 1,
    ),
  ];
  const incomeBigCategories = [
    IncomeBigCategoryEntity(
      id: 1,
      name: '給与',
      colorCode: '0000FF',
      iconPath: 'assets/images/icon_salary.svg',
    ),
  ];

  ProviderContainer createCategoryContainer() {
    return createContainer(
      overrides: [
        expenseSmallCategoryRepositoryProvider.overrideWithValue(
          FakeExpenseSmallCategoryRepository(
            initialRecords: expenseSmallCategories,
          ),
        ),
        expensebigCategoryRepositoryProvider.overrideWithValue(
          FakeExpenseBigCategoryRepository(
            initialRecords: expenseBigCategories,
          ),
        ),
        fixedCostCategoryRepositoryProvider.overrideWithValue(
          FakeFixedCostCategoryRepository(initialRecords: fixedCostCategories),
        ),
        incomeSmallCategoryRepositoryProvider.overrideWithValue(
          FakeIncomeSmallCategoryRepository(
            initialRecords: incomeSmallCategories,
          ),
        ),
        incomeBigCategoryRepositoryProvider.overrideWithValue(
          FakeIncomeBigCategoryRepository(initialRecords: incomeBigCategories),
        ),
      ],
    );
  }

  group('getButtonStatus', () {
    test('ボタン番号がカテゴリー数以上ならnone', () {
      final status = getButtonStatus(
        buttonNumber: 3,
        categoryCount: categories.length,
        selectedCategoryId: 11,
        categories: categories,
      );

      expect(status, ButtonStatus.none);
    });

    test('選択中のカテゴリーIDと一致すればselected', () {
      final status = getButtonStatus(
        buttonNumber: 1,
        categoryCount: categories.length,
        selectedCategoryId: 10,
        categories: categories,
      );

      expect(status, ButtonStatus.selected);
    });

    test('範囲内で選択中でもなければnormal', () {
      final status = getButtonStatus(
        buttonNumber: 2,
        categoryCount: categories.length,
        selectedCategoryId: 10,
        categories: categories,
      );

      expect(status, ButtonStatus.normal);
    });
  });

  group('categoryPaginationProvider', () {
    test('1ページ15件でページ数が決まる', () {
      final container = createContainer();

      // ちょうど15件なら1ページ、16件で2ページ、0件なら0ページ
      expect(container.read(categoryPaginationProvider(15)).pageCount, 1);
      expect(container.read(categoryPaginationProvider(16)).pageCount, 2);
      expect(container.read(categoryPaginationProvider(0)).pageCount, 0);
      expect(container.read(categoryPaginationProvider(15)).itemsPerPage, 15);
    });
  });

  group('categoryByModeProvider', () {
    test('categoryIdが0以下なら先頭のカテゴリーを返す', () async {
      final container = createCategoryContainer();

      final zero = await container.read(
        categoryByModeProvider(
          mode: TransactionMode.expense,
          categoryId: 0,
        ).future,
      );
      final negative = await container.read(
        categoryByModeProvider(
          mode: TransactionMode.expense,
          categoryId: -1,
        ).future,
      );

      // 表示順の先頭は smallCategoryOrderKey が最小の「日用品」
      expect(zero.id, 11);
      expect(zero.categoryName, '日用品');
      expect(negative.id, 11);
    });

    test('カテゴリーが1件も無いなら未選択（ID 0）のカテゴリーを返す', () async {
      // 支出小カテゴリーだけ空にする（マスタ検索へ進むと該当なしで落ちる状態）
      final container = createContainer(
        overrides: [
          expenseSmallCategoryRepositoryProvider.overrideWithValue(
            FakeExpenseSmallCategoryRepository(initialRecords: const []),
          ),
          expensebigCategoryRepositoryProvider.overrideWithValue(
            FakeExpenseBigCategoryRepository(
              initialRecords: expenseBigCategories,
            ),
          ),
        ],
      );

      final category = await container.read(
        categoryByModeProvider(
          mode: TransactionMode.expense,
          categoryId: 0,
        ).future,
      );

      expect(category.id, 0);
      expect(category.categoryName, '');
    });
  });

  group('categoriesByModeProvider', () {
    test('modeごとに対応するカテゴリー一覧が返る', () async {
      final container = createCategoryContainer();

      final expense = await container.read(
        categoriesByModeProvider(TransactionMode.expense).future,
      );
      final fixedCost = await container.read(
        categoriesByModeProvider(TransactionMode.fixedCost).future,
      );
      final income = await container.read(
        categoriesByModeProvider(TransactionMode.income).future,
      );

      // 支出は smallCategoryOrderKey の昇順に並ぶ
      expect(expense.map((e) => e.categoryName), ['日用品', '食費', '交通費']);
      expect(expense.map((e) => e.sortKey), [0, 1, 2]);
      expect(fixedCost.map((e) => e.categoryName), ['住居']);
      expect(income.map((e) => e.categoryName), ['給与']);
    });
  });
}
