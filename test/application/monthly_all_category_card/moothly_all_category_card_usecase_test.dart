import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/monthly_all_category_card/moothly_all_category_card_usecase.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_entity.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_repository.dart';
import 'package:kakeibo/domain/db/budget/budget_entity.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
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
  /// [normalExpense] は固定費を除いた通常カテゴリーの支出合計。
  /// [categories] を省略すると、その支出額を持つ「食費」1件だけになる。
  ProviderContainer createCardContainer({
    int normalExpense = 0,
    List<BudgetEntity> budgets = const [],
    List<IncomeEntity> incomes = const [],
    List<CategoryAccountingEntity>? categories,
    List<FixedCostCategoryEntity> fixedCostCategories = const [],
    List<FixedCostExpenseEntity> fixedCostExpenses = const [],
    List<FixedCostEntity> fixedCosts = const [],
  }) {
    final fakeExpenseRepository = FakeExpenseRepository()
      ..totalExpenseByPeriodWithBigCategoryResult = normalExpense;
    return createContainer(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(fakeExpenseRepository),
        fixedCostExpenseRepositoryProvider.overrideWithValue(
          FakeFixedCostExpenseRepository(initialRecords: fixedCostExpenses),
        ),
        fixedCostRepositoryProvider.overrideWithValue(
          FakeFixedCostRepository(initialRecords: fixedCosts),
        ),
        fixedCostCategoryRepositoryProvider.overrideWithValue(
          FakeFixedCostCategoryRepository(initialRecords: fixedCostCategories),
        ),
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
                [buildCategory(id: 1, name: '食費', totalExpense: normalExpense)],
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

  // 固定費カテゴリー（1:住居 / 2:光熱費）
  const fixedCostCategories = [
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

  // 固定費マスタ（30は想定額6000の変動費）
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
  ];

  // 確定済みの家賃80000（住居）と未確定の電気代（光熱費・推定6000）
  const confirmedRent = FixedCostExpenseEntity(
    id: 100,
    fixedCostId: 10,
    fixedCostCategoryId: 1,
    date: '20250701',
    price: 80000,
    name: '家賃',
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

  group('MonthlyAllCategoryTileUsecaseNotifier の予算合計', () {
    test('通常カテゴリーの予算が0なら固定費があっても予算合計は0', () async {
      final container = createCardContainer(
        normalExpense: 50000,
        fixedCostCategories: fixedCostCategories,
        fixedCosts: fixedCosts,
        fixedCostExpenses: const [confirmedRent],
      );

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.allCategoryTotalBudget, 0);
      expect(result.allFixedCostExpense, 80000);
      expect(result.allCategoryTotalExpense, 130000);
    });

    test('通常カテゴリーの予算があれば予算合計は通常予算＋固定費', () async {
      final container = createCardContainer(
        normalExpense: 50000,
        budgets: const [
          BudgetEntity(
            id: 1,
            expenseBigCategoryId: 1,
            month: '202506',
            price: 30000,
          ),
        ],
        fixedCostCategories: fixedCostCategories,
        fixedCosts: fixedCosts,
        fixedCostExpenses: const [confirmedRent],
      );

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.allCategoryTotalBudget, 110000);
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
      final container = createCardContainer(normalExpense: 50000);

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.cardStatusType, AllCategoryCardStatusType.hasOnlyExpense);
      expect(result.denominator, 50000);
    });

    test('収入だけで支出が収入以内ならhasOnlyIncomeで分母は収入', () async {
      final container = createCardContainer(
        normalExpense: 50000,
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
        normalExpense: 250000,
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
        normalExpense: 20000,
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
        normalExpense: 40000,
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
        normalExpense: 300000,
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
        normalExpense: 100000,
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
        normalExpense: 150000,
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
        normalExpense: 50000,
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
        normalExpense: 20000,
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
        normalExpense: 200000,
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
        normalExpense: 50000,
        incomes: [buildIncome(id: 1, categoryId: 1, price: 400000)],
      );

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.denominator, 100000);
    });

    test('予算があり収入が予算の5/3を超えていれば分母は予算の5/3になる', () async {
      final container = createCardContainer(
        normalExpense: 100000,
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
    test('固定費カテゴリー別の合計が支出内訳の末尾に追加される', () async {
      final container = createCardContainer(
        normalExpense: 50000,
        fixedCostCategories: fixedCostCategories,
        fixedCosts: fixedCosts,
        fixedCostExpenses: const [confirmedRent, unconfirmedElectricity],
      );

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      expect(result.expenseCategoryNameList, ['食費', '住居', '光熱費']);
      // 住居は確定80000、光熱費は未確定の推定額6000
      expect(result.expenseCategoryList, [50000, 80000, 6000]);
      expect(
        result.expenseCategoryIconPathList.last,
        'assets/images/icon_utility.svg',
      );
      expect(result.allFixedCostExpense, 86000);
    });

    test('収入内訳はボーナスと0円のカテゴリーを除外する', () async {
      final container = createCardContainer(
        normalExpense: 50000,
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
        normalExpense: 50000,
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
        fixedCostCategories: fixedCostCategories,
        fixedCosts: fixedCosts,
        fixedCostExpenses: const [confirmedRent],
      );

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      // 通常カテゴリーの予算に続けて、固定費カテゴリーの実績が予算として並ぶ
      expect(result.budgetCategoryNameList, ['食費', '住居']);
      expect(result.budgetCategoryList, [30000, 80000]);
    });

    test('支出と収入の比率リストは分母で割った値になる', () async {
      final container = createCardContainer(
        normalExpense: 50000,
        incomes: [buildIncome(id: 1, categoryId: 1, price: 200000)],
        fixedCostCategories: fixedCostCategories,
        fixedCosts: fixedCosts,
        fixedCostExpenses: const [confirmedRent],
      );

      final result = await container.read(
        monthlyAllCategoryCardNotifierProvider(dateScope).future,
      );

      // 支出130000 < 収入200000 なので分母は収入
      expect(result.denominator, 200000);
      expect(result.expenseCategoryRatioList, [
        closeTo(50000 / 200000, 1e-9),
        closeTo(80000 / 200000, 1e-9),
        closeTo(0.0, 1e-9),
      ]);
      expect(result.incomeCategoryRatioList, [closeTo(1.0, 1e-9)]);
      expect(result.realSavings, 70000);
    });
  });
}
