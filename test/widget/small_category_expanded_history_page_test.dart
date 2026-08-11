// 小カテゴリー展開ページ
// （lib/view/monthly_page/category_tile/big_category_expense_history_page/
//   small_category_expanded_history_page/）のWidget結合テスト
//
// 指定した小カテゴリーの支出だけが日付ごとに並ぶこと、
// タイルから編集モーダルへ入れることを見る。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/view/monthly_page/category_tile/big_category_expense_history_page/small_category_expanded_history_page/small_category_expanded_history_page.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

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
      id: 11,
      smallCategoryOrderKey: 2,
      bigCategoryKey: 1,
      displayedOrderInBig: 2,
      smallCategoryName: '中食',
      defaultDisplayed: 1,
    ),
  ];

  // 集計期間6/25〜7/24内の支出。小カテゴリー10（外食）が2件、11（中食）が1件
  const expenses = [
    ExpenseEntity(
      id: 1,
      date: '20250701',
      price: 12000,
      paymentCategoryId: 10,
      memo: 'ランチ',
    ),
    ExpenseEntity(
      id: 2,
      date: '20250705',
      price: 18000,
      paymentCategoryId: 10,
      memo: 'ディナー',
    ),
    ExpenseEntity(
      id: 3,
      date: '20250703',
      price: 5000,
      paymentCategoryId: 11,
      memo: 'スーパー',
    ),
  ];

  /// 小カテゴリー展開ページ用のFake束を組み立てる
  ///
  /// [withRecords] をfalseにすると支出が1件も無い状態になる。
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
  );

  testWidgets('指定した小カテゴリーの支出だけが日付ごとに並ぶ', (tester) async {
    await pumpApp(
      tester,
      // 小カテゴリーID=10（外食）を指定して開く
      home: const SmallCategoryExpenseHistoryPage(smallId: 10),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    expect(find.text('カテゴリー別利用状況'), findsOneWidget); // AppBar

    // 日付ヘッダーは新しい順（7/5 → 7/1）
    expect(find.text('2025年7月5日(土)'), findsOneWidget);
    expect(find.text('2025年7月1日(火)'), findsOneWidget);
    // 外食の2件だけが出る（小カテゴリー名・メモは先頭スペース付き）
    expect(find.text(' ランチ'), findsOneWidget);
    expect(find.text(' ディナー'), findsOneWidget);
    expect(find.text('¥ 12,000'), findsOneWidget);
    expect(find.text('¥ 18,000'), findsOneWidget);
    // 別の小カテゴリー（中食）の記録は出ない
    expect(find.text(' スーパー'), findsNothing);
    expect(find.text('2025年7月3日(木)'), findsNothing);
  });

  testWidgets('支出タイルのタップで編集モーダルが開く', (tester) async {
    await pumpApp(
      tester,
      home: const SmallCategoryExpenseHistoryPage(smallId: 10),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.text(' ディナー'));
    await pumpTimes(tester);

    expect(find.byType(RegisaterPageBase), findsOneWidget);
    expect(find.text('編集'), findsOneWidget);
    expect(find.text('18,000'), findsWidgets); // 元の支出金額

    await unmountRegisterPage(tester);
  });

  testWidgets('その小カテゴリーの記録が無いときは記録なしメッセージになる', (tester) async {
    await pumpApp(
      tester,
      home: const SmallCategoryExpenseHistoryPage(smallId: 10),
      fakes: buildFakes(withRecords: false),
    );
    await pumpTimes(tester);

    expect(find.text('記録がまだありません'), findsOneWidget);
  });
}
