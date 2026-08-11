// 毎月の予算ページ（lib/view/monthly_page/monthly_plan_area/）のWidget結合テスト
//
// 予算サマリー・カテゴリー別予算一覧の表示と、編集モードでの保存経路を見る。
// 予算の登録/更新の振り分けロジックは budget_usecase_test（UT）で担保済みなので、
// ここでは画面から入力した値がその振り分けに正しく渡るかを見る。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/db/budget/budget_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthy_plan_home_page/monthly_plan_home_page.dart';

import '../helper/fake_repositories.dart';
import '../helper/widget_test_helper.dart';

void main() {
  // システム日時2025/7/6・開始日25日 → 集計期間は2025/6/25〜7/24（代表月202506）
  const monthKey = '202506';

  // 支出大カテゴリー（表示順どおりに並ぶ。id=3は非表示カテゴリー）
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
    ExpenseBigCategoryEntity(
      id: 3,
      colorCode: '00FF00',
      bigCategoryName: '非表示カテゴリー',
      resourcePath: 'assets/images/icon_others.svg',
      displayOrder: 3,
      isDisplayed: 0,
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
      id: 20,
      smallCategoryOrderKey: 2,
      bigCategoryKey: 2,
      displayedOrderInBig: 1,
      smallCategoryName: '電車',
      defaultDisplayed: 1,
    ),
  ];

  // 「先月の支出」欄の元データ。現在月表示なので参照されるのは
  // ひとつ前の集計期間（2025/5/25〜6/24）の支出
  const lastPeriodExpenses = [
    ExpenseEntity(
      id: 1,
      date: '20250601',
      price: 8000,
      paymentCategoryId: 10,
      memo: '',
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
  const incomeBigCategories = [
    IncomeBigCategoryEntity(
      id: 1,
      name: '月次収入',
      colorCode: '0000FF',
      iconPath: 'assets/images/icon_regular_income.svg',
    ),
  ];

  /// 毎月の予算ページ用のFake束を組み立てる
  ///
  /// [budgets] は代表月202506の予算。既定では生活費(id=1)のみ登録済みで、
  /// 交通費(id=2)は未登録（保存時にinsert側へ回る）。
  /// [income] は月次収入の合計。
  TestFakes buildFakes({
    List<BudgetEntity> budgets = const [
      BudgetEntity(
        id: 1,
        expenseBigCategoryId: 1,
        month: monthKey,
        price: 50000,
      ),
    ],
    int income = 300000,
  }) => TestFakes(
    expense: FakeExpenseRepository(initialRecords: lastPeriodExpenses),
    budget: FakeBudgetRepository(initialRecords: budgets),
    expenseBigCategory: FakeExpenseBigCategoryRepository(
      initialRecords: expenseBigCategories,
    ),
    expenseSmallCategory: FakeExpenseSmallCategoryRepository(
      initialRecords: expenseSmallCategories,
    ),
    income: FakeIncomeRepository(
      initialRecords: [
        if (income > 0)
          IncomeEntity(id: 1, categoryId: 1, date: '20250701', price: income),
      ],
      smallCategoryToBigCategory: const {1: 1},
    ),
    incomeSmallCategory: FakeIncomeSmallCategoryRepository(
      initialRecords: incomeSmallCategories,
    ),
    incomeBigCategory: FakeIncomeBigCategoryRepository(
      initialRecords: incomeBigCategories,
    ),
  );

  testWidgets('サマリーに予算合計・総収入・予定収支が出る', (tester) async {
    await pumpApp(
      tester,
      home: const MonthlyPlanHomePage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    expect(find.text('毎月の予算'), findsOneWidget); // AppBar
    expect(find.text('予算'), findsOneWidget);
    expect(find.text('¥ 50,000'), findsWidgets); // 予算合計（固定費なし）
    expect(find.text('総収入'), findsOneWidget);
    expect(find.text('¥ 300,000'), findsOneWidget);
    // 予定収支＝収入300,000－予算50,000（RichTextの「予定収支 」＋金額）
    expect(
      find.textContaining('予定収支 ¥ 250,000', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('カテゴリー別の予算一覧に凡例・カテゴリー名・先月の支出が並ぶ', (tester) async {
    await pumpApp(
      tester,
      home: const MonthlyPlanHomePage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    // 一覧の凡例（現在月なので参照期間は「先月の支出」）
    expect(find.text('カテゴリー'), findsOneWidget);
    expect(find.text('先月の支出'), findsOneWidget);
    expect(find.text('今月の予算'), findsOneWidget);

    expect(find.text('生活費'), findsOneWidget);
    expect(find.text('交通費'), findsOneWidget);
    // 先月（5/25〜6/24）の生活費支出8,000／交通費は実績なしでハイフン
    expect(find.text('¥ 8,000'), findsOneWidget);
    expect(find.text('---'), findsOneWidget);

    // isDisplayed=0 のカテゴリーは一覧に出ない
    expect(find.text('非表示カテゴリー'), findsNothing);
  });

  testWidgets('予算未登録のカテゴリーは入力欄が0で初期表示される', (tester) async {
    await pumpApp(
      tester,
      home: const MonthlyPlanHomePage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    // 登録済み（生活費）は登録額、未登録（交通費）は0が入る
    // （NumberTextInputFormatter.formatInitialValue が0を'0'に変換するため、
    //   TextFieldのヒント「金額を入力」は実際には表示されない）
    expect(find.text('50,000'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('金額を入力'), findsNothing);
  });

  testWidgets('「予算を編集する」でフッターが編集完了ボタンに変わる', (tester) async {
    await pumpApp(
      tester,
      home: const MonthlyPlanHomePage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    expect(find.text('カテゴリー編集・追加'), findsOneWidget);
    expect(find.text('予算を編集する'), findsOneWidget);

    await tester.tap(find.text('予算を編集する'));
    await pumpTimes(tester);

    expect(find.text('編集を完了'), findsOneWidget);
    expect(find.text('予算を編集する'), findsNothing);
  });

  testWidgets('予算を編集して完了すると登録済みはupdate・未登録はinsertされる', (tester) async {
    final fakes = buildFakes();
    await pumpApp(tester, home: const MonthlyPlanHomePage(), fakes: fakes);
    await pumpTimes(tester);

    await tester.tap(find.text('予算を編集する'));
    await pumpTimes(tester);

    // 一覧はdisplayOrder順（0:生活費 / 1:交通費）
    await tester.enterText(find.byType(TextField).at(0), '55000');
    await tester.enterText(find.byType(TextField).at(1), '12000');
    await pumpTimes(tester);

    await tester.tap(find.text('編集を完了'));
    await pumpTimes(tester);

    // 生活費は登録済み（id=1）なのでupdate
    expect(fakes.budget.updatedEntities, hasLength(1));
    expect(fakes.budget.updatedEntities.single.id, 1);
    expect(fakes.budget.updatedEntities.single.expenseBigCategoryId, 1);
    expect(fakes.budget.updatedEntities.single.price, 55000);
    expect(fakes.budget.updatedEntities.single.month, monthKey);

    // 交通費は未登録なのでinsert
    expect(fakes.budget.insertedEntities, hasLength(1));
    expect(fakes.budget.insertedEntities.single.expenseBigCategoryId, 2);
    expect(fakes.budget.insertedEntities.single.price, 12000);

    await waitForSnackBarDismissed(tester);
  });

  testWidgets('何も編集せず完了するとエラー文言が出て書き込まれない', (tester) async {
    final fakes = buildFakes();
    await pumpApp(tester, home: const MonthlyPlanHomePage(), fakes: fakes);
    await pumpTimes(tester);

    await tester.tap(find.text('予算を編集する'));
    await pumpTimes(tester);
    await tester.tap(find.text('編集を完了'));
    await pumpTimes(tester);

    expect(find.textContaining('予算が編集されていません'), findsOneWidget);
    expect(fakes.budget.updatedEntities, isEmpty);
    expect(fakes.budget.insertedEntities, isEmpty);

    await waitForSnackBarDismissed(tester);
  });

  testWidgets('予算も収入も無いときはサマリーごと非表示になる', (tester) async {
    await pumpApp(
      tester,
      home: const MonthlyPlanHomePage(),
      fakes: buildFakes(budgets: const [], income: 0),
    );
    await pumpTimes(tester);

    // サマリーカードの見出しが出ない（一覧と編集導線は残る）
    expect(find.text('予算'), findsNothing);
    expect(find.text('総収入'), findsNothing);
    expect(find.text('生活費'), findsOneWidget);
    expect(find.text('予算を編集する'), findsOneWidget);
  });

  testWidgets('「カテゴリー編集・追加」でカテゴリー設定画面が開く', (tester) async {
    await pumpApp(
      tester,
      home: const MonthlyPlanHomePage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('カテゴリー編集・追加'));
    await pumpTimes(tester);

    expect(find.text('カテゴリー設定'), findsOneWidget);
    expect(find.text('一般'), findsOneWidget);
  });
}
