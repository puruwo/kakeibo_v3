// 日次支出サマリーページ（lib/view/daily_expense_summary_page/）のWidget結合テスト
//
// 1日ぶんの支出が総額・カテゴリー別・固定費に分かれて出るか、
// タイルから編集モーダルへ入れるか、記録なしの日の表示を見る。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_entity.dart';
import 'package:kakeibo/view/daily_expense_summary_page/daily_expense_summary_page.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

import '../helper/fake_repositories.dart';
import '../helper/widget_test_helper.dart';

void main() {
  // 対象日はシステム日時と同じ2025/7/6（内部では2025/7/1〜7/31を取得する）
  final targetDate = DateTime(2025, 7, 6);

  const expenseBigCategories = [
    ExpenseBigCategoryEntity(
      id: 1,
      colorCode: 'FFAA00',
      bigCategoryName: '食費',
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
      smallCategoryName: '外食',
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

  const fixedCosts = [
    FixedCostEntity(
      id: 10,
      name: '家賃',
      variable: 0,
      price: 80000,
      fixedCostCategoryId: 1,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
    ),
  ];

  // 対象日（7/6）の支出2件と、同日の確定固定費1件
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
      price: 800,
      paymentCategoryId: 10,
      memo: 'コーヒー',
    ),
    // 別の日の支出は対象日の内訳に出ない
    ExpenseEntity(
      id: 3,
      date: '20250707',
      price: 5000,
      paymentCategoryId: 10,
      memo: 'ディナー',
    ),
  ];

  const fixedCostExpenses = [
    FixedCostExpenseEntity(
      id: 100,
      fixedCostId: 10,
      fixedCostCategoryId: 1,
      date: '20250706',
      price: 80000,
      name: '家賃',
      isConfirmed: 1,
    ),
  ];

  /// 日次サマリー用のFake束を組み立てる
  ///
  /// [withRecords] をfalseにすると対象日の記録が1件も無い状態になる。
  TestFakes buildFakes({bool withRecords = true}) => TestFakes(
    expense: FakeExpenseRepository(
      initialRecords: withRecords ? expenses : const [],
    ),
    expenseBigCategory: FakeExpenseBigCategoryRepository(
      initialRecords: expenseBigCategories,
    ),
    expenseSmallCategory: FakeExpenseSmallCategoryRepository(
      initialRecords: expenseSmallCategories,
    ),
    fixedCost: FakeFixedCostRepository(initialRecords: fixedCosts),
    fixedCostCategory: FakeFixedCostCategoryRepository(
      initialRecords: fixedCostCategories,
    ),
    fixedCostExpense: FakeFixedCostExpenseRepository(
      initialRecords: withRecords ? fixedCostExpenses : const [],
    ),
  );

  testWidgets('総支出とカテゴリー別の内訳が出る', (tester) async {
    await pumpApp(
      tester,
      home: DailyExpenseSummaryPage(date: targetDate),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    expect(find.text('7月6日の支出'), findsOneWidget); // AppBar
    expect(find.text('総支出'), findsOneWidget);
    // 一般支出1,200＋800＋確定固定費80,000
    expect(find.text('¥ 82,000'), findsOneWidget);

    // カテゴリーヘッダー（食費の合計2,000）とタイル
    expect(find.text('食費'), findsWidgets);
    expect(find.text('¥ 2,000'), findsWidgets);
    expect(find.text('ランチ'), findsOneWidget);
    expect(find.text('コーヒー'), findsOneWidget);
    expect(find.text('¥ 1,200'), findsOneWidget);
    expect(find.text('¥ 800'), findsOneWidget);

    // 別の日の支出は出ない
    expect(find.text('ディナー'), findsNothing);
  });

  testWidgets('確定済み固定費が固定費セクションに出る', (tester) async {
    await pumpApp(
      tester,
      home: DailyExpenseSummaryPage(date: targetDate),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    expect(find.text('固定費合計'), findsOneWidget);
    expect(find.text('家賃'), findsOneWidget);
    expect(find.text('固定費'), findsOneWidget); // タイルのサブラベル
    // セクション合計とタイル金額の2箇所に出る
    expect(find.text('¥ 80,000'), findsNWidgets(2));
  });

  testWidgets('支出タイルのタップで編集モーダルが開く', (tester) async {
    await pumpApp(
      tester,
      home: DailyExpenseSummaryPage(date: targetDate),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('ランチ'));
    await pumpTimes(tester);

    expect(find.byType(RegisaterPageBase), findsOneWidget);
    expect(find.text('編集'), findsOneWidget);
    expect(find.text('1,200'), findsWidgets); // 元の支出金額

    await unmountRegisterPage(tester);
  });

  testWidgets('その日の記録が無いときは支出なしメッセージになる', (tester) async {
    await pumpApp(
      tester,
      home: DailyExpenseSummaryPage(date: targetDate),
      fakes: buildFakes(withRecords: false),
    );
    await pumpTimes(tester);

    expect(find.text('この日の支出はありません'), findsOneWidget);
    expect(find.text('総支出'), findsNothing);
  });
}
