import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// 2つのプロバイダーファイルは同名のNotifierクラスを持つため、プロバイダーだけを取り込む
import 'package:kakeibo/application/expense_history/bonus_expense_history_digest_usecase.dart'
    show bonusExpenseHistoryDigestNotifierProvider;
import 'package:kakeibo/application/expense_history/expense_history_digest_usecase.dart'
    show expenseHistoryDigestNotifierProvider;
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

  // 支出小カテゴリー（10:食費→大1 / 12:旅行→大2）
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
      id: 12,
      smallCategoryOrderKey: 2,
      bigCategoryKey: 2,
      displayedOrderInBig: 1,
      smallCategoryName: '旅行',
      defaultDisplayed: 1,
    ),
  ];

  // 支出大カテゴリー（1:生活費 / 2:レジャー）
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
  ];

  // 月次支出（拠出元1）とボーナス支出（拠出元2）を1件ずつ
  const expenses = [
    ExpenseEntity(id: 1, date: '20250701', price: 1000, paymentCategoryId: 10),
    ExpenseEntity(
      id: 2,
      date: '20250703',
      price: 50000,
      paymentCategoryId: 12,
      incomeSourceBigCategory: 2,
    ),
  ];

  late FakeExpenseRepository fakeExpenseRepository;

  ProviderContainer createDigestContainer() {
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

  group('支出履歴ダイジェスト', () {
    test('通常版は拠出元が給与（bigId=1）で取得される', () async {
      final container = createDigestContainer();

      final result = await container.read(
        expenseHistoryDigestNotifierProvider(period).future,
      );

      expect(fakeExpenseRepository.fetchWithSourceCategoryCalls, hasLength(1));
      final call = fakeExpenseRepository.fetchWithSourceCategoryCalls.single;
      expect(
        call.incomeSourceBigId,
        AccountTypeConstants.living,
      );
      expect(call.period, period);
      expect(result.map((e) => e.id), [1]);
    });

    test('ボーナス版は拠出元がボーナス（bigId=2）で取得される', () async {
      final container = createDigestContainer();

      final result = await container.read(
        bonusExpenseHistoryDigestNotifierProvider(period).future,
      );

      expect(fakeExpenseRepository.fetchWithSourceCategoryCalls, hasLength(1));
      final call = fakeExpenseRepository.fetchWithSourceCategoryCalls.single;
      expect(
        call.incomeSourceBigId,
        AccountTypeConstants.special,
      );
      expect(call.period, period);
      expect(result.map((e) => e.id), [2]);
    });
  });
}
