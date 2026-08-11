import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/category/category_usecase.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/ui_value/edit_expense_small_category_list_value/edit_expense_small_category_value.dart';
import 'package:kakeibo/domain/ui_value/expense_big_category_with_small_list_value/edit_expense_big_category_value.dart';
import 'package:kakeibo/view/component/app_exception.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  late FakeExpenseSmallCategoryRepository fakeSmallRepository;
  late FakeExpenseBigCategoryRepository fakeBigRepository;

  // 支出大カテゴリー（displayOrderはid順と一致させず、並び替えを検証できるようにする）
  // 3:特別費 は小カテゴリーを1件も持たない
  const bigCategories = [
    ExpenseBigCategoryEntity(
      id: 1,
      colorCode: 'FFAA00',
      bigCategoryName: '生活費',
      resourcePath: 'assets/images/icon_life.svg',
      displayOrder: 2,
      isDisplayed: 1,
    ),
    ExpenseBigCategoryEntity(
      id: 2,
      colorCode: '00AAFF',
      bigCategoryName: 'レジャー',
      resourcePath: 'assets/images/icon_leisure.svg',
      displayOrder: 1,
      isDisplayed: 0,
    ),
    ExpenseBigCategoryEntity(
      id: 3,
      colorCode: 'FF00FF',
      bigCategoryName: '特別費',
      resourcePath: 'assets/images/icon_special.svg',
      displayOrder: 3,
      isDisplayed: 1,
    ),
  ];

  // 支出小カテゴリー（smallCategoryOrderKeyは 5 / 1 / 9 と歯抜けにしてある）
  const smallCategories = [
    ExpenseSmallCategoryEntity(
      id: 10,
      smallCategoryOrderKey: 5,
      bigCategoryKey: 1,
      displayedOrderInBig: 3,
      smallCategoryName: '食費',
      defaultDisplayed: 1,
    ),
    ExpenseSmallCategoryEntity(
      id: 11,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 1,
      displayedOrderInBig: 1,
      smallCategoryName: '日用品',
      defaultDisplayed: 0,
    ),
    ExpenseSmallCategoryEntity(
      id: 12,
      smallCategoryOrderKey: 9,
      bigCategoryKey: 2,
      displayedOrderInBig: 1,
      smallCategoryName: '旅行',
      defaultDisplayed: 1,
    ),
  ];

  ProviderContainer createUsecaseContainer({
    List<ExpenseSmallCategoryEntity> smalls = smallCategories,
    List<ExpenseBigCategoryEntity> bigs = bigCategories,
  }) {
    fakeSmallRepository = FakeExpenseSmallCategoryRepository(
      initialRecords: smalls,
    );
    fakeBigRepository = FakeExpenseBigCategoryRepository(initialRecords: bigs);
    return createContainer(
      overrides: [
        expenseSmallCategoryRepositoryProvider.overrideWithValue(
          fakeSmallRepository,
        ),
        expensebigCategoryRepositoryProvider.overrideWithValue(
          fakeBigRepository,
        ),
      ],
    );
  }

  /// 大カテゴリー編集画面のValueを組み立てる
  EditExpenseBigCategoryValue buildEditBig({
    required int id,
    required int displayOrder,
    required int editedStateDisplayOrder,
    bool etitedStateIsChecked = true,
    int isDisplayed = 1,
    String bigCategoryName = '生活費',
  }) {
    return EditExpenseBigCategoryValue(
      id: id,
      colorCode: 'FFAA00',
      bigCategoryName: bigCategoryName,
      resourcePath: 'assets/images/icon_life.svg',
      displayOrder: displayOrder,
      isDisplayed: isDisplayed,
      expenseSmallCategoryList: const [],
      expenseSmallCategoryNameText: '',
      editedStateDisplayOrder: editedStateDisplayOrder,
      etitedStateIsChecked: etitedStateIsChecked,
    );
  }

  /// 小カテゴリー編集画面のValueを組み立てる
  EditExpenseSmallCategoryValue buildEditSmall({
    required int id,
    required String name,
    int bigCategoryKey = 1,
    int smallCategoryOrderKey = 1,
    int displayOrderInBig = 1,
    int defaultDisplayed = 1,
    int editedStateDisplayOrder = 1,
    bool etitedStateIsChecked = true,
  }) {
    return EditExpenseSmallCategoryValue(
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

  group('CategoryUsecase.fetchAll', () {
    test('小カテゴリーに大カテゴリーの情報が結合される', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(categoryUsecaseProvider);

      final result = await usecase.fetchAll();

      // smallCategoryOrderKeyが最小（1）の「日用品」が先頭
      final first = result.first;
      expect(first.id, 11);
      expect(first.categoryName, '日用品');
      expect(first.bigCategoryKey, 1);
      // ここから下は大カテゴリー側から結合された値
      expect(first.bigCategoryName, '生活費');
      expect(first.colorCode, 'FFAA00');
      expect(first.resourcePath, 'assets/images/icon_life.svg');
      expect(first.displayOrder, 2);
      expect(first.isDisplayed, 1);
    });

    test('smallCategoryOrderKey昇順に並び、歯抜けでもsortKeyは0からの連番になる', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(categoryUsecaseProvider);

      final result = await usecase.fetchAll();

      // 元のsmallCategoryOrderKeyは 1 / 5 / 9 と歯抜け
      expect(result.map((e) => e.id), [11, 10, 12]);
      expect(result.map((e) => e.smallCategoryOrderKey), [1, 5, 9]);
      expect(result.map((e) => e.sortKey), [0, 1, 2]);
    });
  });

  group('CategoryUsecase.fetchBySmallId', () {
    test('指定IDの小カテゴリーに大カテゴリーを結合して返す', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(categoryUsecaseProvider);

      final result = await usecase.fetchBySmallId(12);

      expect(result.id, 12);
      expect(result.categoryName, '旅行');
      expect(result.smallCategoryOrderKey, 9);
      expect(result.displaydOrderInBig, 1);
      expect(result.bigCategoryName, 'レジャー');
      expect(result.colorCode, '00AAFF');
      expect(result.isDisplayed, 0);
    });
  });

  group('CategoryUsecase.fetchAllBigCategoriesWithSmallList', () {
    test('小カテゴリー名がカンマ連結される（先頭カンマなし・0個なら空文字）', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(categoryUsecaseProvider);

      final result = await usecase.fetchAllBigCategoriesWithSmallList();

      final big1 = result.firstWhere((e) => e.id == 1);
      expect(big1.expenseSmallCategoryNameText, '食費,日用品');
      final big2 = result.firstWhere((e) => e.id == 2);
      expect(big2.expenseSmallCategoryNameText, '旅行');
      // 小カテゴリーを1件も持たない大カテゴリーは空文字
      final big3 = result.firstWhere((e) => e.id == 3);
      expect(big3.expenseSmallCategoryNameText, '');
      expect(big3.expenseSmallCategoryList, isEmpty);
    });

    test('displayOrder昇順に並び、editedStateDisplayOrderが0からの連番になる', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(categoryUsecaseProvider);

      final result = await usecase.fetchAllBigCategoriesWithSmallList();

      // displayOrderは 2 / 1 / 3 なので id順は 2 → 1 → 3
      expect(result.map((e) => e.id), [2, 1, 3]);
      expect(result.map((e) => e.displayOrder), [1, 2, 3]);
      expect(result.map((e) => e.editedStateDisplayOrder), [0, 1, 2]);
      // isDisplayedのint→boolの初期変換
      expect(result.map((e) => e.etitedStateIsChecked), [false, true, true]);
    });
  });

  group('CategoryUsecase.fetchSmallCategoriesByBig', () {
    test('displayOrderInBig昇順に並び、連番付与とチェック状態の初期化が行われる', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(categoryUsecaseProvider);

      final result = await usecase.fetchSmallCategoriesByBig(1);

      // displayedOrderInBigは 日用品:1 / 食費:3
      expect(result.map((e) => e.id), [11, 10]);
      expect(result.map((e) => e.displayOrderInBig), [1, 3]);
      expect(result.map((e) => e.editedStateDisplayOrder), [0, 1]);
      // defaultDisplayed == 1 のものだけチェック済みになる
      expect(result.map((e) => e.etitedStateIsChecked), [false, true]);
    });
  });

  group('CategoryUsecase.bigCategoriesEdit', () {
    test('リストの長さが一致しないとエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(categoryUsecaseProvider);

      expect(
        () => usecase.bigCategoriesEdit(
          originalValues: [
            buildEditBig(id: 1, displayOrder: 1, editedStateDisplayOrder: 0),
          ],
          editValues: [
            buildEditBig(id: 1, displayOrder: 1, editedStateDisplayOrder: 0),
            buildEditBig(id: 2, displayOrder: 2, editedStateDisplayOrder: 1),
          ],
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

    test('変更のあった行だけupdateされ、チェック状態はint（0/1）に変換される', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(categoryUsecaseProvider);

      final original = [
        buildEditBig(id: 1, displayOrder: 1, editedStateDisplayOrder: 0),
        buildEditBig(id: 2, displayOrder: 2, editedStateDisplayOrder: 1),
      ];
      final edited = [
        // 1件目は変更なし
        buildEditBig(id: 1, displayOrder: 1, editedStateDisplayOrder: 0),
        // 2件目だけ表示順とチェック状態を変更
        buildEditBig(
          id: 2,
          displayOrder: 2,
          editedStateDisplayOrder: 5,
          etitedStateIsChecked: false,
        ),
      ];

      await usecase.bigCategoriesEdit(
        originalValues: original,
        editValues: edited,
      );

      expect(fakeBigRepository.updatedEntities, hasLength(1));
      final updated = fakeBigRepository.updatedEntities.single;
      expect(updated.id, 2);
      // editedStateDisplayOrderがdisplayOrderへ書き込まれる
      expect(updated.displayOrder, 5);
      // etitedStateIsChecked(false) → isDisplayed(0)
      expect(updated.isDisplayed, 0);
    });
  });

  group('CategoryUsecase.bigEdit', () {
    test('同じ内容ならupdateされず、変更があればupdateされる', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(categoryUsecaseProvider);

      const original = ExpenseBigCategoryEntity(
        id: 1,
        colorCode: 'FFAA00',
        bigCategoryName: '生活費',
        resourcePath: 'assets/images/icon_life.svg',
        displayOrder: 2,
        isDisplayed: 1,
      );

      await usecase.bigEdit(original: original, edit: original);
      expect(fakeBigRepository.updatedEntities, isEmpty);

      await usecase.bigEdit(
        original: original,
        edit: original.copyWith(bigCategoryName: '生活費（改）'),
      );
      expect(fakeBigRepository.updatedEntities, hasLength(1));
      expect(
        fakeBigRepository.updatedEntities.single.bigCategoryName,
        '生活費（改）',
      );
    });
  });

  group('CategoryUsecase.smallEdit', () {
    test('編集前の方が要素が多いとエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(categoryUsecaseProvider);

      expect(
        () => usecase.smallEdit(
          originalValues: [
            buildEditSmall(id: 10, name: '食費'),
            buildEditSmall(id: 11, name: '日用品'),
          ],
          editValues: [buildEditSmall(id: 10, name: '食費')],
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
      final usecase = container.read(categoryUsecaseProvider);

      final original = [
        buildEditSmall(id: 10, name: '食費', displayOrderInBig: 1),
        buildEditSmall(id: 11, name: '日用品', displayOrderInBig: 2),
      ];
      // originalとは逆順で渡し、ID降順に並べ替えてから対応づけられることを確かめる
      final edited = [
        buildEditSmall(id: 11, name: '日用品', displayOrderInBig: 2),
        buildEditSmall(
          id: 10,
          name: '食料品',
          displayOrderInBig: 1,
          etitedStateIsChecked: false,
        ),
      ];

      await usecase.smallEdit(originalValues: original, editValues: edited);

      expect(fakeSmallRepository.updatedEntities, hasLength(1));
      final updated = fakeSmallRepository.updatedEntities.single;
      expect(updated.id, 10);
      expect(updated.smallCategoryName, '食料品');
      // etitedStateIsChecked(false) → defaultDisplayed(0)
      expect(updated.defaultDisplayed, 0);
      expect(fakeSmallRepository.addedEntities, isEmpty);
    });

    test('追加行はmaxOrderKey+1から連番で採番されてaddされる', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(categoryUsecaseProvider);

      final original = [buildEditSmall(id: 10, name: '食費')];
      final edited = [
        buildEditSmall(id: 10, name: '食費'),
        // 追加行はUI側でid=-1が割り当てられる
        buildEditSmall(id: -1, name: 'カフェ', editedStateDisplayOrder: 2),
        buildEditSmall(id: -1, name: '外食', editedStateDisplayOrder: 3),
      ];

      await usecase.smallEdit(originalValues: original, editValues: edited);

      // マスタ全体の最大smallCategoryOrderKeyは9なので10・11が採番される
      expect(fakeSmallRepository.addedEntities, hasLength(2));
      expect(
        fakeSmallRepository.addedEntities.map((e) => e.smallCategoryOrderKey),
        [10, 11],
      );
      expect(
        fakeSmallRepository.addedEntities
            .map((e) => e.smallCategoryName)
            .toSet(),
        {'カフェ', '外食'},
      );
      // 採番は追加行の大カテゴリーを指定して問い合わせる
      expect(fakeSmallRepository.getMaxOrderKeyBigCategoryIds, [1]);
    });
  });

  group('CategoryUsecase.addSmall / addBig', () {
    test('addSmallはmaxOrderKey+1で採番し、addBigは採番されたIDを返す', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(categoryUsecaseProvider);

      await usecase.addSmall(
        const ExpenseSmallCategoryEntity(
          id: -1,
          // 仮の値。usecaseが最大値+1で上書きする
          smallCategoryOrderKey: 0,
          bigCategoryKey: 1,
          displayedOrderInBig: 4,
          smallCategoryName: 'カフェ',
          defaultDisplayed: 1,
        ),
      );

      expect(fakeSmallRepository.addedEntities, hasLength(1));
      final added = fakeSmallRepository.addedEntities.single;
      // マスタ全体の最大smallCategoryOrderKeyは9
      expect(added.smallCategoryOrderKey, 10);
      expect(added.smallCategoryName, 'カフェ');
      expect(added.displayedOrderInBig, 4);

      final addedBigId = await usecase.addBig(
        const ExpenseBigCategoryEntity(
          id: -1,
          colorCode: '00FF00',
          bigCategoryName: '教育費',
          resourcePath: 'assets/images/icon_education.svg',
          displayOrder: 4,
          isDisplayed: 1,
        ),
      );

      expect(fakeBigRepository.addedEntities, hasLength(1));
      expect(addedBigId, isPositive);
      expect(fakeBigRepository.records.any((e) => e.id == addedBigId), isTrue);
    });
  });

  group('CategoryUsecase.updateDisplayOrders', () {
    test('Mapの全要素が新しい表示順でupdateされる', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(categoryUsecaseProvider);

      await usecase.updateDisplayOrders({10: 3, 11: 7});

      expect(fakeSmallRepository.updatedEntities, hasLength(2));
      final updated = fakeSmallRepository.updatedEntities;
      expect(updated.map((e) => e.id), [10, 11]);
      expect(updated.map((e) => e.smallCategoryOrderKey), [3, 7]);
      // 表示順以外の項目は既存のまま維持される
      expect(updated.first.smallCategoryName, '食費');
      expect(updated.first.bigCategoryKey, 1);
      expect(updated.first.displayedOrderInBig, 3);
    });
  });
}
