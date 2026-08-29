import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/budget/budget_usecase.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/domain/db/budget/budget_entity.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/ui_value/budget_edit_value/budget_edit_value.dart';
import 'package:kakeibo/domain_service/month_period_service/period_status_service.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

/// 支出大カテゴリーマスタ（1:食費 / 2:日用品）
const _bigCategories = [
  ExpenseBigCategoryEntity(
    id: 1,
    colorCode: 'FF0000',
    bigCategoryName: '食費',
    resourcePath: 'assets/images/icon_food.svg',
    displayOrder: 1,
    isDisplayed: 1,
  ),
  ExpenseBigCategoryEntity(
    id: 2,
    colorCode: '00FF00',
    bigCategoryName: '日用品',
    resourcePath: 'assets/images/icon_daily.svg',
    displayOrder: 2,
    isDisplayed: 1,
  ),
];

/// 支出小カテゴリーマスタ（11・12→大カテゴリー1 / 21→大カテゴリー2）
const _smallCategories = [
  ExpenseSmallCategoryEntity(
    id: 11,
    smallCategoryOrderKey: 1,
    bigCategoryKey: 1,
    displayedOrderInBig: 1,
    smallCategoryName: '食料品',
    defaultDisplayed: 1,
  ),
  ExpenseSmallCategoryEntity(
    id: 12,
    smallCategoryOrderKey: 2,
    bigCategoryKey: 1,
    displayedOrderInBig: 2,
    smallCategoryName: '外食',
    defaultDisplayed: 1,
  ),
  ExpenseSmallCategoryEntity(
    id: 21,
    smallCategoryOrderKey: 3,
    bigCategoryKey: 2,
    displayedOrderInBig: 1,
    smallCategoryName: '消耗品',
    defaultDisplayed: 1,
  ),
];

