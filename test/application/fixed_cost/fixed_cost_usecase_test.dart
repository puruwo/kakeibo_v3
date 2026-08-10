import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_usecase.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/view/component/app_exception.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  // システム日時2025/7/6固定 → 今の集計期間は6/25〜7/24
  late FakeFixedCostRepository fakeFixedCostRepository;
  late FakeFixedCostExpenseRepository fakeFixedCostExpenseRepository;

  ProviderContainer createUsecaseContainer({
    List<FixedCostEntity>? initialRecords,
  }) {
    fakeFixedCostRepository = FakeFixedCostRepository(
      initialRecords: initialRecords,
    );
    fakeFixedCostExpenseRepository = FakeFixedCostExpenseRepository();
    return createContainer(
      overrides: [
        ...aggregationSettingOverrides(systemDate: DateTime(2025, 7, 6)),
        fixedCostRepositoryProvider.overrideWithValue(fakeFixedCostRepository),
        fixedCostExpenseRepositoryProvider.overrideWithValue(
          fakeFixedCostExpenseRepository,
        ),
      ],
    );
  }

  // バリデーションが通る基本の登録エンティティ（初回支払いは今月の期間内）
  const validEntity = FixedCostEntity(
    name: 'サブスク',
    variable: 0,
    price: 1000,
    fixedCostCategoryId: 1,
    intervalNumber: 1,
    intervalUnit: 1,
    firstPaymentDate: '20250710',
  );

  group('FixedCostUsecase.add のバリデーション', () {
    test('初回支払日が今の集計期間より前ならエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostUsecaseProvider);

      expect(
        () => usecase.add(
          fixedCostEntity: validEntity.copyWith(firstPaymentDate: '20250624'),
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '今月の集計期間以降の日付を入力してください',
          ),
        ),
      );
    });

    test('名前が空ならエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostUsecaseProvider);

      expect(
        () => usecase.add(fixedCostEntity: validEntity.copyWith(name: '')),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '名前を入力してください',
          ),
        ),
      );
    });

    test('固定額で金額0円以下ならエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostUsecaseProvider);

      expect(
        () => usecase.add(fixedCostEntity: validEntity.copyWith(price: 0)),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '0円以上で入力してください',
          ),
        ),
      );
    });

    test('金額が上限（99,999,999円）以上ならエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostUsecaseProvider);

      expect(
        () =>
            usecase.add(fixedCostEntity: validEntity.copyWith(price: 99999999)),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '金額の入力値が大き過ぎます',
          ),
        ),
      );
    });

    test('カテゴリー未選択ならエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostUsecaseProvider);

      expect(
        () => usecase.add(
          fixedCostEntity: validEntity.copyWith(fixedCostCategoryId: 0),
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            'カテゴリーを選択してください',
          ),
        ),
      );
    });

    test('変動額（variable=1）は金額0円でも登録できる', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.add(
        fixedCostEntity: validEntity.copyWith(variable: 1, price: 0),
      );

      expect(fakeFixedCostRepository.insertedEntities, hasLength(1));
    });
  });

  group('FixedCostUsecase.add の登録処理', () {
    test('初回支払いが今月内なら支払予定日を進めて実績も作成する', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.add(fixedCostEntity: validEntity);

      // マスタ: 次回支払日=初回+1ヶ月、最近支払日=初回
      expect(fakeFixedCostRepository.insertedEntities, hasLength(1));
      final master = fakeFixedCostRepository.insertedEntities.first;
      expect(master.recentPaymentDate, '20250710');
      expect(master.nextPaymentDate, '20250810');

      // 実績: 初回支払日で1件生成される
      expect(fakeFixedCostExpenseRepository.insertedEntities, hasLength(1));
      final expense = fakeFixedCostExpenseRepository.insertedEntities.first;
      expect(expense.date, '20250710');
      expect(expense.price, 1000);
      expect(expense.isConfirmed, 1);
    });

    test('初回支払いが来月以降なら実績は作らず初回日を次回支払日に設定する', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.add(
        fixedCostEntity: validEntity.copyWith(firstPaymentDate: '20250801'),
      );

      expect(fakeFixedCostRepository.insertedEntities, hasLength(1));
      final master = fakeFixedCostRepository.insertedEntities.first;
      expect(master.nextPaymentDate, '20250801');
      expect(master.recentPaymentDate, isNull);

      // 今月の支払いはないので実績は生成されない
      expect(fakeFixedCostExpenseRepository.insertedEntities, isEmpty);
    });
  });

  group('FixedCostUsecase.addExpenseForFixedCost（バッチの1ヶ月分処理）', () {
    final period = PeriodValue(
      startDatetime: DateTime(2025, 6, 25),
      endDatetime: DateTime(2025, 7, 24),
    );

    test('期間内に支払予定のある固定費だけ実績を作成しマスタの支払日を進める', () async {
      final container = createUsecaseContainer(
        initialRecords: const [
          // 期間内の支払い（対象）
          FixedCostEntity(
            id: 1,
            name: '家賃',
            variable: 0,
            price: 80000,
            fixedCostCategoryId: 1,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20250101',
            nextPaymentDate: '20250701',
          ),
          // 期間外の支払い（対象外）
          FixedCostEntity(
            id: 2,
            name: '保険',
            variable: 0,
            price: 5000,
            fixedCostCategoryId: 1,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20250101',
            nextPaymentDate: '20250801',
          ),
          // 期間内だが削除済み（対象外）
          FixedCostEntity(
            id: 3,
            name: '解約済みサブスク',
            variable: 0,
            price: 500,
            fixedCostCategoryId: 1,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20250101',
            nextPaymentDate: '20250710',
            deleteFlag: 1,
          ),
        ],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.addExpenseForFixedCost(period);

      // 実績は期間内の1件だけ生成される
      expect(fakeFixedCostExpenseRepository.insertedEntities, hasLength(1));
      final expense = fakeFixedCostExpenseRepository.insertedEntities.first;
      expect(expense.fixedCostId, 1);
      expect(expense.date, '20250701');
      expect(expense.price, 80000);

      // マスタは支払予定日が1ヶ月進む
      expect(fakeFixedCostRepository.updatedEntities, hasLength(1));
      final updated = fakeFixedCostRepository.updatedEntities.first;
      expect(updated.id, 1);
      expect(updated.recentPaymentDate, '20250701');
      expect(updated.nextPaymentDate, '20250801');
    });

    test('変動額の固定費は0円・未確定の実績が作られる', () async {
      final container = createUsecaseContainer(
        initialRecords: const [
          FixedCostEntity(
            id: 4,
            name: '電気代',
            variable: 1,
            price: 0,
            estimatedPrice: 6000,
            fixedCostCategoryId: 2,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20250101',
            nextPaymentDate: '20250705',
          ),
        ],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.addExpenseForFixedCost(period);

      expect(fakeFixedCostExpenseRepository.insertedEntities, hasLength(1));
      final expense = fakeFixedCostExpenseRepository.insertedEntities.first;
      expect(expense.price, 0);
      expect(expense.isConfirmed, 0);
      expect(expense.confirmedCostType, 1);
    });

    test('期間内に支払予定がなければ何もしない', () async {
      final container = createUsecaseContainer(initialRecords: const []);
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.addExpenseForFixedCost(period);

      expect(fakeFixedCostExpenseRepository.insertedEntities, isEmpty);
      expect(fakeFixedCostRepository.updatedEntities, isEmpty);
    });
  });

  group('FixedCostUsecase.updateEstimatedPrice', () {
    test('変動額の固定費は過去実績の平均で想定額を更新する', () async {
      final container = createUsecaseContainer(
        initialRecords: const [
          FixedCostEntity(
            id: 5,
            name: '電気代',
            variable: 1,
            price: 0,
            estimatedPrice: 5000,
            fixedCostCategoryId: 2,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20250101',
          ),
        ],
      );
      fakeFixedCostExpenseRepository.estimatedPriceResult = 6500.7;
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.updateEstimatedPrice(fixedCostId: 5);

      expect(fakeFixedCostRepository.updatedEntities, hasLength(1));
      // 平均額は小数を切り捨てて想定額になる
      expect(
        fakeFixedCostRepository.updatedEntities.first.estimatedPrice,
        6500,
      );
    });

    test('固定額の固定費は何もしない', () async {
      final container = createUsecaseContainer(
        initialRecords: const [
          FixedCostEntity(
            id: 6,
            name: '家賃',
            variable: 0,
            price: 80000,
            fixedCostCategoryId: 1,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20250101',
          ),
        ],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.updateEstimatedPrice(fixedCostId: 6);

      expect(fakeFixedCostRepository.updatedEntities, isEmpty);
    });
  });

  group('FixedCostUsecase.edit', () {
    const originalEntity = FixedCostEntity(
      id: 7,
      name: 'ジム',
      variable: 0,
      price: 10000,
      fixedCostCategoryId: 1,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
    );

    test('変更がなければエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostUsecaseProvider);

      expect(
        () => usecase.edit(
          originalEntity: originalEntity,
          editEntity: originalEntity,
        ),
        throwsA(
          isA<AppException>().having((e) => e.message, 'message', '変更がありません'),
        ),
      );
    });

    test('カテゴリー変更なしの編集はマスタ更新のみ', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.edit(
        originalEntity: originalEntity,
        editEntity: originalEntity.copyWith(price: 12000),
      );

      expect(fakeFixedCostRepository.updatedEntities, hasLength(1));
      expect(fakeFixedCostRepository.updatedEntities.first.price, 12000);
      // 過去実績の書き換えは発生しない
      expect(fakeFixedCostExpenseRepository.updatedEntities, isEmpty);
    });

    test('カテゴリー変更ありの編集は過去実績のカテゴリーも一括変更する', () async {
      final container = createUsecaseContainer();
      // 過去実績2件を既存レコードとして積む
      fakeFixedCostExpenseRepository.records.addAll(const [
        FixedCostExpenseEntity(
          id: 100,
          fixedCostId: 7,
          fixedCostCategoryId: 1,
          date: '20250501',
          price: 10000,
        ),
        FixedCostExpenseEntity(
          id: 101,
          fixedCostId: 7,
          fixedCostCategoryId: 1,
          date: '20250601',
          price: 10000,
        ),
      ]);
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.edit(
        originalEntity: originalEntity,
        editEntity: originalEntity.copyWith(fixedCostCategoryId: 3),
      );

      // 過去実績2件が新カテゴリーに更新される
      expect(fakeFixedCostExpenseRepository.updatedEntities, hasLength(2));
      expect(
        fakeFixedCostExpenseRepository.updatedEntities.every(
          (e) => e.fixedCostCategoryId == 3,
        ),
        isTrue,
      );
      // マスタも更新される
      expect(fakeFixedCostRepository.updatedEntities, hasLength(1));
      expect(
        fakeFixedCostRepository.updatedEntities.first.fixedCostCategoryId,
        3,
      );
    });
  });

  group('FixedCostUsecase.delete', () {
    test('リポジトリのdeleteに委譲する', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.delete(id: 42);

      expect(fakeFixedCostRepository.deletedIds, [42]);
    });
  });
}
