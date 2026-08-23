// 履歴タブ（lib/view/historical_calendar_page/）のWidget結合テスト
//
// カレンダーの日別金額表示・日選択と、下部の履歴リスト（支出／収入／固定費の混在）、
// 未確定固定費の金額確定までを確認する。
// 集計ロジックそのものは calendar_usecase_test / historical_transaction_usecase_test
// （UT）で担保済み。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/daily_expense_entity/daily_expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/view/historical_calendar_page/calendar_area/date_box.dart';
import 'package:kakeibo/view/historical_calendar_page/expense_history_page.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

import '../helper/fake_repositories.dart';
import '../helper/widget_test_helper.dart';

void main() {
  // システム日時2025/7/6固定 → 履歴タブが表示する月は2025/7/1〜7/31
  const expenseSmallCategories = [
    ExpenseSmallCategoryEntity(
      id: 10,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 1,
      displayedOrderInBig: 1,
      smallCategoryName: '外食',
      defaultDisplayed: 1,
    ),
    // 固定費行の支出カテゴリー（v10で固定費カテゴリーから移設）
    ExpenseSmallCategoryEntity(
      id: 21,
      smallCategoryOrderKey: 2,
      bigCategoryKey: 2,
      displayedOrderInBig: 1,
      smallCategoryName: '家賃',
      defaultDisplayed: 1,
    ),
    ExpenseSmallCategoryEntity(
      id: 31,
      smallCategoryOrderKey: 3,
      bigCategoryKey: 3,
      displayedOrderInBig: 1,
      smallCategoryName: '電気',
      defaultDisplayed: 1,
    ),
  ];

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
    ExpenseBigCategoryEntity(
      id: 3,
      colorCode: '00AAFF',
      bigCategoryName: '光熱費',
      resourcePath: 'assets/images/icon_bolt.svg',
      displayOrder: 3,
      isDisplayed: 1,
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


  // 固定費マスタ（30は想定額6,000円の変動費）
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
      // 期間内に未生成分として周期展開されないよう次回支払日を先にする
      nextPaymentDate: '20250802',
    ),
    FixedCostEntity(
      id: 30,
      name: '電気代',
      variable: 1,
      estimatedPrice: 6000,
      expenseSmallCategoryId: 31,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
      nextPaymentDate: '20250803',
    ),
  ];

  // 7/1の支出3,000円（外食）と、7/2に確定済みの家賃・7/3に未確定の電気代
  // v10で固定費実績もexpenseの固定費行になった（仕様 §3）
  const expenses = [
    ExpenseEntity(
      id: 1,
      date: '20250701',
      price: 3000,
      paymentCategoryId: 10,
      memo: 'ランチ',
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
      paymentCategoryId: 31,
      memo: '電気代',
      fixedCostId: 30,
      isConfirmed: 0,
      estimatedPrice: 6000,
    ),
  ];

  const incomes = [
    IncomeEntity(id: 1, categoryId: 1, date: '20250705', price: 250000),
  ];

  /// 履歴タブ用のFake束
  ///
  /// [withRecords] を false にすると、記録が1件も無い月の表示になる。
  TestFakes buildFakes({bool withRecords = true}) {
    return TestFakes(
      // カレンダーの日別金額（1日=支出3,000 / 5日=収入250,000）
      dailyExpense: FakeDailyExpenseRepository(
        dailyExpenses: withRecords
            ? {
                DateTime(2025, 7, 1): DailyExpenseEntity(
                  date: DateTime(2025, 7, 1),
                  totalExpense: 3000,
                ),
                DateTime(2025, 7, 5): DailyExpenseEntity(
                  date: DateTime(2025, 7, 5),
                  totalIncome: 250000,
                ),
              }
            : const {},
      ),
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

  testWidgets('ヘッダーに選択中の年月が出る', (tester) async {
    await pumpApp(
      tester,
      home: const ExpenseHistoryPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    expect(find.text('2025年 7月'), findsOneWidget);
  });

  testWidgets('カレンダーに日別の支出・収入金額が出る', (tester) async {
    await pumpApp(
      tester,
      home: const ExpenseHistoryPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    // 7/1は月初なので「7/1」表記、それ以外は日のみ
    expect(find.text('7/1'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    // 支出は3,000（カレンダーは¥なしの3桁区切り）
    expect(find.text('3,000'), findsWidgets);
  });

  testWidgets('履歴リストに支出・収入・固定費が混在して並ぶ', (tester) async {
    await pumpApp(
      tester,
      home: const ExpenseHistoryPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    // 日付ヘッダー（新しい日付が上）
    expect(find.text('2025年7月5日(土)'), findsOneWidget);
    expect(find.text('2025年7月1日(火)'), findsOneWidget);
    // 支出タイル（大カテゴリー名＋小カテゴリー名＋メモ。名前は先頭スペース付きで描画される）
    expect(find.text('食費'), findsOneWidget);
    expect(find.text(' 外食'), findsOneWidget);
    expect(find.text(' ランチ'), findsOneWidget);
    expect(find.text('¥ 3,000'), findsOneWidget);
    // 固定費行も同じ支出タイルで並び、「固定費」チップで識別する（v10。仕様 §8.4）
    expect(find.text('住居'), findsOneWidget);
    // 小カテゴリー名とメモが同じ「家賃」なので2件出る
    expect(find.text(' 家賃'), findsNWidgets(2));
    expect(find.text('¥ 80,000'), findsOneWidget);
    expect(find.text('光熱費'), findsOneWidget);
    expect(find.text(' 電気'), findsOneWidget);
    // 未確定の固定費行は金額が「未入力」
    expect(find.text('未入力'), findsOneWidget);
    // 確定済み・未確定の2行に「固定費」チップが付く
    expect(find.text('固定費'), findsNWidgets(2));
    // 収入タイル
    expect(find.text('給与'), findsOneWidget);
    expect(find.text('¥ 250,000'), findsOneWidget);
  });

  testWidgets('記録が無い月は空状態メッセージになる', (tester) async {
    await pumpApp(
      tester,
      home: const ExpenseHistoryPage(),
      fakes: buildFakes(withRecords: false),
    );
    await pumpTimes(tester);

    expect(find.text('記録がまだありません'), findsOneWidget);
  });

  testWidgets('未確定の固定費行のタップで固定費行の編集シートが開く', (tester) async {
    await pumpApp(
      tester,
      home: const ExpenseHistoryPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.text(' 電気代').first);
    await pumpTimes(tester);

    // v10で未確定の確定操作は編集シートに一本化した（仕様 §6.6）
    expect(find.byType(RegisaterPageBase), findsOneWidget);
    expect(find.text('金額を確定'), findsOneWidget);

    await unmountRegisterPage(tester);
  });

  testWidgets('金額を入力して確定すると実績行の更新がリポジトリに記録される', (tester) async {
    final fakes = buildFakes();
    await pumpApp(tester, home: const ExpenseHistoryPage(), fakes: fakes);
    await pumpTimes(tester);

    await tester.tap(find.text(' 電気代').first);
    await pumpTimes(tester);

    // シート上の最初のTextFormFieldが金額欄
    await tester.enterText(find.byType(TextFormField).first, '7200');
    await tester.pump();
    await tester.tap(find.text('金額を確定'));
    await pumpTimes(tester);

    // 未確定固定費ID=200が7,200円で確定される
    // 確定の書き込み先はexpenseの固定費行（v10）
    expect(fakes.expense.updatedEntities, hasLength(1));
    expect(fakes.expense.updatedEntities.single.id, 200);
    expect(fakes.expense.updatedEntities.single.price, 7200);
    expect(fakes.expense.updatedEntities.single.isConfirmed, 1);
  });

  testWidgets('支出タイルのタップで編集モーダルが開く', (tester) async {
    await pumpApp(
      tester,
      home: const ExpenseHistoryPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.text(' ランチ'));
    await pumpTimes(tester);

    expect(find.byType(RegisaterPageBase), findsOneWidget);
    expect(find.text('編集'), findsOneWidget);
    // 元の支出の金額が初期表示される
    expect(find.text('3,000'), findsWidgets);

    await unmountRegisterPage(tester);
  });

  testWidgets('カレンダーの別の日をタップすると選択日が切り替わる', (tester) async {
    await pumpApp(
      tester,
      home: const ExpenseHistoryPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    // 初期選択日はシステム日時の6日。別の日（10日）をタップして選択を移す
    await tester.tap(find.text('10'));
    await pumpTimes(tester);

    // 選択中の日を再タップすると、その日付で記録モーダルが開く
    // （DateBoxのselected時の挙動。選択日が移ったことの裏取りになる）
    await tester.tap(find.text('10'));
    await pumpTimes(tester);

    expect(find.byType(RegisaterPageBase), findsOneWidget);
    expect(find.text('7/10'), findsOneWidget); // 記録モーダルの日付ピル

    await unmountRegisterPage(tester);
  });

  testWidgets('表示月の前後にはみ出した日は期間外表示になりタップしても反応しない', (tester) async {
    await pumpApp(
      tester,
      home: const ExpenseHistoryPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    // 2025年7月は火曜始まり・31日 → 先頭に6/29,6/30、末尾に8/1,8/2が入る
    final outOfPeriodBoxes = find.byWidgetPredicate(
      (widget) =>
          widget is DateBox &&
          !widget.calendarTileEntity.isWithinAggregationRange,
    );
    expect(outOfPeriodBoxes, findsNWidgets(4));

    // 期間外の日はタップしても選択も記録モーダル起動もしない
    await tester.tap(outOfPeriodBoxes.last);
    await pumpTimes(tester);

    expect(find.byType(RegisaterPageBase), findsNothing);
  });

  testWidgets('前月・翌月ボタンで表示月が切り替わる', (tester) async {
    await pumpApp(
      tester,
      home: const ExpenseHistoryPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    expect(find.text('2025年 7月'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_rounded));
    await pumpTimes(tester);
    expect(find.text('2025年 6月'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
    await pumpTimes(tester);
    expect(find.text('2025年 7月'), findsOneWidget);
  });
}