void main() {
  late FakeExpenseRepository fakeExpenseRepository;

  /// 予算リストのユースケースをテストするコンテナを組み立てる
  ///
  /// 集計期間は buildDateScope の既定値（2025/6/25〜2025/7/24・代表月202506）。
  /// 参考実績の対象期間は periodStatus によって切り替わるため、
  /// 支出レコードは「先月期間（5/25〜6/24）」「当月期間（6/25〜7/24）」の
  /// 両方に置いて区別できるようにする。
  ProviderContainer createUsecaseContainer({
    List<ExpenseBigCategoryEntity>? bigCategories,
    List<BudgetEntity> budgets = const [],
    List<ExpenseEntity> expenses = const [],
  }) {
    fakeExpenseRepository = FakeExpenseRepository(initialRecords: expenses);
    return createContainer(
      overrides: [
        expensebigCategoryRepositoryProvider.overrideWithValue(
          FakeExpenseBigCategoryRepository(
            initialRecords: bigCategories ?? _bigCategories,
          ),
        ),
        expenseSmallCategoryRepositoryProvider.overrideWithValue(
          FakeExpenseSmallCategoryRepository(initialRecords: _smallCategories),
        ),
        budgetRepositoryProvider.overrideWithValue(
          FakeBudgetRepository(initialRecords: budgets),
        ),
        expenseRepositoryProvider.overrideWithValue(fakeExpenseRepository),
      ],
    );
  }

  // 先月期間（5/25〜6/24）の支出3,000円と当月期間（6/25〜7/24）の支出5,000円
  const lastPeriodExpense = ExpenseEntity(
    id: 1,
    date: '20250601',
    price: 3000,
    paymentCategoryId: 11,
  );
  const currentPeriodExpense = ExpenseEntity(
    id: 2,
    date: '20250701',
    price: 5000,
    paymentCategoryId: 11,
  );

  group('BudgetUsecase.fetchAll の参考実績', () {
    test('現在の期間なら先月（1つ前の集計期間）の支出合計になる', () async {
      final container = createUsecaseContainer(
        expenses: const [lastPeriodExpense, currentPeriodExpense],
      );
      final usecase = container.read(budgetUsecaseProvider);

      final result = await usecase.fetchAll(
        dateScope: buildDateScope(periodStatus: PeriodStatus.current),
      );

      expect(result.first.expenseBigCategoryId, 1);
      expect(result.first.lastMonthBudgetPrice, 3000);
      // 参照した期間も1つ前の集計期間（2025/5/25〜2025/6/24）になっている
      final call = fakeExpenseRepository
          .totalExpenseWithSmallCategoryAndSourceCalls
          .first;
      expect(call.fromDate, DateTime(2025, 5, 25));
      expect(call.toDate, DateTime(2025, 6, 24));
    });

    test('過去の期間ならその期間自身の支出合計になる', () async {
      final container = createUsecaseContainer(
        expenses: const [lastPeriodExpense, currentPeriodExpense],
      );
      final usecase = container.read(budgetUsecaseProvider);

      final result = await usecase.fetchAll(
        dateScope: buildDateScope(periodStatus: PeriodStatus.past),
      );

      expect(result.first.lastMonthBudgetPrice, 5000);
      final call = fakeExpenseRepository
          .totalExpenseWithSmallCategoryAndSourceCalls
          .first;
      expect(call.fromDate, DateTime(2025, 6, 25));
      expect(call.toDate, DateTime(2025, 7, 24));
    });

    test('参考実績は給与拠出の小カテゴリーだけを合算する', () async {
      final container = createUsecaseContainer(
        expenses: const [
          lastPeriodExpense,
          // 同じ大カテゴリーの別の小カテゴリー（合算される）
          ExpenseEntity(
            id: 3,
            date: '20250605',
            price: 2000,
            paymentCategoryId: 12,
          ),
          // 拠出元がボーナスの支出（合算されない）
          ExpenseEntity(
            id: 4,
            date: '20250610',
            price: 9999,
            paymentCategoryId: 11,
            incomeSourceBigCategory: AccountTypeConstants.special,
          ),
        ],
      );
      final usecase = container.read(budgetUsecaseProvider);

      final result = await usecase.fetchAll(
        dateScope: buildDateScope(periodStatus: PeriodStatus.current),
      );

      // 大カテゴリー1配下の小カテゴリー11（3,000円）＋12（2,000円）
      expect(result.first.lastMonthBudgetPrice, 5000);
      // 問い合わせは常に給与拠出で行われる
      final calls =
          fakeExpenseRepository.totalExpenseWithSmallCategoryAndSourceCalls;
      expect(
        calls.every(
          (c) => c.incomeSourceBigCategory == AccountTypeConstants.living,
        ),
        isTrue,
      );
      expect(calls.map((c) => c.smallCategoryId), containsAll([11, 12]));
    });
  });

  group('BudgetUsecase.fetchAll のタイル生成', () {
    test('予算が登録済みならregisterd・未登録ならnotRegisterdになる', () async {
      final container = createUsecaseContainer(
        budgets: const [
          BudgetEntity(
            id: 1,
            expenseBigCategoryId: 1,
            month: '202506',
            price: 20000,
          ),
        ],
      );
      final usecase = container.read(budgetUsecaseProvider);

      final result = await usecase.fetchAll(dateScope: buildDateScope());

      expect(result, hasLength(2));
      expect(result[0].budgetStatus, BudgetStatus.registerd);
      expect(result[0].id, 1);
      expect(result[0].price, 20000);
      // 予算未登録の大カテゴリーはid:-1・金額0で返る
      expect(result[1].budgetStatus, BudgetStatus.notRegisterd);
      expect(result[1].id, -1);
      expect(result[1].price, 0);
      expect(result[1].expenseBigCategoryId, 2);
    });

    test('isDisplayed=1の大カテゴリーだけをdisplayOrder昇順で返す', () async {
      final container = createUsecaseContainer(
        bigCategories: const [
          ExpenseBigCategoryEntity(
            id: 1,
            colorCode: 'FF0000',
            bigCategoryName: '食費',
            resourcePath: 'assets/images/icon_food.svg',
            displayOrder: 3,
            isDisplayed: 1,
          ),
          ExpenseBigCategoryEntity(
            id: 2,
            colorCode: '00FF00',
            bigCategoryName: '日用品',
            resourcePath: 'assets/images/icon_daily.svg',
            displayOrder: 1,
            isDisplayed: 1,
          ),
          // 非表示の大カテゴリーはタイルに含めない
          ExpenseBigCategoryEntity(
            id: 3,
            colorCode: '0000FF',
            bigCategoryName: '交際費',
            resourcePath: 'assets/images/icon_friend.svg',
            displayOrder: 2,
            isDisplayed: 0,
          ),
        ],
      );
      final usecase = container.read(budgetUsecaseProvider);

      final result = await usecase.fetchAll(dateScope: buildDateScope());

      expect(result.map((e) => e.expenseBigCategoryId), [2, 1]);
      expect(result.map((e) => e.displayOrder), [1, 3]);
    });
  });

  group('集計開始日の変更後の区切りで参考実績が再計算される（KP-005 D-4-3）', () {
    test('開始日1の今月 8/1〜8/31 なら先月は 7/1〜7/31 になり、その支出だけを合算する', () async {
      // 7/24・7/25 は旧区切り（25日始まり）では別の月度だが、暦月では同じ7月度
      final container = createUsecaseContainer(
        expenses: const [
          ExpenseEntity(
            id: 11,
            date: '20260724',
            price: 1000,
            paymentCategoryId: 11,
          ),
          ExpenseEntity(
            id: 12,
            date: '20260725',
            price: 2000,
            paymentCategoryId: 11,
          ),
          // 8月度の支出は参考実績（先月）に入らない
          ExpenseEntity(
            id: 13,
            date: '20260824',
            price: 4000,
            paymentCategoryId: 11,
          ),
        ],
      );
      final usecase = container.read(budgetUsecaseProvider);
      final calendarAugust = PeriodValue(
        startDatetime: DateTime(2026, 8, 1),
        endDatetime: DateTime(2026, 8, 31),
      );

      final result = await usecase.fetchAll(
        dateScope: buildDateScope(
          selectedDate: DateTime(2026, 8, 29),
          aggregationMonthPeriod: calendarAugust,
          representativeMonth: '202608',
          periodStatus: PeriodStatus.current,
        ),
      );

      expect(result.first.lastMonthBudgetPrice, 3000);
      final call = fakeExpenseRepository
          .totalExpenseWithSmallCategoryAndSourceCalls
          .first;
      expect(call.fromDate, DateTime(2026, 7, 1));
      expect(call.toDate, DateTime(2026, 7, 31));
    });
  });
}
