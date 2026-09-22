import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/category/category_usecase.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/ui_value/edit_expense_small_category_list_value/edit_expense_small_category_value.dart';
import 'package:kakeibo/domain/ui_value/expense_big_category_with_small_list_value/edit_expense_big_category_value.dart';
import 'package:kakeibo/view/component/app_exception.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  late FakeExpenseSmallCategoryRepository fakeSmallRepository;
  late FakeExpenseBigCategoryRepository fakeBigRepository;
  late FakeFixedCostRepository fakeFixedCostRepository;

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
    List<FixedCostEntity> fixedCosts = const [],
  }) {
    fakeSmallRepository = FakeExpenseSmallCategoryRepository(
      initialRecords: smalls,
    );
    fakeBigRepository = FakeExpenseBigCategoryRepository(initialRecords: bigs);
    fakeFixedCostRepository = FakeFixedCostRepository(
      initialRecords: fixedCosts,
    );
    return createContainer(
      overrides: [
        expenseSmallCategoryRepositoryProvider.overrideWithValue(
          fakeSmallRepository,
        ),
        expensebigCategoryRepositoryProvider.overrideWithValue(
          fakeBigRepository,
        ),
        fixedCostRepositoryProvider.overrideWithValue(fakeFixedCostRepository),
      ],
    );
  }

  /// 小カテゴリー[smallCategoryId]を使う固定費マスタ（KP-024 の削除ガード検証用）
  FixedCostEntity buildFixedCost({
    required int id,
    required String name,
    required int smallCategoryId,
    int deleteFlag = 0,
  }) {
    return FixedCostEntity(
      id: id,
      name: name,
      variable: 0,
      price: 80000,
      expenseSmallCategoryId: smallCategoryId,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250125',
      deleteFlag: deleteFlag,
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

    test('削除済みの小カテゴリーは入力画面向けの一覧に出さず、sortKeyは詰めて振る', () async {
      final container = createUsecaseContainer(
        smalls: [
          smallCategories[0],
          // smallCategoryOrderKey が最小の「日用品」を削除済みにする
          smallCategories[1].copyWith(deleteFlag: 1),
          smallCategories[2],
        ],
      );
      final usecase = container.read(categoryUsecaseProvider);

      final result = await usecase.fetchAll();

      expect(result.map((e) => e.id), [10, 12]);
      expect(result.map((e) => e.sortKey), [0, 1]);
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

    test('削除済みの大カテゴリーは並べず、削除済みの小カテゴリーは名前に含めない', () async {
      final container = createUsecaseContainer(
        bigs: [
          bigCategories[0],
          bigCategories[1].copyWith(deleteFlag: 1),
          bigCategories[2],
        ],
        smalls: [
          smallCategories[0],
          smallCategories[1].copyWith(deleteFlag: 1),
          smallCategories[2],
        ],
      );
      final usecase = container.read(categoryUsecaseProvider);

      final result = await usecase.fetchAllBigCategoriesWithSmallList();

      // レジャー（id=2）が外れ、表示順は 1 → 3 を 0 からの連番で振り直す
      expect(result.map((e) => e.id), [1, 3]);
      expect(result.map((e) => e.editedStateDisplayOrder), [0, 1]);
      // 生活費の小カテゴリーは食費だけ（日用品は削除済み）
      expect(result.first.expenseSmallCategoryNameText, '食費');
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

    test('削除済みの小カテゴリーは詳細画面の編集対象に出さない', () async {
      final container = createUsecaseContainer(
        smalls: [
          smallCategories[0].copyWith(deleteFlag: 1),
          smallCategories[1],
          smallCategories[2],
        ],
      );
      final usecase = container.read(categoryUsecaseProvider);

      final result = await usecase.fetchSmallCategoriesByBig(1);

      expect(result.map((e) => e.id), [11]);
      expect(result.map((e) => e.editedStateDisplayOrder), [0]);
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
    // KP-024: 詳細画面の丸マイナスで外した既存項目は、保存時に論理削除する
    test('編集中リストから外した既存項目は論理削除され、行は残る', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(categoryUsecaseProvider);

      await usecase.smallEdit(
        originalValues: [
          buildEditSmall(id: 10, name: '食費'),
          buildEditSmall(id: 11, name: '日用品'),
        ],
        editValues: [buildEditSmall(id: 10, name: '食費')],
      );

      expect(fakeSmallRepository.logicallyDeletedIds, [11]);
      expect(
        fakeSmallRepository.records.firstWhere((e) => e.id == 11).deleteFlag,
        1,
      );
      // 残した項目は変更が無いので書き込まない
      expect(fakeSmallRepository.updatedEntities, isEmpty);
    });

    test('固定費が使っている小カテゴリーを外すとエラーになり、ほかの変更も書き込まない', () async {
      final container = createUsecaseContainer(
        fixedCosts: [buildFixedCost(id: 1, name: '家賃', smallCategoryId: 11)],
      );
      final usecase = container.read(categoryUsecaseProvider);

      await expectLater(
        usecase.smallEdit(
          originalValues: [
            buildEditSmall(id: 10, name: '食費'),
            buildEditSmall(id: 11, name: '日用品'),
          ],
          // 名前の変更も同時にしているが、検証で止まるので書き込まれない
          editValues: [buildEditSmall(id: 10, name: '食料品')],
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '固定費「家賃」が使っているため削除できません',
          ),
        ),
      );
      expect(fakeSmallRepository.logicallyDeletedIds, isEmpty);
      expect(fakeSmallRepository.updatedEntities, isEmpty);
    });

    test('削除済みの固定費だけが使っている小カテゴリーは削除できる', () async {
      final container = createUsecaseContainer(
        fixedCosts: [
          buildFixedCost(id: 1, name: '家賃', smallCategoryId: 11, deleteFlag: 1),
        ],
      );
      final usecase = container.read(categoryUsecaseProvider);

      await usecase.smallEdit(
        originalValues: [
          buildEditSmall(id: 10, name: '食費'),
          buildEditSmall(id: 11, name: '日用品'),
        ],
        editValues: [buildEditSmall(id: 10, name: '食費')],
      );

      expect(fakeSmallRepository.logicallyDeletedIds, [11]);
    });

    test('小カテゴリーをすべて外すとエラー（最後の1件は残す）', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(categoryUsecaseProvider);

      await expectLater(
        usecase.smallEdit(
          originalValues: [buildEditSmall(id: 10, name: '食費')],
          editValues: const [],
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '小カテゴリーは1件以上必要です',
          ),
        ),
      );
      expect(fakeSmallRepository.logicallyDeletedIds, isEmpty);
    });

    test('idで対応づけられ、変更のあった行だけupdateされる', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(categoryUsecaseProvider);

      final original = [
        buildEditSmall(id: 10, name: '食費', displayOrderInBig: 1),
        buildEditSmall(id: 11, name: '日用品', displayOrderInBig: 2),
      ];
      // originalとは逆順で渡し、並び順ではなくidで対応づけられることを確かめる
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
        buildEditSmall(id: 10, name: '食費', editedStateDisplayOrder: 0),
        // まだDBに無い項目は編集中リストが負の一意なidを振る
        buildEditSmall(id: -1, name: 'カフェ', editedStateDisplayOrder: 1),
        buildEditSmall(id: -2, name: '外食', editedStateDisplayOrder: 2),
      ];

      await usecase.smallEdit(originalValues: original, editValues: edited);

      // マスタ全体の最大smallCategoryOrderKeyは9なので10・11が採番される
      expect(fakeSmallRepository.addedEntities, hasLength(2));
      expect(
        fakeSmallRepository.addedEntities.map((e) => e.smallCategoryOrderKey),
        [10, 11],
      );
      // 採番は編集中リストの並び順で行う（idの大小には依存しない）
      expect(
        fakeSmallRepository.addedEntities.map((e) => e.smallCategoryName),
        ['カフェ', '外食'],
      );
      // 表示順は編集中リストの値をそのまま保存する
      expect(
        fakeSmallRepository.addedEntities.map((e) => e.displayedOrderInBig),
        [1, 2],
      );
      // 採番は追加行の大カテゴリーを指定して問い合わせる
      expect(fakeSmallRepository.getMaxOrderKeyBigCategoryIds, [1]);
    });

    test('仮idが同じ順でなくても編集中リストの並び順で採番される', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(categoryUsecaseProvider);

      final original = [
        buildEditSmall(id: 10, name: '食費', editedStateDisplayOrder: 0),
      ];
      // 3件追加したあと先頭へ並べ替えた状態（id の降順・昇順のどちらでもない）
      final edited = [
        buildEditSmall(id: -3, name: 'おやつ', editedStateDisplayOrder: 0),
        buildEditSmall(id: 10, name: '食費', editedStateDisplayOrder: 1),
        buildEditSmall(id: -1, name: 'カフェ', editedStateDisplayOrder: 2),
        buildEditSmall(id: -2, name: '弁当', editedStateDisplayOrder: 3),
      ];

      await usecase.smallEdit(originalValues: original, editValues: edited);

      expect(
        fakeSmallRepository.addedEntities.map((e) => e.smallCategoryName),
        ['おやつ', 'カフェ', '弁当'],
      );
      expect(
        fakeSmallRepository.addedEntities.map((e) => e.smallCategoryOrderKey),
        [10, 11, 12],
      );
      // 既存項目は表示順が変わったのでupdateされる
      expect(fakeSmallRepository.updatedEntities, hasLength(1));
      expect(fakeSmallRepository.updatedEntities.single.id, 10);
      expect(fakeSmallRepository.updatedEntities.single.displayedOrderInBig, 1);
    });

    test('編集前に無いidが既存項目として来るとエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(categoryUsecaseProvider);

      expect(
        () => usecase.smallEdit(
          originalValues: [buildEditSmall(id: 10, name: '食費')],
          editValues: [buildEditSmall(id: 99, name: '食費')],
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

    test('引数で渡したリストを並べ替えない', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(categoryUsecaseProvider);

      // providerが保持しているリストをそのまま渡すため、副作用があってはならない
      final original = [
        buildEditSmall(id: 10, name: '食費'),
        buildEditSmall(id: 11, name: '日用品'),
      ];
      final edited = [
        buildEditSmall(id: 11, name: '日用品', editedStateDisplayOrder: 0),
        buildEditSmall(id: 10, name: '食費', editedStateDisplayOrder: 1),
      ];

      await usecase.smallEdit(originalValues: original, editValues: edited);

      expect(original.map((e) => e.id), [10, 11]);
      expect(edited.map((e) => e.id), [11, 10]);
    });
  });

  group('CategoryUsecase.fetchFixedCostNamesUsingSmallCategories', () {
    test('指定した小カテゴリーを使う有効な固定費の名前だけを返す', () async {
      final container = createUsecaseContainer(
        fixedCosts: [
          buildFixedCost(id: 1, name: '家賃', smallCategoryId: 10),
          buildFixedCost(id: 2, name: 'ジム', smallCategoryId: 12),
          // 削除済みの固定費は対象外
          buildFixedCost(id: 3, name: '旧回線', smallCategoryId: 10, deleteFlag: 1),
        ],
      );
      final usecase = container.read(categoryUsecaseProvider);

      final names = await usecase.fetchFixedCostNamesUsingSmallCategories([
        10,
        11,
      ]);

      expect(names, ['家賃']);
    });

    test('小カテゴリーを指定しなければ空を返す', () async {
      final container = createUsecaseContainer(
        fixedCosts: [buildFixedCost(id: 1, name: '家賃', smallCategoryId: 10)],
      );
      final usecase = container.read(categoryUsecaseProvider);

      expect(await usecase.fetchFixedCostNamesUsingSmallCategories([]), isEmpty);
    });
  });

  group('CategoryUsecase.deleteBig', () {
    test('大カテゴリーを配下の小カテゴリーごと論理削除し、行は残る', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(categoryUsecaseProvider);
      final dbCount = listenUpdateDBCount(container);

      await usecase.deleteBig(1);

      // 生活費（id=1）の配下は 食費(10)・日用品(11)
      expect(fakeSmallRepository.logicallyDeletedIds, [10, 11]);
      expect(fakeBigRepository.logicallyDeletedIds, [1]);
      expect(fakeBigRepository.records, hasLength(3));
      expect(
        fakeBigRepository.records.firstWhere((e) => e.id == 1).deleteFlag,
        1,
      );
      expect(dbCount.read(), 1);
    });

    test('固定費が配下の小カテゴリーを使っているとエラーになり何も削除しない', () async {
      final container = createUsecaseContainer(
        fixedCosts: [buildFixedCost(id: 1, name: '家賃', smallCategoryId: 11)],
      );
      final usecase = container.read(categoryUsecaseProvider);

      await expectLater(
        usecase.deleteBig(1),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '固定費「家賃」が使っているため削除できません',
          ),
        ),
      );
      expect(fakeSmallRepository.logicallyDeletedIds, isEmpty);
      expect(fakeBigRepository.logicallyDeletedIds, isEmpty);
    });

    test('有効な大カテゴリーが残り1件ならエラー（削除済みは数えない）', () async {
      final container = createUsecaseContainer(
        bigs: [
          bigCategories[0],
          bigCategories[1].copyWith(deleteFlag: 1),
          bigCategories[2].copyWith(deleteFlag: 1),
        ],
      );
      final usecase = container.read(categoryUsecaseProvider);

      await expectLater(
        usecase.deleteBig(1),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            'カテゴリーは1件以上必要です',
          ),
        ),
      );
      expect(fakeBigRepository.logicallyDeletedIds, isEmpty);
    });

    test('小カテゴリーを持たない大カテゴリーも削除できる', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(categoryUsecaseProvider);

      // 特別費（id=3）は小カテゴリーを1件も持たない
      await usecase.deleteBig(3);

      expect(fakeSmallRepository.logicallyDeletedIds, isEmpty);
      expect(fakeBigRepository.logicallyDeletedIds, [3]);
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

  group('CategoryUsecase.updateRegisterGrid（KP-032）', () {
    // fixture: 10 食費（key5・表示）/ 11 日用品（key1・非表示）/ 12 旅行（key9・表示）
    test('並べたIDを表示（1）＋0からの連番にし、それ以外は非表示（0）で後ろに続ける', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(categoryUsecaseProvider);

      // 記録画面: 旅行 → 日用品 の順に出す（食費は外す）
      await usecase.updateRegisterGrid([12, 11]);

      final records = {for (final e in fakeSmallRepository.records) e.id: e};
      expect(records[12]!.smallCategoryOrderKey, 0);
      expect(records[12]!.defaultDisplayed, 1);
      expect(records[11]!.smallCategoryOrderKey, 1);
      expect(records[11]!.defaultDisplayed, 1);
      // 外した食費は表示中の後ろ（2）で非表示
      expect(records[10]!.smallCategoryOrderKey, 2);
      expect(records[10]!.defaultDisplayed, 0);
      // 表示順・表示フラグ以外は既存のまま
      expect(records[10]!.smallCategoryName, '食費');
      expect(records[10]!.displayedOrderInBig, 3);
    });

    test('内容が変わらない行はupdateしない', () async {
      final container = createUsecaseContainer(
        smalls: const [
          ExpenseSmallCategoryEntity(
            id: 10,
            smallCategoryOrderKey: 0,
            bigCategoryKey: 1,
            displayedOrderInBig: 1,
            smallCategoryName: '食費',
            defaultDisplayed: 1,
          ),
          ExpenseSmallCategoryEntity(
            id: 11,
            smallCategoryOrderKey: 1,
            bigCategoryKey: 1,
            displayedOrderInBig: 2,
            smallCategoryName: '日用品',
            defaultDisplayed: 0,
          ),
        ],
      );
      final usecase = container.read(categoryUsecaseProvider);

      await usecase.updateRegisterGrid([10]);

      expect(fakeSmallRepository.updatedEntities, isEmpty);
    });

    test('一覧に無いIDは無視し、削除済みの行は触らない', () async {
      final container = createUsecaseContainer(
        smalls: [
          smallCategories[0],
          smallCategories[1],
          smallCategories[2].copyWith(deleteFlag: 1),
        ],
      );
      final usecase = container.read(categoryUsecaseProvider);

      await usecase.updateRegisterGrid([999, 11, 10]);

      final updatedIds = fakeSmallRepository.updatedEntities.map((e) => e.id);
      expect(updatedIds, isNot(contains(12)));
      expect(updatedIds, isNot(contains(999)));
      final records = {for (final e in fakeSmallRepository.records) e.id: e};
      expect(records[11]!.smallCategoryOrderKey, 0);
      expect(records[10]!.smallCategoryOrderKey, 1);
      expect(records[12]!.deleteFlag, 1);
      expect(records[12]!.smallCategoryOrderKey, 9);
    });
  });
}
