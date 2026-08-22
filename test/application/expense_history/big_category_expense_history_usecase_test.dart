import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/expense_history/big_category_expense_history_usecase/big_category_expense_history_usecase.dart';
import 'package:kakeibo/application/expense_history/big_category_expense_history_usecase/request_big_expense_history.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  // 集計期間は2025/6/25〜2025/7/24
  final period = PeriodValue(
    startDatetime: DateTime(2025, 6, 25),
    endDatetime: DateTime(2025, 7, 24),
  );

  // 支出小カテゴリー（10:食費・11:日用品→大1 / 12:旅行→大2 / 大3は小カテゴリーなし）
  const smallCategories = [
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

  // 支出大カテゴリー（1:生活費 / 2:レジャー / 3:特別費）
  const bigCategories = [
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
    ExpenseBigCategoryEntity(
      id: 3,
      colorCode: 'FF00FF',
      bigCategoryName: '特別費',
      resourcePath: 'assets/images/icon_special.svg',
      displayOrder: 3,
      isDisplayed: 1,
    ),
  ];

  late FakeExpenseRepository fakeExpenseRepository;

  ProviderContainer createUsecaseContainer({
    List<ExpenseEntity> expenses = const [],
  }) {
    fakeExpenseRepository = FakeExpenseRepository(initialRecords: expenses);
    return createContainer(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(fakeExpenseRepository),
        expenseSmallCategoryRepositoryProvider.overrideWithValue(
          FakeExpenseSmallCategoryRepository(initialRecords: smallCategories),
        ),
        expensebigCategoryRepositoryProvider.overrideWithValue(
          FakeExpenseBigCategoryRepository(initialRecords: bigCategories),
        ),
      ],
    );
  }

  group('BigCategoryExpenseHistoryUsecaseNotifier.build', () {
    test('大カテゴリー配下の全小カテゴリーの支出が集約される', () async {
      final container = createUsecaseContainer(
        expenses: const [
          ExpenseEntity(
            id: 1,
            date: '20250701',
            price: 1000,
            paymentCategoryId: 10,
          ),
          ExpenseEntity(
            id: 2,
            date: '20250701',
            price: 2000,
            paymentCategoryId: 11,
          ),
          // 別の大カテゴリー配下なので対象外
          ExpenseEntity(
            id: 3,
            date: '20250701',
            price: 3000,
            paymentCategoryId: 12,
          ),
        ],
      );

      final result = await container.read(
        bigCategoryExpenseHistoryNotifierProvider(
          RequestBigExpenseHistory(bigId: 1, monthPeriodValue: period),
        ).future,
      );

      expect(result, hasLength(1));
      expect(result.single.expenseHistoryTileValueList.map((e) => e.id), [
        2,
        1,
      ]);
      expect(
        result.single.expenseHistoryTileValueList.map(
          (e) => e.smallCategoryName,
        ),
        ['日用品', '食費'],
      );
    });

    test('日付でグループ化され、日付降順・グループ内はid降順に並ぶ', () async {
      final container = createUsecaseContainer(
        expenses: const [
          ExpenseEntity(
            id: 1,
            date: '20250701',
            price: 1000,
            paymentCategoryId: 10,
          ),
          ExpenseEntity(
            id: 4,
            date: '20250701',
            price: 4000,
            paymentCategoryId: 11,
          ),
          ExpenseEntity(
            id: 2,
            date: '20250705',
            price: 2000,
            paymentCategoryId: 10,
          ),
          ExpenseEntity(
            id: 3,
            date: '20250628',
            price: 3000,
            paymentCategoryId: 11,
          ),
        ],
      );

      final result = await container.read(
        bigCategoryExpenseHistoryNotifierProvider(
          RequestBigExpenseHistory(bigId: 1, monthPeriodValue: period),
        ).future,
      );

      expect(result.map((g) => g.date), [
        DateTime(2025, 7, 5),
        DateTime(2025, 7, 1),
        DateTime(2025, 6, 28),
      ]);
      expect(result[1].expenseHistoryTileValueList.map((e) => e.id), [4, 1]);
    });

    test('小カテゴリーを1件も持たない大カテゴリーなら空リストを返す', () async {
      final container = createUsecaseContainer(
        expenses: const [
          ExpenseEntity(
            id: 1,
            date: '20250701',
            price: 1000,
            paymentCategoryId: 10,
          ),
        ],
      );

      final result = await container.read(
        bigCategoryExpenseHistoryNotifierProvider(
          RequestBigExpenseHistory(bigId: 3, monthPeriodValue: period),
        ).future,
      );

      expect(result, isEmpty);
      // 小カテゴリーが無いので支出の取得自体が発生しない
      expect(fakeExpenseRepository.fetchWithSmallCategoryCalls, isEmpty);
    });

    test('各取得に期間と拠出元・小カテゴリーIDが正しく渡る', () async {
      final container = createUsecaseContainer();

      await container.read(
        bigCategoryExpenseHistoryNotifierProvider(
          RequestBigExpenseHistory(bigId: 1, monthPeriodValue: period),
        ).future,
      );

      // 大カテゴリー1配下の小カテゴリー（10・11）ごとに1回ずつ取得される
      final calls = fakeExpenseRepository.fetchWithSmallCategoryCalls;
      expect(calls, hasLength(2));
      expect(calls.map((e) => e.smallCategoryId), [10, 11]);
      expect(
        calls.map((e) => e.incomeSourceBigId),
        everyElement(AccountTypeConstants.living),
      );
      expect(calls.map((e) => e.period), everyElement(period));
    });
  });
}
