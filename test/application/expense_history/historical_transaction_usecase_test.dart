import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/expense_history/historical_transaction_usecase.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_group_value.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/domain/ui_value/historical_all_transactions_value/historical_all_transactions_value.dart';
import 'package:kakeibo/domain/ui_value/income_history_tile_value/income_history_tile_value.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  // 集計期間は2025/6/25〜2025/7/24
  final period = PeriodValue(
    startDatetime: DateTime(2025, 6, 25),
    endDatetime: DateTime(2025, 7, 24),
  );

  // ---- groupTransactionsByDate 用のテストデータ組み立て ----

  ExpenseHistoryTileValue buildExpenseTile({
    required int id,
    required DateTime date,
    int price = 1000,
    int incomeSourceBigCategory = 1,
    int? fixedCostId,
    int isConfirmed = 1,
  }) {
    return ExpenseHistoryTileValue(
      id: id,
      date: date,
      price: price,
      paymentCategoryId: 10,
      smallCategoryName: '食費',
      bigCategoryName: '生活費',
      colorCode: 'FFAA00',
      iconPath: 'assets/images/icon_life.svg',
      incomeSourceBigCategory: incomeSourceBigCategory,
      fixedCostId: fixedCostId,
      isConfirmed: isConfirmed,
    );
  }

  IncomeHistoryTileValue buildIncomeTile({
    required int id,
    required DateTime date,
    int price = 300000,
  }) {
    return IncomeHistoryTileValue(
      id: id,
      date: date,
      price: price,
      paymentCategoryId: 1,
      smallCategoryName: '給与',
      bigCategoryName: '給与',
      colorCode: '0000FF',
      iconPath: 'assets/images/icon_salary.svg',
    );
  }

  // ---- build 用のマスタ・レコード ----

  // 支出小カテゴリー（10:食費→大1 / 11:日用品→大1 / 12:旅行→大2）
  const expenseSmallCategories = [
    ExpenseSmallCategoryEntity(
      id: 10,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 1,
      displayedOrderInBig: 1,
      smallCategoryName: '食費',
      defaultDisplayed: 1,
    ),
    ExpenseSmallCategoryEntity(
      id: 11,
      smallCategoryOrderKey: 2,
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
      smallCategoryName: '旅行',
      defaultDisplayed: 1,
    ),
  ];

  // 支出大カテゴリー（1:生活費 / 2:レジャー）
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
      bigCategoryName: 'レジャー',
      resourcePath: 'assets/images/icon_leisure.svg',
      displayOrder: 2,
      isDisplayed: 1,
    ),
  ];

  // 収入小カテゴリー（1:給与→大1 / 2:賞与→大2）
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
  ];

  // 収入大カテゴリー（1:給与 / 2:ボーナス）
  const incomeBigCategories = [
    IncomeBigCategoryEntity(
      id: 1,
      name: '給与',
      colorCode: '0000FF',
      iconPath: 'assets/images/icon_salary.svg',
    ),
    IncomeBigCategoryEntity(
      id: 2,
      name: 'ボーナス',
      colorCode: 'FF00FF',
      iconPath: 'assets/images/icon_bonus.svg',
    ),
  ];

  const smallCategoryToBigCategory = {1: 1, 2: 2};

  // 固定費マスタ（10:家賃 / 30:変動する電気代）
  const fixedCosts = [
    FixedCostEntity(
      id: 10,
      name: '家賃',
      variable: 0,
      price: 80000,
      fixedCostCategoryId: 1,
      expenseSmallCategoryId: 10,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
      // 期間（6/25〜7/24）より後にして未生成分として展開されないようにする
      nextPaymentDate: '20250801',
    ),
    FixedCostEntity(
      id: 30,
      name: '電気代',
      variable: 1,
      estimatedPrice: 6000,
      fixedCostCategoryId: 2,
      expenseSmallCategoryId: 12,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
      nextPaymentDate: '20250805',
    ),
  ];

  ProviderContainer createTransactionContainer({
    List<ExpenseEntity> expenses = const [],
    List<IncomeEntity> incomes = const [],
  }) {
    return createContainer(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(
          FakeExpenseRepository(initialRecords: expenses),
        ),
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
        incomeRepositoryProvider.overrideWithValue(
          FakeIncomeRepository(
            initialRecords: incomes,
            smallCategoryToBigCategory: smallCategoryToBigCategory,
          ),
        ),
        incomeSmallCategoryRepositoryProvider.overrideWithValue(
          FakeIncomeSmallCategoryRepository(
            initialRecords: incomeSmallCategories,
          ),
        ),
        incomeBigCategoryRepositoryProvider.overrideWithValue(
          FakeIncomeBigCategoryRepository(initialRecords: incomeBigCategories),
        ),
        fixedCostRepositoryProvider.overrideWithValue(
          FakeFixedCostRepository(initialRecords: fixedCosts),
        ),
      ],
    );
  }

  group('groupTransactionsByDate', () {
    test('4種の取引の日付がすべて集約される', () {
      final transactions = HistoricalAllTransactionsValue(
        expenses: [
          ExpenseHistoryTileGroupValue(
            date: DateTime(2025, 7, 1),
            expenseHistoryTileValueList: [
              buildExpenseTile(id: 1, date: DateTime(2025, 7, 1)),
            ],
          ),
        ],
        bonusExpenses: [buildExpenseTile(id: 2, date: DateTime(2025, 7, 2))],
        incomes: [buildIncomeTile(id: 3, date: DateTime(2025, 7, 3))],
        bonusIncomes: [buildIncomeTile(id: 4, date: DateTime(2025, 7, 4))],
      );

      final result = groupTransactionsByDate(transactions);

      expect(result, hasLength(4));
      expect(result.map((g) => g.date).toSet(), {
        DateTime(2025, 7, 1),
        DateTime(2025, 7, 2),
        DateTime(2025, 7, 3),
        DateTime(2025, 7, 4),
      });
    });

    test('日グループは日付の降順に並ぶ', () {
      final transactions = HistoricalAllTransactionsValue(
        expenses: [
          ExpenseHistoryTileGroupValue(
            date: DateTime(2025, 7, 1),
            expenseHistoryTileValueList: [
              buildExpenseTile(id: 1, date: DateTime(2025, 7, 1)),
            ],
          ),
          ExpenseHistoryTileGroupValue(
            date: DateTime(2025, 7, 10),
            expenseHistoryTileValueList: [
              buildExpenseTile(id: 2, date: DateTime(2025, 7, 10)),
            ],
          ),
        ],
        bonusExpenses: const [],
        incomes: [buildIncomeTile(id: 3, date: DateTime(2025, 7, 5))],
        bonusIncomes: const [],
      );

      final result = groupTransactionsByDate(transactions);

      expect(result.map((g) => g.date), [
        DateTime(2025, 7, 10),
        DateTime(2025, 7, 5),
        DateTime(2025, 7, 1),
      ]);
    });

    test('同じ日の各種別はその日のグループへ振り分けられる', () {
      final date = DateTime(2025, 7, 1);
      final transactions = HistoricalAllTransactionsValue(
        expenses: [
          ExpenseHistoryTileGroupValue(
            date: date,
            expenseHistoryTileValueList: [
              buildExpenseTile(id: 1, date: date),
              buildExpenseTile(id: 2, date: date),
              // 固定費行も同じ expenses に入る（v10）
              buildExpenseTile(id: 6, date: date, fixedCostId: 10),
            ],
          ),
        ],
        bonusExpenses: [
          buildExpenseTile(id: 3, date: date, incomeSourceBigCategory: 2),
        ],
        incomes: [buildIncomeTile(id: 4, date: date)],
        bonusIncomes: [buildIncomeTile(id: 5, date: date)],
      );

      final result = groupTransactionsByDate(transactions);

      expect(result, hasLength(1));
      final group = result.single;
      expect(group.date, date);
      expect(group.expenses.map((e) => e.id), [1, 2, 6]);
      expect(group.bonusExpenses.map((e) => e.id), [3]);
      expect(group.incomes.map((e) => e.id), [4]);
      expect(group.bonusIncomes.map((e) => e.id), [5]);
    });

    test('その日に存在しない種別は空リストになる', () {
      final transactions = HistoricalAllTransactionsValue(
        expenses: const [],
        bonusExpenses: const [],
        incomes: [buildIncomeTile(id: 1, date: DateTime(2025, 7, 3))],
        bonusIncomes: const [],
      );

      final result = groupTransactionsByDate(transactions);

      final group = result.single;
      expect(group.incomes, hasLength(1));
      expect(group.expenses, isEmpty);
      expect(group.bonusExpenses, isEmpty);
      expect(group.bonusIncomes, isEmpty);
    });

    test('データが1件も無ければ空リストを返す', () {
      const transactions = HistoricalAllTransactionsValue(
        expenses: [],
        bonusExpenses: [],
        incomes: [],
        bonusIncomes: [],
      );

      expect(groupTransactionsByDate(transactions), isEmpty);
    });
  });

  group('HistoricalTransactionUsecaseNotifier.build', () {
    test('支出が日付でグループ化され日付の降順に並ぶ', () async {
      final container = createTransactionContainer(
        expenses: const [
          ExpenseEntity(
            id: 1,
            date: '20250701',
            price: 1000,
            paymentCategoryId: 10,
          ),
          ExpenseEntity(
            id: 2,
            date: '20250705',
            price: 3000,
            paymentCategoryId: 11,
          ),
          ExpenseEntity(
            id: 3,
            date: '20250628',
            price: 2000,
            paymentCategoryId: 10,
          ),
        ],
      );

      final result = await container.read(
        historicalTransactionNotifierProvider(period).future,
      );

      expect(result.expenses.map((g) => g.date), [
        DateTime(2025, 7, 5),
        DateTime(2025, 7, 1),
        DateTime(2025, 6, 28),
      ]);
      // カテゴリーマスタの情報が結合される
      final first = result.expenses.first.expenseHistoryTileValueList.single;
      expect(first.smallCategoryName, '日用品');
      expect(first.bigCategoryName, '生活費');
      expect(first.colorCode, 'FFAA00');
    });

    test('同じ日のグループ内はid降順に並ぶ', () async {
      final container = createTransactionContainer(
        expenses: const [
          ExpenseEntity(
            id: 1,
            date: '20250701',
            price: 1000,
            paymentCategoryId: 10,
          ),
          ExpenseEntity(
            id: 3,
            date: '20250701',
            price: 3000,
            paymentCategoryId: 11,
          ),
          ExpenseEntity(
            id: 2,
            date: '20250701',
            price: 2000,
            paymentCategoryId: 10,
          ),
        ],
      );

      final result = await container.read(
        historicalTransactionNotifierProvider(period).future,
      );

      expect(result.expenses, hasLength(1));
      expect(
        result.expenses.single.expenseHistoryTileValueList.map((e) => e.id),
        [3, 2, 1],
      );
    });

    test('6種のデータがすべて組成される', () async {
      final container = createTransactionContainer(
        expenses: const [
          // 月次支出（拠出元1）
          ExpenseEntity(
            id: 1,
            date: '20250701',
            price: 1000,
            paymentCategoryId: 10,
          ),
          // ボーナス支出（拠出元2）
          ExpenseEntity(
            id: 2,
            date: '20250703',
            price: 50000,
            paymentCategoryId: 12,
            incomeSourceBigCategory: 2,
          ),
          // 確定固定費（v10でexpenseの固定費行になった）
          ExpenseEntity(
            id: 100,
            date: '20250701',
            price: 80000,
            paymentCategoryId: 10,
            memo: '家賃',
            fixedCostId: 10,
            isConfirmed: 1,
          ),
          // 未確定固定費
          ExpenseEntity(
            id: 200,
            date: '20250705',
            price: null,
            paymentCategoryId: 12,
            memo: '電気代',
            fixedCostId: 30,
            isConfirmed: 0,
            estimatedPrice: 6000,
          ),
        ],
        incomes: const [
          // 月次収入（大カテゴリー1）
          IncomeEntity(id: 1, categoryId: 1, date: '20250625', price: 300000),
          // ボーナス収入（大カテゴリー2）
          IncomeEntity(id: 2, categoryId: 2, date: '20250710', price: 500000),
        ],
      );

      final result = await container.read(
        historicalTransactionNotifierProvider(period).future,
      );

      // 固定費行も同じ expenses に入る（v10。仕様 §8.4）
      // 7/1グループ（id=1の通常支出と id=100 の確定固定費）と
      // 7/5グループ（id=200 の未確定固定費）に分かれる
      final allExpenseIds = result.expenses
          .expand((g) => g.expenseHistoryTileValueList)
          .map((e) => e.id)
          .toList();
      expect(allExpenseIds, containsAll([1, 100, 200]));
      expect(result.bonusExpenses.map((e) => e.id), [2]);
      expect(result.incomes.map((e) => e.id), [1]);
      expect(result.bonusIncomes.map((e) => e.id), [2]);
    });
  });
}
