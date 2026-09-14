// カテゴリー設定画面（lib/view/category_edit_page/category_setting_page.dart）
// のWidget結合テスト
//
// 支出・収入の2タブの切り替えと、各タブの一覧表示、
// 詳細編集ページへの導線を見る。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/view/category_edit_page/big_category_setting_page/big_category_edit_area.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';

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
    ExpenseBigCategoryEntity(
      id: 2,
      colorCode: '00AAFF',
      bigCategoryName: '交通費',
      resourcePath: 'assets/images/icon_transportation.svg',
      displayOrder: 2,
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
    ExpenseSmallCategoryEntity(
      id: 20,
      smallCategoryOrderKey: 3,
      bigCategoryKey: 2,
      displayedOrderInBig: 1,
      smallCategoryName: '電車',
      defaultDisplayed: 1,
    ),
  ];

  const incomeBigCategories = [
    IncomeBigCategoryEntity(
      id: 1,
      name: '月次収入',
      colorCode: '0000FF',
      iconPath: 'assets/images/icon_regular_income.svg',
    ),
    IncomeBigCategoryEntity(
      id: 2,
      name: 'ボーナス',
      colorCode: '00FF00',
      iconPath: 'assets/images/icon_extra_income.svg',
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
    IncomeSmallCategoryEntity(
      id: 2,
      smallCategoryOrderKey: 2,
      bigCategoryKey: 2,
      displayedOrderInBig: 1,
      smallCategoryName: '賞与',
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
    incomeBigCategory: FakeIncomeBigCategoryRepository(
      initialRecords: incomeBigCategories,
    ),
    incomeSmallCategory: FakeIncomeSmallCategoryRepository(
      initialRecords: incomeSmallCategories,
    ),
  );

  testWidgets('初期表示は支出タブで支出大カテゴリーが小カテゴリー付きで並ぶ', (tester) async {
    await pumpApp(
      tester,
      home: const CategorySettingPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    expect(find.text('カテゴリー設定'), findsOneWidget); // AppBar
    // タブは支出・収入の2つ（固定費タブは廃止）
    expect(find.text('支出'), findsOneWidget);
    expect(find.text('収入'), findsOneWidget);
    expect(find.text('一般'), findsNothing);
    expect(find.text('固定費'), findsNothing);

    // 一覧の凡例
    expect(find.text('カテゴリー'), findsOneWidget);
    expect(find.text('項目'), findsOneWidget);
    expect(find.text('詳細'), findsOneWidget);

    expect(find.text('生活費'), findsOneWidget);
    expect(find.text('交通費'), findsOneWidget);
    // 小カテゴリー名はカンマ区切りでまとめて出る
    expect(find.text('食費,日用品'), findsOneWidget);
    expect(find.text('電車'), findsOneWidget);
    expect(find.text('+ 新しいカテゴリーを追加'), findsOneWidget);
  });

  testWidgets('収入タブに切り替えると収入カテゴリーが並びフッターが出ない', (tester) async {
    await pumpApp(
      tester,
      home: const CategorySettingPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    // 支出タブでは並び替えフッターが出る
    expect(find.text('並び替え・削除'), findsOneWidget);

    await tester.tap(find.text('収入'));
    await pumpTimes(tester);

    expect(find.text('月次収入'), findsOneWidget);
    expect(find.text('ボーナス'), findsOneWidget);
    expect(find.text('給与'), findsOneWidget);
    // 収入タブは並び替え・削除モードを持たないためフッターが無い（KP-024）
    expect(find.text('並び替え・削除'), findsNothing);
  });

  testWidgets('カテゴリー行のタップで詳細編集ページへ遷移する', (tester) async {
    await pumpApp(
      tester,
      home: const CategorySettingPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('生活費'));
    await pumpTimes(tester);

    expect(find.text('カテゴリーの設定'), findsOneWidget); // 遷移先のAppBar
    // 選択した大カテゴリーの小カテゴリーが編集対象として並ぶ
    expect(find.text('食費'), findsOneWidget);
    expect(find.text('日用品'), findsOneWidget);
    expect(find.text('小カテゴリーを追加'), findsOneWidget);
  });

  testWidgets('「+ 新しいカテゴリーを追加」で新規作成モードの詳細編集へ遷移する', (tester) async {
    await pumpApp(
      tester,
      home: const CategorySettingPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('+ 新しいカテゴリーを追加'));
    await pumpTimes(tester);

    expect(find.text('カテゴリーの設定'), findsOneWidget);
    // 新規作成なので既存の小カテゴリーは1件も引き継がれない
    expect(find.text('食費'), findsNothing);
    expect(find.text('カテゴリー名を入力'), findsOneWidget); // 空の名前入力欄のヒント
  });

  testWidgets('「並び替え・削除」で並び替え編集モードのフッターに変わる', (tester) async {
    await pumpApp(
      tester,
      home: const CategorySettingPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('並び替え・削除'));
    await pumpTimes(tester);

    expect(find.text('編集をキャンセル'), findsOneWidget);
    expect(find.text('編集を完了'), findsOneWidget);
    expect(find.text('並び替え・削除'), findsNothing);
  });

  /// 並び替え・削除モードで [label] の行の丸マイナス（KP-024）
  Finder bigDeleteButtonOf(String label) => find.descendant(
    of: find.ancestor(of: find.text(label), matching: find.byType(Row)).first,
    matching: find.byIcon(AppIcons.deleteRow),
  );

  testWidgets('並び替え・削除モードの丸マイナスで確認すると大カテゴリーが小カテゴリーごと削除され一覧から消える', (
    tester,
  ) async {
    final fakes = buildFakes();
    await pumpApp(tester, home: const CategorySettingPage(), fakes: fakes);
    await pumpTimes(tester);

    await tester.tap(find.text('並び替え・削除'));
    await pumpTimes(tester);
    await tester.tap(bigDeleteButtonOf('生活費'));
    await pumpTimes(tester);

    expect(find.text('「生活費」を削除しますか？'), findsOneWidget);
    expect(
      find.text('小カテゴリー2件もあわせて削除します。\n元に戻せません。\n登録済みの支出はそのまま残ります。'),
      findsOneWidget,
    );

    await tester.tap(find.text('削除する'));
    await pumpTimes(tester, times: 6);

    // 大カテゴリーは確認後すぐに論理削除する（編集を完了するのを待たない）
    expect(fakes.expenseBigCategory.logicallyDeletedIds, [1]);
    expect(fakes.expenseSmallCategory.logicallyDeletedIds, [10, 11]);
    expect(find.text('生活費'), findsNothing);
    expect(find.text('交通費'), findsOneWidget);

    await waitForSnackBarDismissed(tester);
  });

  testWidgets('大カテゴリーを削除しただけで「編集を完了」を押してもエラーにならず一覧に戻る', (
    tester,
  ) async {
    final fakes = buildFakes();
    await pumpApp(tester, home: const CategorySettingPage(), fakes: fakes);
    await pumpTimes(tester);

    await tester.tap(find.text('並び替え・削除'));
    await pumpTimes(tester);
    await tester.tap(bigDeleteButtonOf('生活費'));
    await pumpTimes(tester);
    await tester.tap(find.text('削除する'));
    await pumpTimes(tester, times: 6);
    await waitForSnackBarDismissed(tester);

    await tester.tap(find.text('編集を完了'));
    await pumpTimes(tester, times: 6);

    // 並び替えをしていなくても削除は編集として扱う（コードレビュー指摘・KP-024）
    expect(find.text('編集がされていません'), findsNothing);
    expect(find.text('並び替え・削除'), findsOneWidget);

    await waitForSnackBarDismissed(tester);
  });

  testWidgets('大カテゴリーが1件だけなら丸マイナスは押せず確認も出ない', (tester) async {
    final fakes = TestFakes(
      expenseBigCategory: FakeExpenseBigCategoryRepository(
        initialRecords: [expenseBigCategories.first],
      ),
      expenseSmallCategory: FakeExpenseSmallCategoryRepository(
        initialRecords: expenseSmallCategories,
      ),
      incomeBigCategory: FakeIncomeBigCategoryRepository(
        initialRecords: incomeBigCategories,
      ),
      incomeSmallCategory: FakeIncomeSmallCategoryRepository(
        initialRecords: incomeSmallCategories,
      ),
    );
    await pumpApp(tester, home: const CategorySettingPage(), fakes: fakes);
    await pumpTimes(tester);

    await tester.tap(find.text('並び替え・削除'));
    await pumpTimes(tester);
    await tester.tap(bigDeleteButtonOf('生活費'));
    await pumpTimes(tester);

    expect(find.text('「生活費」を削除しますか？'), findsNothing);
    expect(fakes.expenseBigCategory.logicallyDeletedIds, isEmpty);
  });

  // 大カテゴリーの並び替え（KP-011 で小カテゴリー側と合わせて観点を張った）。
  // 大カテゴリー側は「追加」行を持たないため、リストの要素はすべて並び替え対象。
  testWidgets('並び替え編集モードで大カテゴリーを入れ替えて完了すると新しい表示順で保存される', (tester) async {
    final fakes = buildFakes();
    await pumpApp(tester, home: const CategorySettingPage(), fakes: fakes);
    await pumpTimes(tester);

    await tester.tap(find.text('並び替え・削除'));
    await pumpTimes(tester);

    const labels = ['生活費', '交通費'];
    expect(rowsInOrder(tester, labels), ['生活費', '交通費']);

    // 先頭の生活費を1行分（編集行の高さ50）下げる
    await dragReorderHandle(
      tester,
      '生活費',
      kBigCategoryEditRowHeight,
      rowHeight: kBigCategoryEditRowHeight,
    );

    expect(rowsInOrder(tester, labels), ['交通費', '生活費']);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('編集を完了'));
    await pumpTimes(tester);

    // 表示順は並び替え後のindex（0始まり）で書き直される
    final updated = {
      for (final e in fakes.expenseBigCategory.updatedEntities)
        e.id: e.displayOrder,
    };
    expect(updated, {2: 0, 1: 1});

    await waitForSnackBarDismissed(tester);
  });
}
