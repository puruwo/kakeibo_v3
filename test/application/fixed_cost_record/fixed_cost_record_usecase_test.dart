// FixedCostRecordUsecase（固定費の実績行の確定・編集・削除）のテスト
//
// v10で実績の格納先が fixed_cost_record から expense に移ったため、
// 対象は expense のうち fixed_cost_id を持つ行（仕様 §6.4）。
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost_record/fixed_cost_record_usecase.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/view/component/app_exception.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  late FakeFixedCostRepository fakeFixedCostRepository;
  late FakeExpenseRepository fakeExpenseRepository;

  ProviderContainer createUsecaseContainer({
    List<FixedCostEntity>? fixedCosts,
    List<ExpenseEntity>? expenses,
  }) {
    fakeExpenseRepository = FakeExpenseRepository(initialRecords: expenses);
    fakeFixedCostRepository = FakeFixedCostRepository(
      initialRecords: fixedCosts,
      expenseRepository: fakeExpenseRepository,
    );
    return createContainer(
      overrides: [
        fixedCostRepositoryProvider.overrideWithValue(fakeFixedCostRepository),
        expenseRepositoryProvider.overrideWithValue(fakeExpenseRepository),
      ],
    );
  }


  // 変動固定費のマスタ（確定操作の対象）
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

  // 未確定の実績行（実額なし・予想額あり）
  const unconfirmedRow = ExpenseEntity(
    id: 100,
    date: '20250710',
    price: null,
    paymentCategoryId: 12,
    fixedCostId: 10,
    isConfirmed: 0,
    estimatedPrice: 6000,
  );

  group('FixedCostRecordUsecase.edit', () {
    // 確定済みの固定費行
    const confirmedRow = ExpenseEntity(
      id: 100,
      date: '20250710',
      price: 7200,
      paymentCategoryId: 12,
      memo: '電気代',
      fixedCostId: 10,
    );

    test('金額が0円以下／上限以上ならエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostRecordUsecaseProvider);

      await expectLater(
        () => usecase.edit(entity: confirmedRow.copyWith(price: 0)),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '0円以上で入力してください',
          ),
        ),
      );
      await expectLater(
        () => usecase.edit(entity: confirmedRow.copyWith(price: 1888888)),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '金額の入力値が大き過ぎます',
          ),
        ),
      );
      expect(fakeExpenseRepository.updatedEntities, isEmpty);
    });

    test('実額が未入力（NULL）ならエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostRecordUsecaseProvider);

      await expectLater(
        () => usecase.edit(entity: unconfirmedRow),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '0円以上で入力してください',
          ),
        ),
      );
    });

    test('未確定行への金額入力は確定操作として扱う', () async {
      // 未確定のままの手動金額変更は提供しない（仕様 §6.4）
      final container = createUsecaseContainer(
        fixedCosts: const [variableMaster],
        expenses: const [unconfirmedRow],
      );
      final usecase = container.read(fixedCostRecordUsecaseProvider);

      await usecase.edit(entity: unconfirmedRow.copyWith(price: 8000));

      final row = fakeExpenseRepository.records.single;
      expect(row.price, 8000);
      expect(row.isConfirmed, 1);
      // 予想額は残す（仕様 §3）
      expect(row.estimatedPrice, 6000);
    });

    test('確定済み行の金額編集で推定額が再計算される', () async {
      final container = createUsecaseContainer(
        fixedCosts: const [variableMaster],
        expenses: const [confirmedRow],
      );
      final usecase = container.read(fixedCostRecordUsecaseProvider);
      final dbCount = listenUpdateDBCount(container);

      await usecase.edit(entity: confirmedRow.copyWith(price: 9000));

      expect(fakeExpenseRepository.updatedEntities, hasLength(1));
      expect(fakeExpenseRepository.updatedEntities.first.price, 9000);
      // 平均の根拠が変わるので推定額も追随する（仕様 §6.5）
      expect(
        fakeFixedCostRepository.records.single.estimatedPrice,
        9000,
      );
      // 再計算ぶんと編集ぶんでカウンタが進む
      expect(dbCount.read(), 2);
    });

    test('固定費に紐づかない行なら推定額の再計算はしない', () async {
      final container = createUsecaseContainer(
        expenses: const [
          ExpenseEntity(id: 200, date: '20250710', price: 500),
        ],
      );
      final usecase = container.read(fixedCostRecordUsecaseProvider);
      final dbCount = listenUpdateDBCount(container);

      await usecase.edit(
        entity: const ExpenseEntity(id: 200, date: '20250710', price: 600),
      );

      expect(fakeExpenseRepository.updatedEntities.single.price, 600);
      expect(dbCount.read(), 1);
    });
  });

  group('FixedCostRecordUsecase.delete', () {
    test('実績行を削除する', () async {
      final container = createUsecaseContainer(
        expenses: const [
          ExpenseEntity(id: 100, date: '20250710', price: 7200),
        ],
      );
      final usecase = container.read(fixedCostRecordUsecaseProvider);
      final dbCount = listenUpdateDBCount(container);

      await usecase.delete(id: 100);

      expect(fakeExpenseRepository.deletedIds, [100]);
      expect(fakeExpenseRepository.records, isEmpty);
      expect(dbCount.read(), 1);
    });

    test('確定済みの固定費行を削除すると推定額が再計算される', () async {
      // 平均の根拠から外れるため（仕様 §6.5）
      final container = createUsecaseContainer(
        fixedCosts: const [variableMaster],
        expenses: const [
          // 削除対象（10000円）。消えると残り6000円だけが平均の根拠になる
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
        ],
      );
      final usecase = container.read(fixedCostRecordUsecaseProvider);

      await usecase.delete(id: 100);

      expect(fakeFixedCostRepository.records.single.estimatedPrice, 6000);
    });

    test('未確定行の削除では推定額を再計算しない', () async {
      // 未確定行は平均の根拠に入っていない
      final container = createUsecaseContainer(
        fixedCosts: const [variableMaster],
        expenses: const [unconfirmedRow],
      );
      final usecase = container.read(fixedCostRecordUsecaseProvider);

      await usecase.delete(id: 100);

      expect(fakeFixedCostRepository.records.single.estimatedPrice, 5000);
    });
  });
}
