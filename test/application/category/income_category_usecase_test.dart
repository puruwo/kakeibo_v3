import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/category/income_category_usecase.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';
import 'package:kakeibo/domain/ui_value/edit_income_small_category_list_value/edit_income_small_category_value.dart';
import 'package:kakeibo/view/component/app_exception.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  late FakeIncomeSmallCategoryRepository fakeSmallRepository;
  late FakeIncomeBigCategoryRepository fakeBigRepository;
  late FakeIncomeRepository fakeIncomeRepository;

  // 収入大カテゴリー（1:給与・2:ボーナスは削除不可。3:副業は削除可能）
  // 並び替えの検証のため、あえてid昇順では積まない
  const bigCategories = [
    IncomeBigCategoryEntity(
      id: 3,
      name: '副業',
      colorCode: '00FF00',
      iconPath: 'assets/images/icon_side.svg',
    ),
    IncomeBigCategoryEntity(
      id: 1,
      name: '給与',
      colorCode: '0000FF',
      iconPath: 'assets/images/icon_salary.svg',
    ),
    IncomeBigCategoryEntity(
      id: 2,
      name: 'ボーナス',
      colorCode: 'FF00FF',
      iconPath: 'assets/images/icon_bonus.svg',
    ),
  ];

  // 収入小カテゴリー（smallCategoryOrderKeyは 4 / 1 / 7 と歯抜けにしてある）
  const smallCategories = [
    IncomeSmallCategoryEntity(
      id: 10,
      smallCategoryOrderKey: 4,
      bigCategoryKey: 1,
      displayedOrderInBig: 3,
      smallCategoryName: '基本給',
      defaultDisplayed: 1,
    ),
    IncomeSmallCategoryEntity(
      id: 11,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 1,
      displayedOrderInBig: 1,
      smallCategoryName: '残業代',
      defaultDisplayed: 0,
    ),
    IncomeSmallCategoryEntity(
      id: 12,
      smallCategoryOrderKey: 7,
      bigCategoryKey: 3,
      displayedOrderInBig: 1,
      smallCategoryName: '原稿料',
      defaultDisplayed: 1,
    ),
  ];

  ProviderContainer createUsecaseContainer({
    List<IncomeSmallCategoryEntity> smalls = smallCategories,
    List<IncomeBigCategoryEntity> bigs = bigCategories,
    List<IncomeEntity> incomes = const [],
  }) {
    fakeSmallRepository = FakeIncomeSmallCategoryRepository(
      initialRecords: smalls,
    );
    fakeBigRepository = FakeIncomeBigCategoryRepository(initialRecords: bigs);
    fakeIncomeRepository = FakeIncomeRepository(initialRecords: incomes);
    return createContainer(
      overrides: [
        incomeSmallCategoryRepositoryProvider.overrideWithValue(
          fakeSmallRepository,
        ),
        incomeBigCategoryRepositoryProvider.overrideWithValue(
          fakeBigRepository,
        ),
        incomeRepositoryProvider.overrideWithValue(fakeIncomeRepository),
      ],
    );
  }

  /// 小カテゴリー編集画面のValueを組み立てる
  EditIncomeSmallCategoryValue buildEditSmall({
    required int id,
    required String name,
    int bigCategoryKey = 1,
    int smallCategoryOrderKey = 1,
    int displayOrderInBig = 1,
    int defaultDisplayed = 1,
    int editedStateDisplayOrder = 1,
    bool etitedStateIsChecked = true,
  }) {
    return EditIncomeSmallCategoryValue(
      id: id,
      bigCategoryKey: bigCategoryKey,
      name: name,
      smallCategoryOrderKey: smallCategoryOrderKey,
      displayOrderInBig: displayOrderInBig,
      defaultDisplayed: defaultDisplayed,
      editedStateDisplayOrder: editedStateDisplayOrder,
      etitedStateIsChecked: etitedStateIsChecked,
    );
  }

  group('IncomeCategoryUsecase の取得系', () {
    test('fetchAllCategory: 大カテゴリーが結合され、orderKey昇順・sortKeyが連番になる', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(incomeCategoryUsecaseProvider);

      final result = await usecase.fetchAllCategory();

      // 元のsmallCategoryOrderKeyは 1 / 4 / 7 と歯抜け
      expect(result.map((e) => e.id), [11, 10, 12]);
      expect(result.map((e) => e.smallCategoryOrderKey), [1, 4, 7]);
      expect(result.map((e) => e.sortKey), [0, 1, 2]);

      // 大カテゴリー側から結合された値
      final first = result.first;
      expect(first.categoryName, '残業代');
      expect(first.bigCategoryName, '給与');
      expect(first.colorCode, '0000FF');
      expect(first.resourcePath, 'assets/images/icon_salary.svg');
    });

    test('fetchCategoryBySmallId: 指定IDの結合済みカテゴリーが返る', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(incomeCategoryUsecaseProvider);

      final result = await usecase.fetchCategoryBySmallId(12);

      expect(result.id, 12);
      expect(result.categoryName, '原稿料');
      expect(result.bigCategoryKey, 3);
      expect(result.bigCategoryName, '副業');
      expect(result.colorCode, '00FF00');
      expect(result.resourcePath, 'assets/images/icon_side.svg');
    });

    test('fetchBigCategoryByBigId: 指定IDの大カテゴリーが返る', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(incomeCategoryUsecaseProvider);

      final result = await usecase.fetchBigCategoryByBigId(2);

      expect(result.id, 2);
      expect(result.name, 'ボーナス');
      expect(result.colorCode, 'FF00FF');
      expect(result.iconPath, 'assets/images/icon_bonus.svg');
    });

    test('fetchAllBigCategoriesWithSmallList: id昇順で小カテゴリー名がカンマ連結される', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(incomeCategoryUsecaseProvider);

      final result = await usecase.fetchAllBigCategoriesWithSmallList();

      // マスタは 3 → 1 → 2 の順で積んでいるがid昇順に並び替えられる
      expect(result.map((e) => e.id), [1, 2, 3]);
      expect(result[0].incomeSmallCategoryNameText, '基本給,残業代');
      // 小カテゴリーを1件も持たない大カテゴリーは空文字
      expect(result[1].incomeSmallCategoryNameText, '');
      expect(result[1].incomeSmallCategoryList, isEmpty);
      expect(result[2].incomeSmallCategoryNameText, '原稿料');
    });

    test('fetchSmallCategoriesByBig: displayOrderInBig昇順で連番が付与される', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(incomeCategoryUsecaseProvider);

      final result = await usecase.fetchSmallCategoriesByBig(1);

      // displayedOrderInBigは 残業代:1 / 基本給:3
      expect(result.map((e) => e.id), [11, 10]);
      expect(result.map((e) => e.displayOrderInBig), [1, 3]);
      expect(result.map((e) => e.editedStateDisplayOrder), [0, 1]);
      // defaultDisplayed == 1 のものだけチェック済みになる
      expect(result.map((e) => e.etitedStateIsChecked), [false, true]);
    });
  });

  group('IncomeCategoryUsecase.smallEdit', () {
    test('編集前の方が要素が多いとエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(incomeCategoryUsecaseProvider);

      expect(
        () => usecase.smallEdit(
          originalValues: [
            buildEditSmall(id: 10, name: '基本給'),
            buildEditSmall(id: 11, name: '残業代'),
          ],
          editValues: [buildEditSmall(id: 10, name: '基本給')],
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

    test('ID降順で対応づけられ、変更のあった行だけupdateされる', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(incomeCategoryUsecaseProvider);

      final original = [
        buildEditSmall(id: 10, name: '基本給', displayOrderInBig: 1),
        buildEditSmall(id: 11, name: '残業代', displayOrderInBig: 2),
      ];
      // originalとは逆順で渡し、ID降順に並べ替えてから対応づけられることを確かめる
      final edited = [
        buildEditSmall(id: 11, name: '残業代', displayOrderInBig: 2),
        buildEditSmall(
          id: 10,
          name: '月給',
          displayOrderInBig: 1,
          etitedStateIsChecked: false,
        ),
      ];

      await usecase.smallEdit(originalValues: original, editValues: edited);

      expect(fakeSmallRepository.updatedEntities, hasLength(1));
      final updated = fakeSmallRepository.updatedEntities.single;
      expect(updated.id, 10);
      expect(updated.smallCategoryName, '月給');
      // etitedStateIsChecked(false) → defaultDisplayed(0)
      expect(updated.defaultDisplayed, 0);
      expect(fakeSmallRepository.addedEntities, isEmpty);
    });

    test('追加行はmaxOrderKey+1から連番で採番されてaddされる', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(incomeCategoryUsecaseProvider);

      final original = [buildEditSmall(id: 10, name: '基本給')];
      final edited = [
        buildEditSmall(id: 10, name: '基本給'),
        // 追加行はUI側でid=-1が割り当てられる
        buildEditSmall(id: -1, name: '住宅手当', editedStateDisplayOrder: 2),
        buildEditSmall(id: -1, name: '通勤手当', editedStateDisplayOrder: 3),
      ];

      await usecase.smallEdit(originalValues: original, editValues: edited);

      // マスタ全体の最大smallCategoryOrderKeyは7なので8・9が採番される
      expect(fakeSmallRepository.addedEntities, hasLength(2));
      expect(
        fakeSmallRepository.addedEntities.map((e) => e.smallCategoryOrderKey),
        [8, 9],
      );
      expect(
        fakeSmallRepository.addedEntities
            .map((e) => e.smallCategoryName)
            .toSet(),
        {'住宅手当', '通勤手当'},
      );
      // 採番は追加行の大カテゴリーを指定して問い合わせる
      expect(fakeSmallRepository.getMaxOrderKeyBigCategoryIds, [1]);
    });
  });

  group('IncomeCategoryUsecase の追加・編集', () {
    test(
      'addSmallはmaxOrderKey+1で採番し、addBigはIDを返し、bigEditは差分があるときだけupdateする',
      () async {
        final container = createUsecaseContainer();
        final usecase = container.read(incomeCategoryUsecaseProvider);

        await usecase.addSmall(
          const IncomeSmallCategoryEntity(
            id: -1,
            // 仮の値。usecaseが最大値+1で上書きする
            smallCategoryOrderKey: 0,
            bigCategoryKey: 1,
            displayedOrderInBig: 4,
            smallCategoryName: '住宅手当',
            defaultDisplayed: 1,
          ),
        );

        expect(fakeSmallRepository.addedEntities, hasLength(1));
        final added = fakeSmallRepository.addedEntities.single;
        // マスタ全体の最大smallCategoryOrderKeyは7
        expect(added.smallCategoryOrderKey, 8);
        expect(added.smallCategoryName, '住宅手当');
        expect(added.displayedOrderInBig, 4);

        final addedBigId = await usecase.addBig(
          const IncomeBigCategoryEntity(
            id: -1,
            name: '配当',
            colorCode: 'AAAAAA',
            iconPath: 'assets/images/icon_dividend.svg',
          ),
        );
        expect(fakeBigRepository.addedEntities, hasLength(1));
        expect(addedBigId, isPositive);
        expect(
          fakeBigRepository.records.any((e) => e.id == addedBigId),
          isTrue,
        );

        const originalBig = IncomeBigCategoryEntity(
          id: 3,
          name: '副業',
          colorCode: '00FF00',
          iconPath: 'assets/images/icon_side.svg',
        );
        await usecase.bigEdit(original: originalBig, edit: originalBig);
        expect(fakeBigRepository.updatedEntities, isEmpty);

        await usecase.bigEdit(
          original: originalBig,
          edit: originalBig.copyWith(name: '副業収入'),
        );
        expect(fakeBigRepository.updatedEntities, hasLength(1));
        expect(fakeBigRepository.updatedEntities.single.name, '副業収入');
      },
    );

    test('updateDisplayOrders: Mapの全要素が新しい表示順でupdateされる', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(incomeCategoryUsecaseProvider);

      await usecase.updateDisplayOrders({10: 2, 11: 5});

      expect(fakeSmallRepository.updatedEntities, hasLength(2));
      final updated = fakeSmallRepository.updatedEntities;
      expect(updated.map((e) => e.id), [10, 11]);
      expect(updated.map((e) => e.smallCategoryOrderKey), [2, 5]);
      // 表示順以外の項目は既存のまま維持される
      expect(updated.first.smallCategoryName, '基本給');
      expect(updated.first.bigCategoryKey, 1);
      expect(updated.first.displayedOrderInBig, 3);
    });
  });

  group('IncomeCategoryUsecase.deleteBig', () {
    // 対象カテゴリー（大3:副業）配下の小カテゴリー12に紐づく収入と、
    // 他カテゴリー（大1:給与）配下の小カテゴリー10に紐づく収入
    const incomes = [
      IncomeEntity(id: 100, categoryId: 12, date: '20250701', price: 30000),
      IncomeEntity(id: 101, categoryId: 10, date: '20250705', price: 300000),
      IncomeEntity(id: 102, categoryId: 12, date: '20250710', price: 50000),
    ];

    test('id=1（給与）は削除できない', () async {
      final container = createUsecaseContainer(incomes: incomes);
      final usecase = container.read(incomeCategoryUsecaseProvider);

      await expectLater(
        usecase.deleteBig(1),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            'このカテゴリーは削除できません',
          ),
        ),
      );
      // 削除処理には一切進まない
      expect(fakeBigRepository.deletedIds, isEmpty);
      expect(fakeSmallRepository.deletedBigCategoryIds, isEmpty);
      expect(fakeIncomeRepository.deletedIds, isEmpty);
    });

    test('id=2（ボーナス）は削除できない', () async {
      final container = createUsecaseContainer(incomes: incomes);
      final usecase = container.read(incomeCategoryUsecaseProvider);

      await expectLater(
        usecase.deleteBig(2),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            'このカテゴリーは削除できません',
          ),
        ),
      );
      expect(fakeBigRepository.deletedIds, isEmpty);
      expect(fakeSmallRepository.deletedBigCategoryIds, isEmpty);
      expect(fakeIncomeRepository.deletedIds, isEmpty);
    });

    test('配下の小カテゴリーに紐づく収入レコードが連動削除される', () async {
      final container = createUsecaseContainer(incomes: incomes);
      final usecase = container.read(incomeCategoryUsecaseProvider);

      await usecase.deleteBig(3);

      // 小カテゴリー12に紐づくレコードだけが削除される
      expect(fakeIncomeRepository.deletedIds, [100, 102]);
    });

    test('小カテゴリーの一括削除と大カテゴリーの削除が実行される', () async {
      final container = createUsecaseContainer(incomes: incomes);
      final usecase = container.read(incomeCategoryUsecaseProvider);

      await usecase.deleteBig(3);

      expect(fakeSmallRepository.deletedBigCategoryIds, [3]);
      expect(fakeBigRepository.deletedIds, [3]);
      // マスタからも消えている
      expect(
        fakeSmallRepository.records.any((e) => e.bigCategoryKey == 3),
        isFalse,
      );
      expect(fakeBigRepository.records.any((e) => e.id == 3), isFalse);
    });

    test('対象カテゴリーに収入レコードが無ければ収入の削除は発生しない', () async {
      final container = createUsecaseContainer(
        incomes: const [
          IncomeEntity(
            id: 101,
            categoryId: 10,
            date: '20250705',
            price: 300000,
          ),
        ],
      );
      final usecase = container.read(incomeCategoryUsecaseProvider);

      await usecase.deleteBig(3);

      expect(fakeIncomeRepository.deletedIds, isEmpty);
      // カテゴリー自体の削除は実行される
      expect(fakeSmallRepository.deletedBigCategoryIds, [3]);
      expect(fakeBigRepository.deletedIds, [3]);
    });
  });

  group('IncomeCategoryUsecase のDB更新カウンタ', () {
    test('CRUD操作でDBの更新回数がインクリメントされる', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(incomeCategoryUsecaseProvider);
      final dbCount = listenUpdateDBCount(container);
      expect(dbCount.read(), 0);

      await usecase.addSmall(
        const IncomeSmallCategoryEntity(
          id: -1,
          smallCategoryOrderKey: 0,
          bigCategoryKey: 1,
          displayedOrderInBig: 4,
          smallCategoryName: '住宅手当',
          defaultDisplayed: 1,
        ),
      );

      expect(dbCount.read(), 1);
    });
  });
}
