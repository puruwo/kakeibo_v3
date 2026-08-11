import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/income/income_usecase.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/view/component/app_exception.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  const validEntity = IncomeEntity(date: '20250725', price: 300000);

  group('IncomeUsecase.add', () {
    test('金額0円以下ならエラーで登録しない', () async {
      final fakeRepository = FakeIncomeRepository();
      final container = createContainer(
        overrides: [incomeRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      final usecase = container.read(incomeUsecaseProvider);

      await expectLater(
        () => usecase.add(incomeEntity: validEntity.copyWith(price: 0)),
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

    test('金額が上限（99,999,999円）以上ならエラー', () async {
      final fakeRepository = FakeIncomeRepository();
      final container = createContainer(
        overrides: [incomeRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      final usecase = container.read(incomeUsecaseProvider);

      await expectLater(
        () => usecase.add(incomeEntity: validEntity.copyWith(price: 99999999)),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '金額の入力値が大き過ぎます',
          ),
        ),
      );
    });

    test('カテゴリー未選択（ID 0）ならエラーで登録しない', () async {
      final fakeRepository = FakeIncomeRepository();
      final container = createContainer(
        overrides: [incomeRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      final usecase = container.read(incomeUsecaseProvider);

      // 収入小カテゴリーが0件だと未選択のまま保存操作まで進める
      await expectLater(
        () => usecase.add(incomeEntity: validEntity.copyWith(categoryId: 0)),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            'カテゴリーを選択してください',
          ),
        ),
      );
      expect(fakeRepository.insertedEntities, isEmpty);
    });

    test('正常な登録はリポジトリに挿入する', () async {
      final fakeRepository = FakeIncomeRepository();
      final container = createContainer(
        overrides: [incomeRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      final usecase = container.read(incomeUsecaseProvider);

      await usecase.add(incomeEntity: validEntity);

      expect(fakeRepository.insertedEntities, hasLength(1));
      expect(fakeRepository.insertedEntities.first.price, 300000);
    });
  });

  group('IncomeUsecase.edit', () {
    test('変更がなければエラー', () async {
      final fakeRepository = FakeIncomeRepository();
      final container = createContainer(
        overrides: [incomeRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      final usecase = container.read(incomeUsecaseProvider);

      await expectLater(
        () =>
            usecase.edit(originalEntity: validEntity, editEntity: validEntity),
        throwsA(
          isA<AppException>().having((e) => e.message, 'message', '変更がありません'),
        ),
      );
    });

    test('カテゴリー未選択（ID 0）ならエラーで更新しない', () async {
      final fakeRepository = FakeIncomeRepository();
      final container = createContainer(
        overrides: [incomeRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      final usecase = container.read(incomeUsecaseProvider);

      await expectLater(
        () => usecase.edit(
          originalEntity: validEntity,
          editEntity: validEntity.copyWith(categoryId: 0),
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            'カテゴリーを選択してください',
          ),
        ),
      );
      expect(fakeRepository.updatedEntities, isEmpty);
    });

    test('正常な編集はリポジトリを更新する', () async {
      final fakeRepository = FakeIncomeRepository();
      final container = createContainer(
        overrides: [incomeRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      final usecase = container.read(incomeUsecaseProvider);

      await usecase.edit(
        originalEntity: validEntity,
        editEntity: validEntity.copyWith(price: 320000),
      );

      expect(fakeRepository.updatedEntities, hasLength(1));
      expect(fakeRepository.updatedEntities.first.price, 320000);
    });
  });

  group('IncomeUsecase.delete', () {
    test('リポジトリのdeleteに委譲する', () async {
      final fakeRepository = FakeIncomeRepository();
      final container = createContainer(
        overrides: [incomeRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      final usecase = container.read(incomeUsecaseProvider);

      await usecase.delete(id: 7);

      expect(fakeRepository.deletedIds, [7]);
    });
  });
}
