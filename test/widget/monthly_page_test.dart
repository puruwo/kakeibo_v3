// 月間分析タブ（lib/view/monthly_page/）のWidget結合テスト
//
// 集計結果がカード・グラフ・カテゴリータイルに正しく出るか、
// 各導線が正しい画面へ遷移するかを見る。
// 金額の計算そのものは moothly_all_category_card_usecase_test /
// moothly_category_card_usecase_test（UT）で担保済み。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_entity.dart';
import 'package:kakeibo/domain/db/budget/budget_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_entity.dart';
import 'package:kakeibo/view/component/app_empty_state.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/monthly_page/monthly_page.dart';
import 'package:kakeibo/view/monthly_page/prediction_graph_area/prediction_graph.dart';

import '../helper/fake_repositories.dart';
import '../helper/widget_test_helper.dart';

void main() {
  /// セクション見出しのFinder
  ///
  /// [AppContentsHeader] はアイコン無しのとき見出し頭に半角スペースを足すため、
  /// 探す文字列も先頭スペース込みにする。
  Finder sectionTitle(String title) => find.text(' $title');

  // システム日時2025/7/6・開始日25日 → 集計期間は2025/6/25〜7/24（代表月202506）
  const monthKey = '202506';

  // 支出大カテゴリー別の集計（カードの金額ラベルはここの値を表示する）
  const categoryAccountings = [
    CategoryAccountingEntity(
      id: 1,
      categoryColor: 'FFAA00',
      bigCategoryName: '食費',
      categoryIconPath: 'assets/images/icon_meal.svg',
      totalExpenseByBigCategory: 30000,
    ),
    CategoryAccountingEntity(
      id: 2,
      categoryColor: '00AAFF',
      bigCategoryName: '交通',
      categoryIconPath: 'assets/images/icon_transportation.svg',
      totalExpenseByBigCategory: 12000,
    ),
  ];

  // カード内の小カテゴリー（カードのグラフ比率はこの合計で決まる）
  const smallCategoryTiles = {
    1: [
      SmallCategoryTileEntity(
        id: 10,
        smallCategoryName: '外食',
        totalExpenseBySmallCategory: 30000,
        recordCount: 3,
      ),
    ],
    2: [
      SmallCategoryTileEntity(
        id: 20,
        smallCategoryName: '電車',
        totalExpenseBySmallCategory: 12000,
        recordCount: 4,
      ),
    ],
  };

  // 支出大カテゴリー（3:住居 / 4:光熱費）
  // v10で固定費カテゴリーは支出カテゴリーへ移設された（仕様 §3）
  const expenseBigCategories = [
    ExpenseBigCategoryEntity(
      id: 3,
      colorCode: 'FFAA00',
      bigCategoryName: '住居',
      resourcePath: 'assets/images/icon_home.svg',
      displayOrder: 3,
      isDisplayed: 1,
    ),
    ExpenseBigCategoryEntity(
      id: 4,
      colorCode: '00AAFF',
      bigCategoryName: '光熱費',
      resourcePath: 'assets/images/icon_bolt.svg',
      displayOrder: 4,
      isDisplayed: 1,
    ),
  ];

  // 支出小カテゴリー（31:家賃→大3 / 41:電気→大4）
  const expenseSmallCategories = [
    ExpenseSmallCategoryEntity(
      id: 31,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 3,
      displayedOrderInBig: 1,
      smallCategoryName: '家賃',
      defaultDisplayed: 1,
    ),
    ExpenseSmallCategoryEntity(
      id: 41,
      smallCategoryOrderKey: 2,
      bigCategoryKey: 4,
      displayedOrderInBig: 1,
      smallCategoryName: '電気',
      defaultDisplayed: 1,
    ),
  ];

  // 固定費マスタ（30は想定額6,000円の変動費）
  // 次回支払日は集計期間（6/25〜7/24）より後にして、
  // 予測グラフの未生成分として周期展開されないようにする
  const fixedCosts = [
    FixedCostEntity(
      id: 10,
      name: '家賃',
      variable: 0,
      price: 80000,
      fixedCostCategoryId: 1,
      expenseSmallCategoryId: 31,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
      nextPaymentDate: '20250801',
    ),
    FixedCostEntity(
      id: 30,
      name: '電気代',
      variable: 1,
      estimatedPrice: 6000,
      fixedCostCategoryId: 2,
      expenseSmallCategoryId: 41,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
      nextPaymentDate: '20250805',
    ),
  ];

  // 集計期間6/25〜7/24内の固定費行（確定80,000＋未確定の予想額6,000）
  const fixedCostExpenseRows = [
    ExpenseEntity(
      id: 100,
      date: '20250701',
      price: 80000,
      paymentCategoryId: 31,
      memo: '家賃',
      fixedCostId: 10,
      isConfirmed: 1,
    ),
    ExpenseEntity(
      id: 200,
      date: '20250705',
      price: null,
      paymentCategoryId: 41,
      memo: '電気代',
      fixedCostId: 30,
      isConfirmed: 0,
      estimatedPrice: 6000,
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
      name: '給与',
      colorCode: '0000FF',
      iconPath: 'assets/images/icon_regular_income.svg',
    ),
  ];

  /// 月間分析タブ用のFake束を組み立てる
  ///
  /// [totalExpense] は固定費行を含む支出合計（v10でexpenseの単一集計。仕様 §7.1）。
  /// [budgets] は代表月202506の予算（カテゴリー別）。
  /// [income] は給与カテゴリーの月次収入。
  TestFakes buildFakes({
    int totalExpense = 128000,
    List<BudgetEntity> budgets = const [
      BudgetEntity(
        id: 1,
        expenseBigCategoryId: 1,
        month: monthKey,
        price: 50000,
      ),
      BudgetEntity(
        id: 2,
        expenseBigCategoryId: 2,
        month: monthKey,
        price: 10000,
      ),
    ],
    int income = 300000,
    bool withFixedCost = true,
    List<CategoryAccountingEntity> categories = categoryAccountings,
    Map<int, List<SmallCategoryTileEntity>> tiles = smallCategoryTiles,
  }) {
    final expenseRepository = FakeExpenseRepository(
      initialRecords: withFixedCost ? fixedCostExpenseRows : const [],
    )
      ..totalExpenseByPeriodWithBigCategoryResult = totalExpense
      // 予測グラフの折れ線は日別合計を積み上げる（支出0のシナリオでは積まない）
      ..dailyExpenseTotalByDate.addAll(
        totalExpense == 0
            ? const <DateTime, int>{}
            : {DateTime(2025, 7, 1): 20000, DateTime(2025, 7, 5): 22000},
      );

    return TestFakes(
      expense: expenseRepository,
      budget: FakeBudgetRepository(initialRecords: budgets),
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
      categoryAccounting: FakeCategoryAccountingRepository(
        categories: categories,
      ),
      smallCategoryTile: FakeSmallCategoryTileRepository(
        tilesByBigCategoryId: tiles,
      ),
      fixedCost: FakeFixedCostRepository(
        initialRecords: withFixedCost ? fixedCosts : const [],
      ),
      expenseBigCategory: FakeExpenseBigCategoryRepository(
        initialRecords: expenseBigCategories,
      ),
      expenseSmallCategory: FakeExpenseSmallCategoryRepository(
        initialRecords: expenseSmallCategories,
      ),
    );
  }

  testWidgets('ヘッダーに集計期間ラベルと「一般会計」が出る', (tester) async {
    await pumpApp(tester, home: const MonthlyPage(), fakes: buildFakes());
    await pumpTimes(tester);

    // 集計期間6/25〜7/24（開始日が月初でないので2ヶ月表記）
    expect(find.text('2025年 6 - 7月'), findsOneWidget);
    expect(find.text('生活収支'), findsOneWidget);
  });

  testWidgets('予測グラフが描画される', (tester) async {
    await pumpApp(tester, home: const MonthlyPage(), fakes: buildFakes());
    await pumpTimes(tester);

    expect(sectionTitle('支出グラフ'), findsOneWidget);
    expect(find.byType(PredictionGraph), findsOneWidget);
  });

  testWidgets('今月の収支カード：予算内なら収支がプラス表示になる', (tester) async {
    // 支出128,000（一般42,000＋固定費86,000をexpenseで一括集計）
    // 予算50,000+10,000＝60,000（固定費の自動加算は廃止。仕様 §7.3）
    // 収入300,000 → 支出は予算を超えるが収入は超えない
    await pumpApp(tester, home: const MonthlyPage(), fakes: buildFakes());
    await pumpTimes(tester);

    expect(sectionTitle('今月の収支'), findsOneWidget);
    expect(find.text('¥ 128,000'), findsOneWidget); // 総支出
    // 予算はRichText（「/予算 」＋金額）。カテゴリー予算の合計のみ
    expect(
      find.textContaining('/予算 ¥ 60,000', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('¥ 300,000'), findsOneWidget); // 総収入
    // 収支＝収入300,000－支出128,000（プラスなので符号つき）
    expect(find.text('¥ +172,000'), findsOneWidget);
  });

  testWidgets('今月の収支カード：予算・収入を超えると収支がマイナス表示になる', (tester) async {
    // 支出386,000 > 収入300,000 > 予算60,000
    await pumpApp(
      tester,
      home: const MonthlyPage(),
      fakes: buildFakes(totalExpense: 386000),
    );
    await pumpTimes(tester);

    expect(find.text('¥ 386,000'), findsOneWidget); // 総支出
    expect(
      find.textContaining('/予算 ¥ 60,000', findRichText: true),
      findsOneWidget,
    );
    // 収支＝300,000－386,000のマイナス表示
    expect(find.text('¥ -86,000'), findsOneWidget);
  });

  testWidgets('カテゴリーカードに支出額と予算が出る', (tester) async {
    await pumpApp(tester, home: const MonthlyPage(), fakes: buildFakes());
    await pumpTimes(tester);

    expect(sectionTitle('カテゴリー別'), findsOneWidget);
    expect(find.text('食費'), findsOneWidget);
    expect(find.text('交通'), findsOneWidget);
    expect(find.text('¥ 30,000'), findsOneWidget); // 食費の支出
    expect(find.text('¥ 12,000'), findsOneWidget); // 交通の支出
    // 予算ラベルはRichText（「予算 」＋金額）
    expect(
      find.textContaining('予算 ¥ 50,000', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('予算 ¥ 10,000', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('予算を超えたカテゴリーだけ超過オーバーレイが描かれる', (tester) async {
    // 食費30,000<予算50,000（超過なし）／交通12,000>予算10,000（超過）
    await pumpApp(tester, home: const MonthlyPage(), fakes: buildFakes());
    await pumpTimes(tester);

    // 超過分は over_fill.png のオーバーレイで表現される
    expect(
      find.image(const AssetImage('assets/images/over_fill.png')),
      findsOneWidget,
    );
  });

  testWidgets('固定費サマリーに支払い予定・確定分・予想分が出る', (tester) async {
    await pumpApp(tester, home: const MonthlyPage(), fakes: buildFakes());
    await pumpTimes(tester);

    expect(sectionTitle('固定費'), findsOneWidget);
    expect(find.text('支払い予定'), findsOneWidget);
    expect(find.text('¥ 86,000'), findsOneWidget); // 確定80,000＋予想6,000
    expect(find.text('確定分'), findsOneWidget);
    // 確定分の合計とカテゴリー別サマリー（住居）の2箇所に出る
    expect(find.text('¥ 80,000'), findsNWidgets(2));
    expect(find.text('予想分'), findsOneWidget);
    expect(find.text('¥ 6,000'), findsOneWidget);

    // カテゴリー別サマリー（住居は確定済み・光熱費は未確定）
    expect(find.text('住居'), findsOneWidget);
    expect(find.text('光熱費'), findsOneWidget);
    expect(find.text('未確定'), findsOneWidget);
  });

  testWidgets('固定費が無いときは予想分がハイフン表示になる', (tester) async {
    await pumpApp(
      tester,
      home: const MonthlyPage(),
      fakes: buildFakes(withFixedCost: false),
    );
    await pumpTimes(tester);

    expect(find.text('予想分'), findsOneWidget);
    expect(find.text('---'), findsOneWidget);
  });

  testWidgets('固定費の「さらに表示」で月間固定費ページへ遷移する', (tester) async {
    await pumpApp(tester, home: const MonthlyPage(), fakes: buildFakes());
    await pumpTimes(tester);

    await tester.tap(find.text('さらに表示'));
    await pumpTimes(tester);

    // 遷移先（月間固定費ページ）のヘッダーと明細
    // （月間分析タブ側のセクション見出しは先頭スペース付きなので別物）
    expect(find.text('固定費'), findsOneWidget);
    expect(find.text('家賃'), findsOneWidget);
  });

  testWidgets('カテゴリーカードのタップで大カテゴリー支出履歴へ遷移する', (tester) async {
    await pumpApp(tester, home: const MonthlyPage(), fakes: buildFakes());
    await pumpTimes(tester);

    await tester.tap(find.text('食費'));
    // 遷移先の小カテゴリー行はかつて幅を screenWidth-64 から按分しており、
    // 実際の行幅はそれより2px狭いため iPhone14/15幅(390pt) では
    // RenderFlexが2pxオーバーフローしていた（lib/view/monthly_page/category_tile/
    // big_category_expense_history_page/expanded_category_sum_tile.dart）。
    // 行の制約を按分基準にする修正が入ったので、遷移しても例外は出ない。
    final errors = await pumpAndCollectExceptions(tester);
    expect(errors, isEmpty, reason: '遷移先の描画で例外が出てはいけない');

    // 遷移先（カテゴリー別利用状況）に小カテゴリー（外食）が並ぶ
    expect(find.text('カテゴリー別利用状況'), findsOneWidget);
    expect(find.text('外食'), findsWidgets);
  });

  testWidgets('収入を追加・予算を編集のボタンが並ぶ', (tester) async {
    await pumpApp(tester, home: const MonthlyPage(), fakes: buildFakes());
    await pumpTimes(tester);

    expect(find.text('収入を追加'), findsOneWidget);
    expect(find.text('予算を編集'), findsOneWidget);

    await tester.tap(find.text('予算を編集'));
    await pumpTimes(tester);

    // 予算編集（月次計画ホーム）へ遷移する
    expect(find.text('毎月の予算'), findsOneWidget);
  });

  testWidgets('記録が1件も無いときは記録を促すカードになり支出グラフは出ない', (tester) async {
    await pumpApp(
      tester,
      home: const MonthlyPage(),
      fakes: buildFakes(
        totalExpense: 0,
        budgets: const [],
        income: 0,
        withFixedCost: false,
        categories: const [],
        tiles: const {},
      ),
    );
    await pumpTimes(tester);

    expect(find.text('今月の収支を記録しましょう'), findsOneWidget);
    expect(find.text('収入や予算を登録すると今月の収支が表示されます'), findsOneWidget);
    // Q-15: 誘導カードは AppEmptyState のボタン無し版（導線は下の「収入を追加 / 予算を編集」）
    final emptyState = find.byType(AppEmptyState);
    expect(emptyState, findsOneWidget);
    expect(
      find.descendant(of: emptyState, matching: find.byType(MainButton)),
      findsNothing,
    );
    // データなしのとき支出グラフのセクションごと消える
    expect(sectionTitle('支出グラフ'), findsNothing);
    expect(find.byType(PredictionGraph), findsNothing);
  });

  testWidgets('ヘッダーをタップすると月度ピッカーが開く', (tester) async {
    await pumpApp(tester, home: const MonthlyPage(), fakes: buildFakes());
    await pumpTimes(tester);

    await tester.tap(find.text('生活収支'));
    await pumpTimes(tester);

    expect(find.text('適用'), findsOneWidget);
  });
}
