// カテゴリー詳細編集ページ
// （lib/view/category_edit_page/big_category_detail_edit_page/）のWidget結合テスト
//
// 支出・収入・固定費の3実装が同じ CategoryDetailEditPage を共有するため、
// 分岐が共通の部分（名前編集・カラー選択・小カテゴリー編集）は支出で代表して確認し、
// 実装が分かれる部分（小カテゴリーの有無・保存先リポジトリ）だけ個別に張る。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/expense_category_detail_edit_page/category_detail_edit_page.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view_model/state/page_mode_controller/page_mode.dart';

import '../helper/fake_repositories.dart';
import '../helper/widget_test_helper.dart';

void main() {
  const expenseBigCategories = [
    ExpenseBigCategoryEntity(
      id: 1,
      colorCode: 'FFAA00',
      bigCategoryName: '生活費',
      resourcePath: 'assets/images/icon_meal.svg',
      displayOrder: 1,
      isDisplayed: 1,
    ),
  ];

  const expenseSmallCategories = [
    ExpenseSmallCategoryEntity(
      id: 10,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 1,
      displayedOrderInBig: 1,
      smallCategoryName: '食費',
      defaultDisplayed: 1,
    ),
    ExpenseSmallCategoryEntity(
      id: 11,
      smallCategoryOrderKey: 2,
      bigCategoryKey: 1,
      displayedOrderInBig: 2,
      smallCategoryName: '日用品',
      defaultDisplayed: 1,
    ),
  ];

  const fixedCostCategories = [
    FixedCostCategoryEntity(
      id: 1,
      categoryName: '住居',
      colorCode: 'FFAA00',
      resourcePath: 'assets/images/icon_home.svg',
    ),
  ];

  const incomeBigCategories = [
    IncomeBigCategoryEntity(
      id: 1,
      name: '月次収入',
      colorCode: '21D19F',
      iconPath: 'assets/images/icon_regular_income.svg',
    ),
  ];

  const incomeSmallCategories = [
    IncomeSmallCategoryEntity(
      id: 1,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 1,
      displayedOrderInBig: 1,
      smallCategoryName: '給与',
      defaultDisplayed: 1,
    ),
  ];

  TestFakes buildFakes() => TestFakes(
    expenseBigCategory: FakeExpenseBigCategoryRepository(
      initialRecords: expenseBigCategories,
    ),
    expenseSmallCategory: FakeExpenseSmallCategoryRepository(
      initialRecords: expenseSmallCategories,
    ),
    fixedCostCategory: FakeFixedCostCategoryRepository(
      initialRecords: fixedCostCategories,
    ),
    incomeBigCategory: FakeIncomeBigCategoryRepository(
      initialRecords: incomeBigCategories,
    ),
    incomeSmallCategory: FakeIncomeSmallCategoryRepository(
      initialRecords: incomeSmallCategories,
    ),
  );

  /// 大カテゴリー名の入力欄（画面上いちばん最初のTextFormField）
  Finder nameField() => find.byType(TextFormField).at(0);

  /// ヘッダー右の完了（チェック）ボタン
  ///
  /// 小カテゴリーのチェックボックスも同じアイコンを使うため、AppBar配下に絞る。
  Finder doneButton() => find.descendant(
    of: find.byType(AppBar),
    matching: find.byIcon(Icons.done_rounded),
  );

  group('一般（支出）カテゴリー', () {
    Future<TestFakes> pumpEditPage(WidgetTester tester) async {
      final fakes = buildFakes();
      await pumpApp(
        tester,
        home: const CategoryDetailEditPage(
          screenMode: BigCategoryDetailEditScreenMode.edit,
          categoryType: CategoryType.expense,
          bigCategoryId: 1,
        ),
        fakes: fakes,
      );
      await pumpTimes(tester);
      return fakes;
    }

    testWidgets('既存カテゴリーの名前と小カテゴリー一覧が初期表示される', (tester) async {
      await pumpEditPage(tester);

      expect(find.text('カテゴリーの設定'), findsOneWidget); // AppBar
      expect(find.text('生活費'), findsOneWidget); // 名前入力欄の初期値
      expect(find.text('カテゴリーカラー'), findsOneWidget);
      // 小カテゴリーの一覧（凡例＋2件＋追加行）
      expect(find.text('表示'), findsOneWidget);
      expect(find.text('並べ替え'), findsOneWidget);
      expect(find.text('食費'), findsOneWidget);
      expect(find.text('日用品'), findsOneWidget);
      expect(find.text('+ 新しい項目を追加'), findsOneWidget);
    });

    testWidgets('名前を変えて完了すると大カテゴリーがupdateされる', (tester) async {
      final fakes = await pumpEditPage(tester);

      await tester.enterText(nameField(), '食費全般');
      await pumpTimes(tester, times: 3);
      await tester.tap(doneButton());
      await pumpTimes(tester);

      expect(fakes.expenseBigCategory.updatedEntities, hasLength(1));
      final updated = fakes.expenseBigCategory.updatedEntities.single;
      expect(updated.id, 1);
      expect(updated.bigCategoryName, '食費全般');
      // 名前以外は元の値を引き継ぐ
      // （カラーコードは色→HEX変換を経るため保存時に小文字化される）
      expect(updated.colorCode, 'ffaa00');
      expect(updated.displayOrder, 1);
      // 小カテゴリーは触っていないので書き込まれない
      expect(fakes.expenseSmallCategory.updatedEntities, isEmpty);

      await waitForSnackBarDismissed(tester);
    });

    testWidgets('カラー選択ダイアログで選んだ色だけを変えても保存される', (tester) async {
      final fakes = await pumpEditPage(tester);

      await tester.tap(find.text('カテゴリーカラー'));
      await pumpTimes(tester);
      expect(find.text('カテゴリーカラーを選択'), findsOneWidget);

      // パレット2色目（CategoryPalette.expense2 = FB5B01）を選ぶ
      await tester.tap(
        find
            .descendant(
              of: find.byType(Dialog),
              matching: find.byType(AppInkWell),
            )
            .at(1),
      );
      await pumpTimes(tester);

      await tester.tap(doneButton());
      await pumpTimes(tester);

      expect(fakes.expenseBigCategory.updatedEntities, hasLength(1));
      final updated = fakes.expenseBigCategory.updatedEntities.single;
      // 保存されるカラーコードは小文字6桁HEX。名前は変更していないので元のまま
      expect(updated.colorCode, 'fb5b01');
      expect(updated.bigCategoryName, '生活費');

      await waitForSnackBarDismissed(tester);
    });

    testWidgets('アイコンをタップするとアイコン選択ダイアログが開く', (tester) async {
      await pumpEditPage(tester);

      // カテゴリーアイコン（カード上部のSVG）をタップする
      await tester.tap(find.bySemanticsLabel('categoryIcon').first);
      await pumpTimes(tester);

      expect(find.text('カテゴリーアイコンを選択'), findsOneWidget);
    });

    testWidgets('小カテゴリー名を変えて完了すると小カテゴリーがupdateされる', (tester) async {
      final fakes = await pumpEditPage(tester);

      // 小カテゴリーの入力欄は名前入力欄の次から並ぶ（0:大カテゴリー名）
      await tester.enterText(find.byType(TextFormField).at(1), '外食');
      await pumpTimes(tester, times: 3);
      await tester.tap(doneButton());
      await pumpTimes(tester);

      expect(fakes.expenseSmallCategory.updatedEntities, hasLength(1));
      final updated = fakes.expenseSmallCategory.updatedEntities.single;
      expect(updated.id, 10);
      expect(updated.smallCategoryName, '外食');
      expect(updated.bigCategoryKey, 1);
      // 大カテゴリー側は触っていないので書き込まれない
      expect(fakes.expenseBigCategory.updatedEntities, isEmpty);

      await waitForSnackBarDismissed(tester);
    });

    testWidgets('「+ 新しい項目を追加」で入力した項目が一覧に増え保存でaddされる', (tester) async {
      final fakes = await pumpEditPage(tester);

      await tester.tap(find.text('+ 新しい項目を追加'));
      await pumpTimes(tester);

      expect(find.text('新しい項目名を入力'), findsOneWidget);
      // ダイアログ内の入力欄（末尾に追加されたTextFormField）
      await tester.enterText(find.byType(TextFormField).last, 'カフェ');
      await pumpTimes(tester, times: 3);
      await tester.tap(find.text('OK'));
      await pumpTimes(tester);

      // 一覧に3件目として並ぶ
      expect(find.text('カフェ'), findsOneWidget);

      await tester.tap(doneButton());
      await pumpTimes(tester);

      expect(fakes.expenseSmallCategory.addedEntities, hasLength(1));
      final added = fakes.expenseSmallCategory.addedEntities.single;
      expect(added.smallCategoryName, 'カフェ');
      expect(added.bigCategoryKey, 1);

      await waitForSnackBarDismissed(tester);
    });

    testWidgets('項目名を空にして完了するとエラー文言が出て保存されない', (tester) async {
      final fakes = await pumpEditPage(tester);

      await tester.enterText(find.byType(TextFormField).at(1), '');
      await pumpTimes(tester, times: 3);
      await tester.tap(doneButton());
      await pumpTimes(tester);

      expect(find.textContaining('名前が入力されていない項目名があります'), findsOneWidget);
      expect(fakes.expenseSmallCategory.updatedEntities, isEmpty);

      await waitForSnackBarDismissed(tester);
    });

    testWidgets('何も編集せず完了するとエラー文言が出て保存されない', (tester) async {
      final fakes = await pumpEditPage(tester);

      await tester.tap(doneButton());
      await pumpTimes(tester);

      expect(find.textContaining('編集がされていません'), findsOneWidget);
      expect(fakes.expenseBigCategory.updatedEntities, isEmpty);
      expect(fakes.expenseSmallCategory.updatedEntities, isEmpty);

      await waitForSnackBarDismissed(tester);
    });
  });

  group('収入カテゴリー', () {
    Future<TestFakes> pumpEditPage(WidgetTester tester) async {
      final fakes = buildFakes();
      await pumpApp(
        tester,
        home: const CategoryDetailEditPage(
          screenMode: BigCategoryDetailEditScreenMode.edit,
          categoryType: CategoryType.income,
          bigCategoryId: 1,
        ),
        fakes: fakes,
      );
      await pumpTimes(tester);
      return fakes;
    }

    testWidgets('収入カテゴリーは名前と収入項目の一覧が出る', (tester) async {
      await pumpEditPage(tester);

      expect(find.text('月次収入'), findsOneWidget); // 名前入力欄の初期値
      expect(find.text('給与'), findsOneWidget);
      expect(find.text('+ 新しい項目を追加'), findsOneWidget);
    });

    testWidgets('名前を変えて完了すると収入大カテゴリーがupdateされる', (tester) async {
      final fakes = await pumpEditPage(tester);

      await tester.enterText(nameField(), '毎月の収入');
      await pumpTimes(tester, times: 3);
      await tester.tap(doneButton());
      await pumpTimes(tester);

      expect(fakes.incomeBigCategory.updatedEntities, hasLength(1));
      final updated = fakes.incomeBigCategory.updatedEntities.single;
      expect(updated.id, 1);
      expect(updated.name, '毎月の収入');

      await waitForSnackBarDismissed(tester);
    });
  });
}
