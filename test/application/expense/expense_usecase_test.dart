import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/expense/expense_usecase.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  const validEntity = ExpenseEntity(
    date: '20250706',
    price: 1200,
    paymentCategoryId: 1,
  );

  group('ExpenseUsecase.add', () {
    test('金額0円以下ならエラーで登録しない', () async {
      final fakeRepository = FakeExpenseRepository();
      final container = createContainer(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      final usecase = container.read(expenseUsecaseProvider);

      await expectLater(
        () => usecase.add(expenseEntity: validEntity.copyWith(price: 0)),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '0円以上で入力してください',
          ),
        ),
      );
      expect(fakeRepository.insertedEntities, isEmpty);
    });

    test('金額が上限（1,888,888円）以上ならエラー', () async {
      final fakeRepository = FakeExpenseRepository();
      final container = createContainer(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      final usecase = container.read(expenseUsecaseProvider);

      await expectLater(
        () => usecase.add(expenseEntity: validEntity.copyWith(price: 1888888)),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '金額の入力値が大き過ぎます',
          ),
        ),
      );
    });

    test('上限未満（1,888,887円）は登録できる', () async {
      final fakeRepository = FakeExpenseRepository();
      final container = createContainer(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      final usecase = container.read(expenseUsecaseProvider);

      await usecase.add(expenseEntity: validEntity.copyWith(price: 1888887));

      expect(fakeRepository.insertedEntities, hasLength(1));
      expect(fakeRepository.insertedEntities.first.price, 1888887);
    });

    test('登録するとDB更新カウンタが増える（画面リフレッシュの合図）', () async {
      final fakeRepository = FakeExpenseRepository();
      final container = createContainer(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      final usecase = container.read(expenseUsecaseProvider);
      expect(container.read(updateDBCountNotifierProvider), 0);

      await usecase.add(expenseEntity: validEntity);

      expect(container.read(updateDBCountNotifierProvider), 1);
    });
  });

  group('ExpenseUsecase.edit', () {
    test('変更がなければエラー', () async {
      final fakeRepository = FakeExpenseRepository();
      final container = createContainer(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      final usecase = container.read(expenseUsecaseProvider);

      await expectLater(
        () =>
            usecase.edit(originalEntity: validEntity, editEntity: validEntity),
        throwsA(
          isA<AppException>().having((e) => e.message, 'message', '変更がありません'),
        ),
      );
    });

    test('金額バリデーションはaddと同じ', () async {
      final fakeRepository = FakeExpenseRepository();
      final container = createContainer(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      final usecase = container.read(expenseUsecaseProvider);

      await expectLater(
        () => usecase.edit(
          originalEntity: validEntity,
          editEntity: validEntity.copyWith(price: -100),
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '0円以上で入力してください',
          ),
        ),
      );
    });

    test('正常な編集はリポジトリを更新する', () async {
      final fakeRepository = FakeExpenseRepository();
      final container = createContainer(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      final usecase = container.read(expenseUsecaseProvider);

      await usecase.edit(
        originalEntity: validEntity,
        editEntity: validEntity.copyWith(price: 1500),
      );

      expect(fakeRepository.updatedEntities, hasLength(1));
      expect(fakeRepository.updatedEntities.first.price, 1500);
    });
  });

  group('ExpenseUsecase.delete', () {
    test('リポジトリのdeleteに委譲する', () async {
      final fakeRepository = FakeExpenseRepository();
      final container = createContainer(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      final usecase = container.read(expenseUsecaseProvider);

      await usecase.delete(id: 99);

      expect(fakeRepository.deletedIds, [99]);
    });
  });
}
