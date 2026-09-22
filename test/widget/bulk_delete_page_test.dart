// 一括削除ページ（lib/view/bulk_delete_page/）のWidget結合テスト（KP-031）
//
// 起点の行が選択済みで開くこと・行タップと「すべて選択」で選択が変わること・
// フッターのボタンの件数と非活性・確認ダイアログを経て deleteByIds が呼ばれ
// 残りの一覧とスナックバーが出ること・0件の空状態・収入モードを見る。
// 一覧の組み立てと削除のロジックは application/bulk_delete のUTが担当する。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/bulk_delete/bulk_delete_mode.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/view/bulk_delete_page/bulk_delete_item_tile.dart';
import 'package:kakeibo/view/bulk_delete_page/bulk_delete_page.dart';
import 'package:kakeibo/view/component/app_chip_label.dart';
import 'package:kakeibo/view/component/button_util.dart';

import '../helper/fake_repositories.dart';
import '../helper/widget_test_helper.dart';

void main() {
  const expenseBigCategories = [
    ExpenseBigCategoryEntity(
      id: 1,
      colorCode: 'FFAA00',
      bigCategoryName: '食費',
      resourcePath: 'assets/images/icon_meal.svg',
      displayOrder: 1,
      isDisplayed: 1,
    ),
    ExpenseBigCategoryEntity(
      id: 2,
      colorCode: 'FFAA00',
      bigCategoryName: '住居',
      resourcePath: 'assets/images/icon_home.svg',
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
      smallCategoryName: '外食',
      defaultDisplayed: 1,
    ),
    ExpenseSmallCategoryEntity(
      id: 21,
      smallCategoryOrderKey: 2,
      bigCategoryKey: 2,
      displayedOrderInBig: 1,
      smallCategoryName: '家賃',
      defaultDisplayed: 1,
    ),
  ];

  // 固定費マスタ（固定額。削除時の推定額の再計算は変動費でないため走らない）
  const fixedCosts = [
    FixedCostEntity(
      id: 10,
      name: '家賃',
      variable: 0,
      price: 80000,
      expenseSmallCategoryId: 21,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
      nextPaymentDate: '20250802',
    ),
  ];

  // 7/6 の通常支出2件・7/2 の確定固定費・7/3 の未確定固定費（月をまたいだ 6/1 の行も出る）
  const expenses = [
    ExpenseEntity(
      id: 1,
      date: '20250706',
      price: 1200,
      paymentCategoryId: 10,
      memo: 'ランチ',
    ),
    ExpenseEntity(
      id: 2,
      date: '20250706',
      price: 880,
      paymentCategoryId: 10,
      memo: '弁当',
    ),
    ExpenseEntity(
      id: 100,
      date: '20250702',
      price: 80000,
      paymentCategoryId: 21,
      memo: '家賃',
      fixedCostId: 10,
      isConfirmed: 1,
    ),
    ExpenseEntity(
      id: 200,
      date: '20250703',
      price: null,
      paymentCategoryId: 21,
      memo: '電気代',
      fixedCostId: 10,
      isConfirmed: 0,
      estimatedPrice: 6000,
    ),
    ExpenseEntity(
      id: 3,
      date: '20250601',
      price: 340,
      paymentCategoryId: 10,
      memo: '電車',
    ),
  ];

  const incomeBigCategories = [
    IncomeBigCategoryEntity(
      id: 1,
      name: '月次収入',
      colorCode: '00AAFF',
      iconPath: 'assets/images/icon_salary.svg',
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
  const incomes = [
    IncomeEntity(
      id: 1,
      categoryId: 1,
      date: '20250625',
      price: 250000,
      memo: '6月分',
    ),
    IncomeEntity(
      id: 2,
      categoryId: 1,
      date: '20250725',
      price: 260000,
      memo: '7月分',
    ),
  ];

  TestFakes buildFakes({bool withRecords = true}) {
    return TestFakes(
      expense: FakeExpenseRepository(
        initialRecords: withRecords ? expenses : const [],
      ),
      expenseSmallCategory: FakeExpenseSmallCategoryRepository(
        initialRecords: expenseSmallCategories,
      ),
      expenseBigCategory: FakeExpenseBigCategoryRepository(
        initialRecords: expenseBigCategories,
      ),
      income: FakeIncomeRepository(
        initialRecords: withRecords ? incomes : const [],
        smallCategoryToBigCategory: const {1: 1},
      ),
      incomeSmallCategory: FakeIncomeSmallCategoryRepository(
        initialRecords: incomeSmallCategories,
      ),
      incomeBigCategory: FakeIncomeBigCategoryRepository(
        initialRecords: incomeBigCategories,
      ),
      fixedCost: FakeFixedCostRepository(initialRecords: fixedCosts),
    );
  }

  Finder expenseRow(int id) => find.byKey(ValueKey('bulk-delete-expense-$id'));
  Finder incomeRow(int id) => find.byKey(ValueKey('bulk-delete-income-$id'));

  bool isSelected(WidgetTester tester, Finder row) =>
      tester.widget<BulkDeleteItemTile>(row).isSelected;

  MainButton deleteButton(WidgetTester tester) =>
      tester.widget<MainButton>(find.byType(MainButton));

  testWidgets('起点のレコードが選択済みで開き、フッターに件数が出る', (tester) async {
    await pumpApp(
      tester,
      home: const BulkDeletePage(
        mode: BulkDeleteMode.expense,
        initialSelectedId: 2,
      ),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    expect(find.text('支出をまとめて削除'), findsOneWidget);
    // 全履歴が日付見出しつきで出る（7/6・7/3・7/2・6/1）
    expect(find.text('2025年7月6日(日)'), findsOneWidget);
    expect(find.text('2025年6月1日(日)'), findsOneWidget);
    expect(find.byType(BulkDeleteItemTile), findsNWidgets(5));

    expect(isSelected(tester, expenseRow(2)), isTrue);
    expect(isSelected(tester, expenseRow(1)), isFalse);
    expect(find.text('1件を削除'), findsOneWidget);
    expect(deleteButton(tester).onPressed, isNotNull);
    expect(find.text('すべて選択'), findsOneWidget);
  });

  testWidgets('固定費行は「固定費」チップ、未確定は「未入力」で出る', (tester) async {
    await pumpApp(
      tester,
      home: const BulkDeletePage(
        mode: BulkDeleteMode.expense,
        initialSelectedId: 1,
      ),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    expect(find.widgetWithText(AppChipLabel, '固定費'), findsNWidgets(2));
    expect(find.text('未入力'), findsOneWidget);
    // 行末は支出の「−」
    expect(find.byIcon(AppIcons.remove), findsNWidgets(5));
  });

  testWidgets('行タップで選択が切り替わり、件数が増減する', (tester) async {
    await pumpApp(
      tester,
      home: const BulkDeletePage(
        mode: BulkDeleteMode.expense,
        initialSelectedId: 2,
      ),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(expenseRow(1));
    await pumpTimes(tester, times: 2);
    expect(isSelected(tester, expenseRow(1)), isTrue);
    expect(find.text('2件を削除'), findsOneWidget);

    // 起点の行も外せる
    await tester.tap(expenseRow(2));
    await pumpTimes(tester, times: 2);
    expect(isSelected(tester, expenseRow(2)), isFalse);
    expect(find.text('1件を削除'), findsOneWidget);
  });

  testWidgets('「すべて選択」で全行が選ばれ、「すべて解除」で0件になりボタンが非活性になる', (tester) async {
    await pumpApp(
      tester,
      home: const BulkDeletePage(
        mode: BulkDeleteMode.expense,
        initialSelectedId: 2,
      ),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('すべて選択'));
    await pumpTimes(tester, times: 2);

    expect(find.text('5件を削除'), findsOneWidget);
    expect(find.text('すべて解除'), findsOneWidget);
    for (final id in [1, 2, 3, 100, 200]) {
      expect(isSelected(tester, expenseRow(id)), isTrue, reason: 'id=$id');
    }

    await tester.tap(find.text('すべて解除'));
    await pumpTimes(tester, times: 2);

    expect(find.text('削除'), findsOneWidget);
    expect(deleteButton(tester).onPressed, isNull);
    expect(find.text('すべて選択'), findsOneWidget);
  });

  testWidgets('削除ボタン→確認→「削除する」で選択した行が消え、スナックバーが出て一覧に留まる', (tester) async {
    final fakes = await pumpApp(
      tester,
      home: const BulkDeletePage(
        mode: BulkDeleteMode.expense,
        initialSelectedId: 2,
      ),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(expenseRow(1));
    await pumpTimes(tester, times: 2);

    await tester.tap(find.text('2件を削除'));
    await pumpTimes(tester);

    // 既存の ActionSheet 型の確認ダイアログ（件数入り）
    expect(find.text('2件の記録を削除'), findsOneWidget);
    expect(find.text('削除する'), findsOneWidget);

    await tester.tap(find.text('削除する'));
    await pumpTimes(tester);

    // 1回の deleteByIds で2件まとめて渡す
    expect(fakes.expense.deletedByIdsCalls, hasLength(1));
    expect(fakes.expense.deletedByIdsCalls.single, unorderedEquals([1, 2]));

    // 一覧に留まり、残りの3行だけが出る。選択は空に戻る
    expect(find.text('支出をまとめて削除'), findsOneWidget);
    expect(expenseRow(1), findsNothing);
    expect(expenseRow(2), findsNothing);
    expect(find.byType(BulkDeleteItemTile), findsNWidgets(3));
    expect(find.text('2件を削除しました'), findsOneWidget);
    expect(find.text('削除'), findsOneWidget);
    expect(deleteButton(tester).onPressed, isNull);

    await waitForSnackBarDismissed(tester);
  });

  testWidgets('確認で「キャンセル」を選ぶと削除せず選択も残る', (tester) async {
    final fakes = await pumpApp(
      tester,
      home: const BulkDeletePage(
        mode: BulkDeleteMode.expense,
        initialSelectedId: 2,
      ),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('1件を削除'));
    await pumpTimes(tester);
    await tester.tap(find.text('キャンセル'));
    await pumpTimes(tester);

    expect(fakes.expense.deletedByIdsCalls, isEmpty);
    expect(find.byType(BulkDeleteItemTile), findsNWidgets(5));
    expect(isSelected(tester, expenseRow(2)), isTrue);
    expect(find.text('1件を削除'), findsOneWidget);
  });

  testWidgets('レコードが0件なら空状態の文言が出て、ボタンと「すべて選択」が非活性になる', (tester) async {
    await pumpApp(
      tester,
      home: const BulkDeletePage(
        mode: BulkDeleteMode.expense,
        initialSelectedId: 1,
      ),
      fakes: buildFakes(withRecords: false),
    );
    await pumpTimes(tester);

    expect(find.text('記録がまだありません'), findsOneWidget);
    expect(find.byType(BulkDeleteItemTile), findsNothing);
    expect(deleteButton(tester).onPressed, isNull);
    expect(find.text('削除'), findsOneWidget);
    // 「すべて選択」は非活性（押しても何も起きない）
    await tester.tap(find.text('すべて選択'));
    await pumpTimes(tester, times: 2);
    expect(find.text('すべて選択'), findsOneWidget);
  });

  testWidgets('収入モードは収入の全レコードだけを出し、タイトルと行末のサインが変わる', (tester) async {
    final fakes = await pumpApp(
      tester,
      home: const BulkDeletePage(
        mode: BulkDeleteMode.income,
        initialSelectedId: 2,
      ),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    expect(find.text('収入をまとめて削除'), findsOneWidget);
    expect(find.byType(BulkDeleteItemTile), findsNWidgets(2));
    expect(incomeRow(2), findsOneWidget);
    expect(find.byType(BulkDeleteItemTile).evaluate().length, 2);
    expect(find.byIcon(AppIcons.add), findsNWidgets(2));
    expect(find.byIcon(AppIcons.remove), findsNothing);
    expect(isSelected(tester, incomeRow(2)), isTrue);

    await tester.tap(find.text('1件を削除'));
    await pumpTimes(tester);
    await tester.tap(find.text('削除する'));
    await pumpTimes(tester);

    expect(fakes.income.deletedByIdsCalls, [
      [2],
    ]);
    expect(fakes.expense.deletedByIdsCalls, isEmpty);
    expect(find.byType(BulkDeleteItemTile), findsOneWidget);
    expect(find.text('1件を削除しました'), findsOneWidget);

    await waitForSnackBarDismissed(tester);
  });
}
