import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/expense_history/small_category_expense_history_usecase/request_small_expense_history.dart';
import 'package:kakeibo/application/expense_history/small_category_expense_history_usecase/small_category_expense_history_usecase.dart';
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

  // 支出小カテゴリー（10:食費・11:日用品→大1）
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
  ];

  // 支出大カテゴリー（1:生活費）
  const bigCategories = [
    ExpenseBigCategoryEntity(
      id: 1,
      colorCode: 'FFAA00',
      bigCategoryName: '生活費',
      resourcePath: 'assets/images/icon_life.svg',
      displayOrder: 1,
      isDisplayed: 1,
    ),
  ];

  ProviderContainer createUsecaseContainer({
    List<ExpenseEntity> expenses = const [],
  }) {
    return createContainer(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(
          FakeExpenseRepository(initialRecords: expenses),
        ),
        expenseSmallCategoryRepositoryProvider.overrideWithValue(
          FakeExpenseSmallCategoryRepository(initialRecords: smallCategories),
        ),
        expensebigCategoryRepositoryProvider.overrideWithValue(
          FakeExpenseBigCategoryRepository(initialRecords: bigCategories),
        ),
      ],
    );
  }

  group('SmallCategoryExpenseHistoryUsecaseNotifier.build', () {
    test('指定した小カテゴリーの支出だけが取得される', () async {
      final container = createUsecaseContainer(
        expenses: const [
          ExpenseEntity(
            id: 1,
            date: '20250701',
            price: 1000,
            paymentCategoryId: 10,
          ),
          // 別の小カテゴリーなので対象外
          ExpenseEntity(
            id: 2,
            date: '20250701',
            price: 2000,
            paymentCategoryId: 11,
          ),
        ],
      );

      final result = await container.read(
        smallCategoryExpenseHistoryNotifierProvider(
          RequestSmallExpenseHistory(smallId: 10, monthPeriodValue: period),
        ).future,
      );

      expect(result, hasLength(1));
      final tile = result.single.expenseHistoryTileValueList.single;
      expect(tile.id, 1);
      expect(tile.smallCategoryName, '食費');
      expect(tile.bigCategoryName, '生活費');
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
            paymentCategoryId: 10,
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
            paymentCategoryId: 10,
          ),
        ],
      );

      final result = await container.read(
        smallCategoryExpenseHistoryNotifierProvider(
          RequestSmallExpenseHistory(smallId: 10, monthPeriodValue: period),
        ).future,
      );

      expect(result.map((g) => g.date), [
        DateTime(2025, 7, 5),
        DateTime(2025, 7, 1),
        DateTime(2025, 6, 28),
      ]);
      expect(result[1].expenseHistoryTileValueList.map((e) => e.id), [4, 1]);
    });

    test('該当する支出が0件なら空リストを返す', () async {
      final container = createUsecaseContainer();

      final result = await container.read(
        smallCategoryExpenseHistoryNotifierProvider(
          RequestSmallExpenseHistory(smallId: 10, monthPeriodValue: period),
        ).future,
      );

      expect(result, isEmpty);
    });
  });
}
