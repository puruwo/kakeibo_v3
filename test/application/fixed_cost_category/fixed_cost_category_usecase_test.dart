import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost_category/fixed_cost_category_provider.dart';
import 'package:kakeibo/application/fixed_cost_category/fixed_cost_category_usecase.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
import 'package:kakeibo/view/component/app_exception.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  late FakeFixedCostCategoryRepository fakeRepository;

  // 固定費カテゴリーマスタ（displayOrderはid順と一致させず、並び替えを検証できるようにする）
  const categories = [
    FixedCostCategoryEntity(
      id: 1,
      categoryName: '住居',
      colorCode: 'FFAA00',
      resourcePath: 'assets/images/icon_home.svg',
      displayOrder: 2,
    ),
    FixedCostCategoryEntity(
      id: 2,
      categoryName: '光熱費',
      colorCode: '00AAFF',
      resourcePath: 'assets/images/icon_utility.svg',
      displayOrder: 0,
    ),
    FixedCostCategoryEntity(
      id: 3,
      categoryName: '通信費',
      colorCode: 'FF00FF',
      resourcePath: 'assets/images/icon_net.svg',
      displayOrder: 1,
    ),
  ];

  ProviderContainer createUsecaseContainer({
    List<FixedCostCategoryEntity> initialRecords = categories,
  }) {
    fakeRepository = FakeFixedCostCategoryRepository(
      initialRecords: initialRecords,
    );
    return createContainer(
      overrides: [
        fixedCostCategoryRepositoryProvider.overrideWithValue(fakeRepository),
      ],
    );
  }

  // バリデーションが通る基本の登録エンティティ（displayOrderは仮の値）
  const validEntity = FixedCostCategoryEntity(
    categoryName: '保険',
    colorCode: '00FF00',
    resourcePath: 'assets/images/icon_insurance.svg',
  );

  group('FixedCostCategoryUsecase.add', () {
    test('カテゴリー名が空ならエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostCategoryUsecaseProvider);

      expect(
        () => usecase.add(entity: validEntity.copyWith(categoryName: '')),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            'カテゴリー名を入力してください',
          ),
        ),
      );
    });

    test('displayOrderは既存の最大値+1で採番されてinsertされる', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostCategoryUsecaseProvider);

      await usecase.add(entity: validEntity);

      expect(fakeRepository.insertedEntities, hasLength(1));
      final inserted = fakeRepository.insertedEntities.single;
      // 既存の最大displayOrderは2
      expect(inserted.displayOrder, 3);
      expect(inserted.categoryName, '保険');
    });
  });

  group('FixedCostCategoryUsecase.edit', () {
    const original = FixedCostCategoryEntity(
      id: 1,
      categoryName: '住居',
      colorCode: 'FFAA00',
      resourcePath: 'assets/images/icon_home.svg',
      displayOrder: 2,
    );

    test('変更がなければエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostCategoryUsecaseProvider);

      expect(
        () => usecase.edit(originalEntity: original, editEntity: original),
        throwsA(
          isA<AppException>().having((e) => e.message, 'message', '変更がありません'),
        ),
      );
    });

    test('カテゴリー名が空ならエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostCategoryUsecaseProvider);

      expect(
        () => usecase.edit(
          originalEntity: original,
          editEntity: original.copyWith(categoryName: ''),
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            'カテゴリー名を入力してください',
          ),
        ),
      );
    });

    test('変更があればupdateされる', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostCategoryUsecaseProvider);

      await usecase.edit(
        originalEntity: original,
        editEntity: original.copyWith(categoryName: '家賃・住居'),
      );

      expect(fakeRepository.updatedEntities, hasLength(1));
      expect(fakeRepository.updatedEntities.single.id, 1);
      expect(fakeRepository.updatedEntities.single.categoryName, '家賃・住居');
    });
  });

  group('FixedCostCategoryUsecase.delete', () {
    test('リポジトリの削除へ委譲される', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostCategoryUsecaseProvider);

      await usecase.delete(id: 2);

      expect(fakeRepository.deletedIds, [2]);
      expect(fakeRepository.records.any((e) => e.id == 2), isFalse);
    });
  });

  group('FixedCostCategoryUsecase.toggleDisplay', () {
    test('isDisplayedだけを書き換えてupdateされる', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostCategoryUsecaseProvider);

      await usecase.toggleDisplay(id: 1, isDisplayed: 0);

      expect(fakeRepository.updatedEntities, hasLength(1));
      final updated = fakeRepository.updatedEntities.single;
      expect(updated.isDisplayed, 0);
      // 他の項目は元のまま
      expect(updated.id, 1);
      expect(updated.categoryName, '住居');
      expect(updated.displayOrder, 2);
    });
  });

  group('FixedCostCategoryUsecase.updateDisplayOrder', () {
    test('渡されたリストの順序で0からの連番に振り直される', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostCategoryUsecaseProvider);

      // 通信費 → 住居 → 光熱費 の順に並べ替えた想定
      await usecase.updateDisplayOrder(
        entities: [categories[2], categories[0], categories[1]],
      );

      expect(fakeRepository.updatedEntities, hasLength(3));
      expect(fakeRepository.updatedEntities.map((e) => e.id), [3, 1, 2]);
      expect(fakeRepository.updatedEntities.map((e) => e.displayOrder), [
        0,
        1,
        2,
      ]);
    });
  });

  group('FixedCostCategoryUsecase.updateDisplayOrders', () {
    test('Mapで指定された表示順に一括更新される', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostCategoryUsecaseProvider);

      await usecase.updateDisplayOrders({3: 0, 1: 1, 2: 2});

      expect(fakeRepository.updatedEntities, hasLength(3));
      expect(fakeRepository.updatedEntities.map((e) => e.id), [3, 1, 2]);
      expect(fakeRepository.updatedEntities.map((e) => e.displayOrder), [
        0,
        1,
        2,
      ]);
      // 表示順以外は既存のまま維持される
      expect(fakeRepository.updatedEntities.first.categoryName, '通信費');
    });
  });

  group('allFixedCostCategoriesProvider', () {
    test('displayOrder昇順にソートされて返る', () async {
      final container = createUsecaseContainer();

      final result = await container.read(
        allFixedCostCategoriesProvider.future,
      );

      // マスタの並びは 1(2) → 2(0) → 3(1) だがdisplayOrder昇順になる
      expect(result.map((e) => e.id), [2, 3, 1]);
      expect(result.map((e) => e.displayOrder), [0, 1, 2]);
    });
  });
}
