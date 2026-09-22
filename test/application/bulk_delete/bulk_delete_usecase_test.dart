// BulkDeleteUsecase（支出・収入レコードのまとめて削除）のテスト（KP-031）
//
// 削除は ID の一覧を1回の deleteByIds で渡すこと、支出に確定済みの固定費行が含まれるときは
// そのマスタの推定額が再計算されること、DB 更新の通知が出ることを確かめる。
// 一覧の組み立ては bulk_delete_list_service_test が担当する。
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/bulk_delete/bulk_delete_mode.dart';
import 'package:kakeibo/application/bulk_delete/bulk_delete_usecase.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  late FakeExpenseRepository fakeExpenseRepository;
  late FakeIncomeRepository fakeIncomeRepository;
  late FakeFixedCostRepository fakeFixedCostRepository;

  ProviderContainer createUsecaseContainer({
    List<ExpenseEntity>? expenses,
    List<IncomeEntity>? incomes,
    List<FixedCostEntity>? fixedCosts,
  }) {
    fakeExpenseRepository = FakeExpenseRepository(initialRecords: expenses);
    fakeIncomeRepository = FakeIncomeRepository(initialRecords: incomes);
    fakeFixedCostRepository = FakeFixedCostRepository(
      initialRecords: fixedCosts,
      expenseRepository: fakeExpenseRepository,
    );
    return createContainer(
      overrides: [
        ...aggregationSettingOverrides(systemDate: DateTime(2025, 7, 6)),
        expenseRepositoryProvider.overrideWithValue(fakeExpenseRepository),
        incomeRepositoryProvider.overrideWithValue(fakeIncomeRepository),
        fixedCostRepositoryProvider.overrideWithValue(fakeFixedCostRepository),
      ],
    );
  }

  // 変動固定費のマスタ（推定額 5,000 円）
  const variableMaster = FixedCostEntity(
    id: 10,
    name: '電気代',
    variable: 1,
    estimatedPrice: 5000,
    expenseSmallCategoryId: 12,
    intervalNumber: 1,
    intervalUnit: 1,
    firstPaymentDate: '20250101',
  );

  // 通常支出3件（固定費行なし）
  const plainExpenses = [
    ExpenseEntity(id: 1, date: '20250706', price: 1200, paymentCategoryId: 10),
    ExpenseEntity(id: 2, date: '20250706', price: 880, paymentCategoryId: 10),
    ExpenseEntity(id: 3, date: '20250701', price: 340, paymentCategoryId: 10),
  ];

  group('BulkDeleteUsecase.delete（支出）', () {
    test('選択した ID を1回の deleteByIds で削除し、DB 更新を1回通知する', () async {
      final container = createUsecaseContainer(expenses: plainExpenses);
      final dbCount = listenUpdateDBCount(container);
      final usecase = container.read(bulkDeleteUsecaseProvider);

      await usecase.delete(mode: BulkDeleteMode.expense, ids: [1, 3]);

      expect(fakeExpenseRepository.deletedByIdsCalls, [
        [1, 3],
      ]);
      expect(fakeExpenseRepository.records.map((e) => e.id).toList(), [2]);
      // 1件ずつの delete は使わない
      expect(fakeExpenseRepository.deletedIds, [1, 3]);
      expect(dbCount.read(), 1);
    });

    test('確定済みの固定費行を含むと、そのマスタの推定額が残りの確定行の平均で再計算される', () async {
      final container = createUsecaseContainer(
        fixedCosts: const [variableMaster],
        expenses: const [
          // 削除対象の確定行2件（10,000 / 6,000）
          ExpenseEntity(
            id: 100,
            date: '20250710',
            price: 10000,
            paymentCategoryId: 12,
            fixedCostId: 10,
          ),
          ExpenseEntity(
            id: 101,
            date: '20250610',
            price: 6000,
            paymentCategoryId: 12,
            fixedCostId: 10,
          ),
          // 残る確定行（7,000）。削除後はこれだけが平均の根拠になる
          ExpenseEntity(
            id: 102,
            date: '20250510',
            price: 7000,
            paymentCategoryId: 12,
            fixedCostId: 10,
          ),
          // 通常支出も同時に消す
          ExpenseEntity(
            id: 1,
            date: '20250706',
            price: 1200,
            paymentCategoryId: 10,
          ),
        ],
      );
      final dbCount = listenUpdateDBCount(container);
      final usecase = container.read(bulkDeleteUsecaseProvider);

      await usecase.delete(mode: BulkDeleteMode.expense, ids: [100, 101, 1]);

      expect(fakeExpenseRepository.deletedByIdsCalls, [
        [100, 101, 1],
      ]);
      expect(fakeExpenseRepository.records.map((e) => e.id).toList(), [102]);
      expect(fakeFixedCostRepository.records.single.estimatedPrice, 7000);
      // 削除の通知に加えて推定額の再計算でも通知が出る（回数は問わない）
      expect(dbCount.read(), greaterThanOrEqualTo(1));
    });

    test('未確定の固定費行だけなら推定額を再計算しない', () async {
      final container = createUsecaseContainer(
        fixedCosts: const [variableMaster],
        expenses: const [
          ExpenseEntity(
            id: 200,
            date: '20250710',
            price: null,
            paymentCategoryId: 12,
            fixedCostId: 10,
            isConfirmed: 0,
            estimatedPrice: 5000,
          ),
        ],
      );
      final dbCount = listenUpdateDBCount(container);
      final usecase = container.read(bulkDeleteUsecaseProvider);

      await usecase.delete(mode: BulkDeleteMode.expense, ids: [200]);

      expect(fakeExpenseRepository.records, isEmpty);
      // 未確定行は平均の根拠に入っていないため 5,000 のまま
      expect(fakeFixedCostRepository.records.single.estimatedPrice, 5000);
      expect(dbCount.read(), 1);
    });

    test('空の ID なら何もしない', () async {
      final container = createUsecaseContainer(expenses: plainExpenses);
      final dbCount = listenUpdateDBCount(container);
      final usecase = container.read(bulkDeleteUsecaseProvider);

      await usecase.delete(mode: BulkDeleteMode.expense, ids: const []);

      expect(fakeExpenseRepository.deletedByIdsCalls, isEmpty);
      expect(fakeExpenseRepository.records, hasLength(3));
      expect(dbCount.read(), 0);
    });
  });

  group('BulkDeleteUsecase.delete（収入）', () {
    test('選択した ID を1回の deleteByIds で削除し、DB 更新を1回通知する', () async {
      final container = createUsecaseContainer(
        incomes: const [
          IncomeEntity(id: 1, categoryId: 1, date: '20250625', price: 250000),
          IncomeEntity(id: 2, categoryId: 1, date: '20250725', price: 260000),
          IncomeEntity(id: 3, categoryId: 4, date: '20250701', price: 1000),
        ],
      );
      final dbCount = listenUpdateDBCount(container);
      final usecase = container.read(bulkDeleteUsecaseProvider);

      await usecase.delete(mode: BulkDeleteMode.income, ids: [2, 3]);

      expect(fakeIncomeRepository.deletedByIdsCalls, [
        [2, 3],
      ]);
      expect(fakeIncomeRepository.records.map((e) => e.id).toList(), [1]);
      // 支出側には触らない
      expect(fakeExpenseRepository.deletedByIdsCalls, isEmpty);
      expect(dbCount.read(), 1);
    });

    test('空の ID なら何もしない', () async {
      final container = createUsecaseContainer(
        incomes: const [
          IncomeEntity(id: 1, categoryId: 1, date: '20250625', price: 250000),
        ],
      );
      final dbCount = listenUpdateDBCount(container);
      final usecase = container.read(bulkDeleteUsecaseProvider);

      await usecase.delete(mode: BulkDeleteMode.income, ids: const []);

      expect(fakeIncomeRepository.deletedByIdsCalls, isEmpty);
      expect(fakeIncomeRepository.records, hasLength(1));
      expect(dbCount.read(), 0);
    });
  });
}
