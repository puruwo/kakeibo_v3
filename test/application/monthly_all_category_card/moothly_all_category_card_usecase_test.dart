import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/monthly_all_category_card/moothly_all_category_card_usecase.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_entity.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_repository.dart';
import 'package:kakeibo/domain/db/budget/budget_entity.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/all_category_card_value/all_category_card_entity.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  // 集計期間は2025/6/25〜2025/7/24、代表月は202506
  final dateScope = buildDateScope();

  // 収入小カテゴリー（1:給与→大1 / 2:賞与→大2(ボーナス) / 3:副業→大1）
  const incomeSmallCategories = [
    IncomeSmallCategoryEntity(
      id: 1,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 1,
      displayedOrderInBig: 1,
      smallCategoryName: '給与',
      defaultDisplayed: 1,
    ),
    IncomeSmallCategoryEntity(
      id: 2,
      smallCategoryOrderKey: 2,
      bigCategoryKey: 2,
      displayedOrderInBig: 1,
      smallCategoryName: '賞与',
      defaultDisplayed: 1,
    ),
    IncomeSmallCategoryEntity(
      id: 3,
      smallCategoryOrderKey: 3,
      bigCategoryKey: 1,
      displayedOrderInBig: 2,
      smallCategoryName: '副業',
      defaultDisplayed: 1,
    ),
  ];

  // 収入大カテゴリー（1:給与 / 2:ボーナス）
  const incomeBigCategories = [
    IncomeBigCategoryEntity(
      id: 1,
      name: '給与',
      colorCode: '0000FF',
      iconPath: '',
      accountType: 1, // 生活収支
    ),
    IncomeBigCategoryEntity(
      id: 2,
      name: 'ボーナス',
      colorCode: 'FF00FF',
      iconPath: '',
      accountType: 2, // 特別枠
    ),
  ];

  // 収入小カテゴリーID → 大カテゴリーID
  const smallCategoryToBigCategory = {1: 1, 2: 2, 3: 1};

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

  /// カードのProviderをテストするコンテナを組み立てる
  ///
  /// [totalExpense] は期間・拠出元で絞った支出合計。
  /// v10で固定費実績もexpenseに入るため、固定費分もこの値に含まれる（仕様 §7.1）。
  /// [categories] を省略すると、その支出額を持つ「食費」1件だけになる。
  ProviderContainer createCardContainer({
    int totalExpense = 0,
    List<BudgetEntity> budgets = const [],
    List<IncomeEntity> incomes = const [],
    List<CategoryAccountingEntity>? categories,
  }) {
    final fakeExpenseRepository = FakeExpenseRepository()
      ..totalExpenseByPeriodWithBigCategoryResult = totalExpense;
    return createContainer(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(fakeExpenseRepository),
        budgetRepositoryProvider.overrideWithValue(
          FakeBudgetRepository(initialRecords: budgets),
        ),
        incomeRepositoryProvider.overrideWithValue(
          FakeIncomeRepository(
            initialRecords: incomes,
            smallCategoryToBigCategory: smallCategoryToBigCategory,
          ),
        ),
        incomeBigCategoryRepositoryProvider.overrideWithValue(
          FakeIncomeBigCategoryRepository(initialRecords: incomeBigCategories),
        ),
        incomeSmallCategoryRepositoryProvider.overrideWithValue(
          FakeIncomeSmallCategoryRepository(
            initialRecords: incomeSmallCategories,
          ),
        ),
        categoryAccountingRepositoryProvider.overrideWithValue(
          FakeCategoryAccountingRepository(
            categories:
                categories ??
                [buildCategory(id: 1, name: '食費', totalExpense: totalExpense)],
          ),
        ),
      ],
    );
  }

  /// 給与カテゴリーの収入を1件作る
  IncomeEntity buildIncome({
    required int id,
    required int categoryId,
    required int price,
  }) {
    return IncomeEntity(
      id: id,
      categoryId: categoryId,
      date: '20250701',
      price: price,
    );
  }

  group('MonthlyAllCategoryTileUsecaseNotifier の予算合計', () {
    test('カテゴリー予算が0なら予算合計は0', () async {
      // 支出130000のうち80000は固定費行だが、expenseの単一集計に含まれている
      final container = createCardContainer(totalExpense: 130000);

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.allCategoryTotalBudget, 0);
      expect(result.allCategoryTotalExpense, 130000);
    });

    test('予算合計はカテゴリー予算の合計のみで固定費は加算されない', () async {
      // 固定費の自動加算は廃止（仕様 §7.3）。加算が残っていると 30000+80000 になる
      final container = createCardContainer(
        totalExpense: 130000,
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
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.allCategoryTotalBudget, 30000);
    });

    test('複数カテゴリーの予算はそのまま合算される', () async {
      final container = createCardContainer(
        totalExpense: 130000,
        categories: [
          buildCategory(id: 1, name: '食費', totalExpense: 50000),
          buildCategory(id: 2, name: '住居', totalExpense: 80000),
        ],
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
            price: 90000,
          ),
        ],
      );

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.allCategoryTotalBudget, 120000);
    });
  });

  group('MonthlyAllCategoryTileUsecaseNotifier のステータス判定', () {
    test('支出も収入も予算も無ければnoDataで分母は0', () async {
      final container = createCardContainer();

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.cardStatusType, AllCategoryCardStatusType.noData);
      expect(result.denominator, 0);
    });

    test('支出だけならhasOnlyExpenseで分母は支出', () async {
      final container = createCardContainer(totalExpense: 50000);

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.cardStatusType, AllCategoryCardStatusType.hasOnlyExpense);
      expect(result.denominator, 50000);
    });

    test('収入だけで支出が収入以内ならhasOnlyIncomeで分母は収入', () async {
      final container = createCardContainer(
        totalExpense: 50000,
        incomes: [buildIncome(id: 1, categoryId: 1, price: 200000)],
      );

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.cardStatusType, AllCategoryCardStatusType.hasOnlyIncome);
      expect(result.denominator, 200000);
    });

    test('収入だけで支出が収入を超えていればhasIncomeAndOverで分母は支出', () async {
      final container = createCardContainer(
        totalExpense: 250000,
        incomes: [buildIncome(id: 1, categoryId: 1, price: 200000)],
      );

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.cardStatusType, AllCategoryCardStatusType.hasIncomeAndOver);
      expect(result.denominator, 250000);
    });

    test('予算だけで支出が予算以内ならhasOnlyBudgetで分母は予算', () async {
      final container = createCardContainer(
        totalExpense: 20000,
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
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.cardStatusType, AllCategoryCardStatusType.hasOnlyBudget);
      expect(result.denominator, 30000);
    });

    test('予算だけで支出が予算を超えていればhasBudgetAndOverで分母は支出', () async {
      final container = createCardContainer(
        totalExpense: 40000,
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
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.cardStatusType, AllCategoryCardStatusType.hasBudgetAndOver);
      expect(result.denominator, 40000);
    });

    test('予算<収入<支出ならhasBudgetIncomeExpenseOverで分母は支出', () async {
      final container = createCardContainer(
        totalExpense: 300000,
        budgets: const [
          BudgetEntity(
            id: 1,
            expenseBigCategoryId: 1,
            month: '202506',
            price: 100000,
          ),
        ],
        incomes: [buildIncome(id: 1, categoryId: 1, price: 200000)],
      );

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(
        result.cardStatusType,
        AllCategoryCardStatusType.hasBudgetIncomeExpenseOver,
      );
      expect(result.denominator, 300000);
    });

    test('予算<支出<収入ならhasBudgetExpenseIncomeOverで分母は収入', () async {
      final container = createCardContainer(
        totalExpense: 100000,
        budgets: const [
          BudgetEntity(
            id: 1,
            expenseBigCategoryId: 1,
            month: '202506',
            price: 50000,
          ),
        ],
        incomes: [buildIncome(id: 1, categoryId: 1, price: 150000)],
      );

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(
        result.cardStatusType,
        AllCategoryCardStatusType.hasBudgetExpenseIncomeOver,
      );
      expect(result.denominator, 150000);
    });

    test('収入<予算<支出ならhasIncomeBudgetExpenseOverで分母は支出', () async {
      final container = createCardContainer(
        totalExpense: 150000,
        budgets: const [
          BudgetEntity(
            id: 1,
            expenseBigCategoryId: 1,
            month: '202506',
            price: 100000,
          ),
        ],
        incomes: [buildIncome(id: 1, categoryId: 1, price: 50000)],
      );

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(
        result.cardStatusType,
        AllCategoryCardStatusType.hasIncomeBudgetExpenseOver,
      );
      expect(result.denominator, 150000);
    });

    test('支出が予算も収入も超えていなければhasBudgetAndIncomeNotOverで分母は収入と予算の大きい方', () async {
      // 収入200000 > 予算100000 → 分母は収入
      final incomeIsLargerContainer = createCardContainer(
        totalExpense: 50000,
        budgets: const [
          BudgetEntity(
            id: 1,
            expenseBigCategoryId: 1,
            month: '202506',
            price: 100000,
          ),
        ],
        incomes: [buildIncome(id: 1, categoryId: 1, price: 200000)],
      );
      // 予算100000 > 収入50000 → 分母は予算
      final budgetIsLargerContainer = createCardContainer(
        totalExpense: 20000,
        budgets: const [
          BudgetEntity(
            id: 1,
            expenseBigCategoryId: 1,
            month: '202506',
            price: 100000,
          ),
        ],
        incomes: [buildIncome(id: 1, categoryId: 1, price: 50000)],
      );

      final incomeIsLarger = await incomeIsLargerContainer.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );
      final budgetIsLarger = await budgetIsLargerContainer.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(
        incomeIsLarger.cardStatusType,
        AllCategoryCardStatusType.hasBudgetAndIncomeNotOver,
      );
      expect(incomeIsLarger.denominator, 200000);
      expect(
        budgetIsLarger.cardStatusType,
        AllCategoryCardStatusType.hasBudgetAndIncomeNotOver,
      );
      expect(budgetIsLarger.denominator, 100000);
    });
  });

  group('MonthlyAllCategoryTileUsecaseNotifier の高収入スケール調整', () {
    test('予算があり支出が予算を超えていれば分母は支出になる', () async {
      final container = createCardContainer(
        totalExpense: 200000,
        budgets: const [
          BudgetEntity(
            id: 1,
            expenseBigCategoryId: 1,
            month: '202506',
            price: 100000,
          ),
        ],
        incomes: [buildIncome(id: 1, categoryId: 1, price: 400000)],
      );

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.denominator, 200000);
    });

    test('予算が無く収入が支出の4倍を超えていれば分母は支出の2倍になる', () async {
      final container = createCardContainer(
        totalExpense: 50000,
        incomes: [buildIncome(id: 1, categoryId: 1, price: 400000)],
      );

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.denominator, 100000);
    });

    test('予算があり収入が予算の5/3を超えていれば分母は予算の5/3になる', () async {
      final container = createCardContainer(
        totalExpense: 100000,
        budgets: const [
          BudgetEntity(
            id: 1,
            expenseBigCategoryId: 1,
            month: '202506',
            price: 200000,
          ),
        ],
        incomes: [buildIncome(id: 1, categoryId: 1, price: 400000)],
      );

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.denominator, (200000 * 5 / 3).round());
    });
  });

  group('MonthlyAllCategoryTileUsecaseNotifier の内訳', () {
    test('支出内訳は支出カテゴリーの集計だけで構成される（固定費の後付け追加なし）', () async {
      // 固定費行も同じ支出カテゴリーに集計されるため、内訳へ別枠で足さない（仕様 §7.1）
      final container = createCardContainer(
        totalExpense: 136000,
        categories: [
          buildCategory(id: 1, name: '食費', totalExpense: 50000),
          buildCategory(id: 2, name: '住居', totalExpense: 80000),
          buildCategory(id: 3, name: '光熱費', totalExpense: 6000),
        ],
      );

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.expenseCategoryNameList, ['食費', '住居', '光熱費']);
      expect(result.expenseCategoryList, [50000, 80000, 6000]);
      expect(
        result.expenseCategoryIconPathList.last,
        'assets/images/icon_3.svg',
      );
    });

    test('収入内訳はボーナスと0円のカテゴリーを除外する', () async {
      final container = createCardContainer(
        totalExpense: 50000,
        incomes: [
          buildIncome(id: 1, categoryId: 1, price: 200000),
          // 会計種別=特別枠（ボーナス）は集計にも内訳にも含めない
          buildIncome(id: 2, categoryId: 2, price: 100000),
          // 副業は0円なので内訳に出ない
          buildIncome(id: 3, categoryId: 3, price: 0),
        ],
      );

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.allCategoryTotalIncome, 200000);
      expect(result.incomeCategoryNameList, ['給与']);
      expect(result.incomeCategoryList, [200000]);
      // 親大カテゴリーのカラーコードが適用される
      expect(result.incomeCategoryColorList, ['0000FF']);
    });

    test('予算内訳は金額が入っているカテゴリーだけになる', () async {
      final container = createCardContainer(
        totalExpense: 50000,
        categories: [
          buildCategory(id: 1, name: '食費', totalExpense: 30000),
          buildCategory(id: 2, name: '日用品', totalExpense: 20000),
        ],
        budgets: const [
          BudgetEntity(
            id: 1,
            expenseBigCategoryId: 1,
            month: '202506',
            price: 30000,
          ),
          // 0円の予算は内訳に出ない
          BudgetEntity(
            id: 2,
            expenseBigCategoryId: 2,
            month: '202506',
            price: 0,
          ),
        ],
      );

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      // 固定費カテゴリーのセグメントは追加されない（仕様 §7.3）
      expect(result.budgetCategoryNameList, ['食費']);
      expect(result.budgetCategoryList, [30000]);
    });

    test('支出と収入の比率リストは分母で割った値になる', () async {
      final container = createCardContainer(
        totalExpense: 130000,
        categories: [
          buildCategory(id: 1, name: '食費', totalExpense: 50000),
          buildCategory(id: 2, name: '住居', totalExpense: 80000),
        ],
        incomes: [buildIncome(id: 1, categoryId: 1, price: 200000)],
      );

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      // 支出130000 < 収入200000 なので分母は収入
      expect(result.denominator, 200000);
      expect(result.expenseCategoryRatioList, [
        closeTo(50000 / 200000, 1e-9),
        closeTo(80000 / 200000, 1e-9),
      ]);
      expect(result.incomeCategoryRatioList, [closeTo(1.0, 1e-9)]);
      expect(result.realSavings, 70000);
    });
  });
}
