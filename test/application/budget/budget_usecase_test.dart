import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/budget/budget_usecase.dart';
import 'package:kakeibo/domain/db/budget/budget_entity.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';
import 'package:kakeibo/domain/ui_value/budget_edit_value/budget_edit_value.dart';
import 'package:kakeibo/view/component/app_exception.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  BudgetEditValue buildEditValue({
    required int id,
    required BudgetStatus status,
    required int price,
    int bigCategoryId = 1,
  }) {
    return BudgetEditValue(
      id: id,
      budgetStatus: status,
      expenseBigCategoryId: bigCategoryId,
      month: '202507',
      price: price,
      lastMonthBudgetPrice: 0,
      expenseBigCategoryName: '食費',
      colorCode: 'FFFFFF',
      resourcePath: '',
      displayOrder: 1,
    );
  }

  group('BudgetUsecase.edit', () {
    test('元リストと編集金額リストの長さが違えばエラー', () async {
      final fakeRepository = FakeBudgetRepository();
      final container = createContainer(
        overrides: [budgetRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      final usecase = container.read(budgetUsecaseProvider);

      await expectLater(
        () => usecase.edit(
          originalValues: [
            buildEditValue(id: 1, status: BudgetStatus.registerd, price: 10000),
          ],
          editPrice: [10000, 20000],
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '予期せぬエラーが発生しました(E001)',
          ),
        ),
      );
    });

    test('金額に変更がなければ書き込みは発生しない', () async {
      final fakeRepository = FakeBudgetRepository();
      final container = createContainer(
        overrides: [budgetRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      final usecase = container.read(budgetUsecaseProvider);

      await usecase.edit(
        originalValues: [
          buildEditValue(id: 1, status: BudgetStatus.registerd, price: 10000),
        ],
        editPrice: [10000],
      );

      expect(fakeRepository.updatedEntities, isEmpty);
      expect(fakeRepository.insertedEntities, isEmpty);
    });

    test('登録済みの予算の金額変更はupdateになる', () async {
      final fakeRepository = FakeBudgetRepository();
      final container = createContainer(
        overrides: [budgetRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      final usecase = container.read(budgetUsecaseProvider);

      await usecase.edit(
        originalValues: [
          buildEditValue(id: 1, status: BudgetStatus.registerd, price: 10000),
        ],
        editPrice: [15000],
      );

      expect(fakeRepository.updatedEntities, hasLength(1));
      expect(fakeRepository.updatedEntities.first.price, 15000);
      expect(fakeRepository.insertedEntities, isEmpty);
    });

    test('未登録の予算に金額を入れるとinsertになる', () async {
      final fakeRepository = FakeBudgetRepository();
      final container = createContainer(
        overrides: [budgetRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      final usecase = container.read(budgetUsecaseProvider);

      await usecase.edit(
        originalValues: [
          buildEditValue(id: -1, status: BudgetStatus.notRegisterd, price: 0),
        ],
        editPrice: [20000],
      );

      expect(fakeRepository.insertedEntities, hasLength(1));
      expect(fakeRepository.insertedEntities.first.price, 20000);
      expect(fakeRepository.updatedEntities, isEmpty);
    });

    test('複数カテゴリーの一括編集は変更があった行だけ書き込む', () async {
      final fakeRepository = FakeBudgetRepository();
      final container = createContainer(
        overrides: [budgetRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      final usecase = container.read(budgetUsecaseProvider);

      await usecase.edit(
        originalValues: [
          buildEditValue(id: 1, status: BudgetStatus.registerd, price: 10000),
          buildEditValue(
            id: -1,
            status: BudgetStatus.notRegisterd,
            price: 0,
            bigCategoryId: 2,
          ),
          buildEditValue(
            id: 3,
            status: BudgetStatus.registerd,
            price: 5000,
            bigCategoryId: 3,
          ),
        ],
        editPrice: [12000, 8000, 5000],
      );

      // 1行目: update、2行目: insert、3行目: 変更なし
      expect(fakeRepository.updatedEntities, hasLength(1));
      expect(fakeRepository.updatedEntities.first.expenseBigCategoryId, 1);
      expect(fakeRepository.insertedEntities, hasLength(1));
      expect(fakeRepository.insertedEntities.first.expenseBigCategoryId, 2);
    });
  });

  group('BudgetUsecase.add', () {
    test('リポジトリに挿入する', () async {
      final fakeRepository = FakeBudgetRepository();
      final container = createContainer(
        overrides: [budgetRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      final usecase = container.read(budgetUsecaseProvider);

      await usecase.add(
        entity: const BudgetEntity(
          expenseBigCategoryId: 1,
          month: '202507',
          price: 30000,
        ),
      );

      expect(fakeRepository.insertedEntities, hasLength(1));
    });
  });
}
