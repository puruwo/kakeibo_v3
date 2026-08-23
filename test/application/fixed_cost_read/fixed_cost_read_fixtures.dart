// fixed_cost_read 系ユースケースの共通フィクスチャ
//
// v10でデータ源が fixed_cost_record から expense に移り、グルーピングも
// 支出カテゴリー（大→小）基準になった（仕様 §8.3）。6本のテストが同じ
// カテゴリーマスタ・固定費マスタを使うため、ここに集約する。
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

/// 支出大カテゴリー（1=住居 / 2=光熱費。表示順は 1 → 2）
const fixtureBigCategories = [
  ExpenseBigCategoryEntity(
    id: 1,
    colorCode: 'FFAA00',
    bigCategoryName: '住居',
    resourcePath: 'assets/images/icon_home.svg',
    displayOrder: 1,
    isDisplayed: 1,
  ),
  ExpenseBigCategoryEntity(
    id: 2,
    colorCode: '00AAFF',
    bigCategoryName: '光熱費',
    resourcePath: 'assets/images/icon_utility.svg',
    displayOrder: 2,
    isDisplayed: 1,
  ),
];

/// 支出小カテゴリー（11=家賃・12=保険 → 大1 / 21=電気 → 大2）
const fixtureSmallCategories = [
  ExpenseSmallCategoryEntity(
    id: 11,
    smallCategoryOrderKey: 1,
    bigCategoryKey: 1,
    displayedOrderInBig: 1,
    smallCategoryName: '家賃',
    defaultDisplayed: 1,
  ),
  ExpenseSmallCategoryEntity(
    id: 12,
    smallCategoryOrderKey: 2,
    bigCategoryKey: 1,
    displayedOrderInBig: 2,
    smallCategoryName: '保険',
    defaultDisplayed: 1,
  ),
  ExpenseSmallCategoryEntity(
    id: 21,
    smallCategoryOrderKey: 3,
    bigCategoryKey: 2,
    displayedOrderInBig: 1,
    smallCategoryName: '電気',
    defaultDisplayed: 1,
  ),
];

/// 固定費マスタ（10:毎月の家賃 / 20:毎年の保険 / 30:変動する電気代）
const fixtureFixedCosts = [
  FixedCostEntity(
    id: 10,
    name: '家賃',
    variable: 0,
    price: 80000,
    expenseSmallCategoryId: 11,
    intervalNumber: 1,
    intervalUnit: 1,
    firstPaymentDate: '20250101',
    nextPaymentDate: '20250801',
  ),
  FixedCostEntity(
    id: 20,
    name: '保険',
    variable: 0,
    price: 30000,
    expenseSmallCategoryId: 12,
    intervalNumber: 1,
    intervalUnit: 2,
    firstPaymentDate: '20250101',
    nextPaymentDate: '20260701',
  ),
  FixedCostEntity(
    id: 30,
    name: '電気代',
    variable: 1,
    estimatedPrice: 6000,
    expenseSmallCategoryId: 21,
    intervalNumber: 1,
    intervalUnit: 1,
    firstPaymentDate: '20250101',
    nextPaymentDate: '20250805',
  ),
];

/// fixed_cost_read 系ユースケース用のコンテナを組み立てる
///
/// [expenses] には expense の行（固定費行・通常支出とも）を渡す。
ProviderContainer createFixedCostReadContainer({
  List<ExpenseEntity> expenses = const [],
  List<FixedCostEntity> fixedCosts = fixtureFixedCosts,
}) {
  return createContainer(
    overrides: [
      expenseRepositoryProvider.overrideWithValue(
        FakeExpenseRepository(initialRecords: expenses),
      ),
      expenseSmallCategoryRepositoryProvider.overrideWithValue(
        FakeExpenseSmallCategoryRepository(
          initialRecords: fixtureSmallCategories,
        ),
      ),
      expensebigCategoryRepositoryProvider.overrideWithValue(
        FakeExpenseBigCategoryRepository(initialRecords: fixtureBigCategories),
      ),
      fixedCostRepositoryProvider.overrideWithValue(
        FakeFixedCostRepository(initialRecords: fixedCosts),
      ),
    ],
  );
}

/// 確定済みの固定費行（家賃 80,000円 / 2025-07-01）
const fixtureConfirmedRent = ExpenseEntity(
  id: 100,
  date: '20250701',
  price: 80000,
  paymentCategoryId: 11,
  memo: '家賃',
  fixedCostId: 10,
  isConfirmed: 1,
);

/// 未確定の固定費行（電気代 予想6,000円 / 2025-07-05）
const fixtureUnconfirmedElectricity = ExpenseEntity(
  id: 101,
  date: '20250705',
  price: null,
  paymentCategoryId: 21,
  memo: '電気代',
  fixedCostId: 30,
  isConfirmed: 0,
  estimatedPrice: 6000,
);

/// 確定済みの固定費行（保険 30,000円 / 2025-06-30）
const fixtureConfirmedInsurance = ExpenseEntity(
  id: 102,
  date: '20250630',
  price: 30000,
  paymentCategoryId: 12,
  memo: '保険',
  fixedCostId: 20,
  isConfirmed: 1,
);
