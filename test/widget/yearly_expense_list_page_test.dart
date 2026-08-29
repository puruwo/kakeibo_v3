// 支出一覧画面（lib/view/yearly_expense_list_page/）のWidget結合テスト
//
// 案件 UIデザイン改修 §6 の本実装。帯付きサマリーカード・カテゴリー別内訳・
// 会計種別（全体/生活収支/特別枠）の絞り込みと明細画面への引き継ぎ・
// カテゴリー明細（月毎アコーディオン・生活/特別のグループ分け）を見る。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/expense_history/yearly_expense_list_usecase.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/view/yearly_expense_list_page/yearly_category_expense_list_page.dart';
import 'package:kakeibo/view/yearly_expense_list_page/yearly_expense_list_page.dart';

import '../helper/fake_repositories.dart';
import '../helper/widget_test_helper.dart';

void main() {
  // 年度期間: 2025/4/25〜2026/4/24（システム日時2025/7/6は年度3ヶ月目）
  final period = PeriodValue(
    startDatetime: DateTime(2025, 4, 25),
    endDatetime: DateTime(2026, 4, 24),
  );

  const expenseBigCategories = [
    ExpenseBigCategoryEntity(
      id: 1,
      colorCode: 'FF7171',
      bigCategoryName: '食費',
      resourcePath: 'assets/images/icon_meal.svg',
      displayOrder: 1,
      isDisplayed: 1,
    ),
    ExpenseBigCategoryEntity(
      id: 2,
      colorCode: '4BA6FF',
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
      smallCategoryName: '外食',
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

  // 生活収支のみ: 食費 7月2件（30,000+10,000）・8月1件（20,000）／交通費 7月1件（40,000）
  const livingExpenses = [
    ExpenseEntity(
      id: 1,
      date: '20250705',
      price: 30000,
      paymentCategoryId: 10,
      memo: '焼肉',
    ),
    ExpenseEntity(
      id: 2,
      date: '20250710',
      price: 10000,
      paymentCategoryId: 10,
      memo: 'ランチ',
    ),
    ExpenseEntity(
      id: 3,
      date: '20250810',
      price: 20000,
      paymentCategoryId: 10,
      memo: '寿司',
    ),
    ExpenseEntity(
      id: 4,
      date: '20250715',
      price: 40000,
      paymentCategoryId: 20,
      memo: '定期券',
    ),
  ];

  // 特別枠: 食費 7月1件（20,000）
  // 全体 120,000（食費80,000=66.7%・交通費40,000=33.3%）
  // 生活 100,000（食費60,000=60.0%・交通費40,000=40.0%）／特別 20,000（食費のみ100%）
  const expenses = [
    ...livingExpenses,
    ExpenseEntity(
      id: 5,
      date: '20250720',
      price: 20000,
      paymentCategoryId: 10,
      memo: '記念日',
      incomeSourceBigCategory: AccountTypeConstants.special,
    ),
  ];

  TestFakes buildFakes({List<ExpenseEntity> records = expenses}) => TestFakes(
    expense: FakeExpenseRepository(initialRecords: records),
    expenseBigCategory: FakeExpenseBigCategoryRepository(
      initialRecords: expenseBigCategories,
    ),
    expenseSmallCategory: FakeExpenseSmallCategoryRepository(
      initialRecords: expenseSmallCategories,
    ),
  );

  group('支出一覧', () {
    testWidgets('帯の総支出とカテゴリー別内訳（金額降順・構成比つき）が出る。月別サマリーと月平均は出ない', (
      tester,
    ) async {
      await pumpApp(
        tester,
        home: YearlyExpenseListPage(period: period),
        fakes: buildFakes(),
      );
      await pumpTimes(tester);

      expect(find.text('支出一覧'), findsOneWidget); // AppBar
      expect(find.text('総支出'), findsOneWidget);
      expect(find.text('¥ 120,000'), findsOneWidget);

      // 絞り込みチップ
      expect(find.text('全体'), findsOneWidget);
      expect(find.text('生活収支'), findsOneWidget);
      expect(find.text('特別枠'), findsOneWidget);

      // カテゴリー別: 金額降順で 食費80,000 → 交通費40,000（生活＋特別）
      expect(find.text('食費'), findsOneWidget);
      expect(find.text('¥ 80,000'), findsOneWidget);
      expect(find.text('66.7%'), findsOneWidget);
      expect(find.text('交通費'), findsOneWidget);
      expect(find.text('¥ 40,000'), findsOneWidget);
      expect(find.text('33.3%'), findsOneWidget);

      // 一覧画面には月別アコーディオンと月平均を置かない
      expect(find.text('7月'), findsNothing);
      expect(find.textContaining('月平均'), findsNothing);
    });

    testWidgets('チップで絞ると総支出・内訳・構成比の分母が選択中の枠に揃う', (tester) async {
      await pumpApp(
        tester,
        home: YearlyExpenseListPage(period: period),
        fakes: buildFakes(),
      );
      await pumpTimes(tester);

      // 生活収支: 特別枠の20,000が除かれる
      await tester.tap(find.text('生活収支'));
      await pumpTimes(tester);
      expect(find.text('生活収支の支出'), findsOneWidget);
      expect(find.text('総支出'), findsNothing);
      expect(find.text('¥ 100,000'), findsOneWidget);
      expect(find.text('¥ 60,000'), findsOneWidget);
      expect(find.text('60.0%'), findsOneWidget);
      expect(find.text('40.0%'), findsOneWidget);

      // 特別枠: 食費だけになり、交通費は一覧から消える
      await tester.tap(find.text('特別枠'));
      await pumpTimes(tester);
      expect(find.text('特別枠の支出'), findsOneWidget);
      expect(find.text('¥ 20,000'), findsNWidgets(2)); // 帯と食費行
      expect(find.text('100.0%'), findsOneWidget);
      expect(find.text('交通費'), findsNothing);

      // 全体に戻す
      await tester.tap(find.text('全体'));
      await pumpTimes(tester);
      expect(find.text('総支出'), findsOneWidget);
      expect(find.text('¥ 120,000'), findsOneWidget);
    });

    testWidgets('絞り込み先に記録が無ければチップを残したまま空メッセージになる', (tester) async {
      await pumpApp(
        tester,
        home: YearlyExpenseListPage(period: period),
        fakes: buildFakes(records: livingExpenses),
      );
      await pumpTimes(tester);

      await tester.tap(find.text('特別枠'));
      await pumpTimes(tester);

      expect(find.text('特別枠の記録はありません'), findsOneWidget);
      expect(find.text('¥ 0'), findsOneWidget);
      // チップは残るので全体へ戻れる
      await tester.tap(find.text('全体'));
      await pumpTimes(tester);
      expect(find.text('¥ 100,000'), findsOneWidget);
    });

    testWidgets('記録が無ければ空メッセージが出る', (tester) async {
      await pumpApp(
        tester,
        home: YearlyExpenseListPage(period: period),
        fakes: buildFakes(records: const []),
      );
      await pumpTimes(tester);

      expect(find.text('記録がまだありません'), findsOneWidget);
    });
  });

  group('支出カテゴリー明細', () {
    testWidgets('カテゴリー行のタップで明細画面へ遷移し、合計・月平均（経過月数割り）と月毎アコーディオン（初期は全月閉じた状態）が出る', (
      tester,
    ) async {
      await pumpApp(
        tester,
        home: YearlyExpenseListPage(period: period),
        fakes: buildFakes(),
      );
      await pumpTimes(tester);

      await tester.tap(find.text('食費'));
      await pumpTimes(tester);

      expect(find.byType(YearlyCategoryExpenseListPage), findsOneWidget);
      // 帯: 食費の合計80,000（生活＋特別）。絞り込み無しなので状態ピルは出ない
      expect(find.text('合計'), findsOneWidget);
      expect(find.text('¥ 80,000'), findsOneWidget);
      expect(find.byIcon(Icons.filter_alt_outlined), findsNothing);
      // 月平均は年度3ヶ月目までの経過月数で割る: 80,000÷3=26,667
      expect(find.text('月平均'), findsOneWidget);
      expect(find.text('¥ 26,667'), findsOneWidget);
      // 総支出比と構成比バーは置かない
      expect(find.textContaining('総支出の'), findsNothing);

      // 月ヘッダー（新しい月が上）: 8月1件・7月3件
      expect(find.text('8月'), findsOneWidget);
      expect(find.text('1件'), findsOneWidget);
      expect(find.text('7月'), findsOneWidget);
      expect(find.text('3件'), findsOneWidget);
      expect(find.text('¥ 60,000'), findsOneWidget); // 7月の月計（生活40,000＋特別20,000）
      expect(find.text('¥ 20,000'), findsOneWidget); // 8月の月計

      // 初期は全月閉じた状態: 明細タイルは1件も出ない
      expect(find.text('寿司'), findsNothing);
      expect(find.text('焼肉'), findsNothing);
      expect(find.text('記念日'), findsNothing);
      // 交通費の明細は出ない
      expect(find.text('定期券'), findsNothing);
    });

    testWidgets('全体表示: 生活と特別が混在する月だけ小見出しで分け、片方だけの月は見出しを省略する', (
      tester,
    ) async {
      await pumpApp(
        tester,
        home: YearlyCategoryExpenseListPage(
          period: period,
          bigCategoryId: 1,
          bigCategoryName: '食費',
        ),
        fakes: buildFakes(),
      );
      await pumpTimes(tester);

      // 8月（生活のみ）を開く → 見出し無しで明細だけ
      await tester.tap(find.text('8月'));
      await pumpTimes(tester);
      expect(find.text('寿司'), findsOneWidget);
      expect(find.text('生活収支'), findsNothing);
      expect(find.text('特別枠'), findsNothing);

      // 7月（混在）を開く → 「生活収支 2件 ¥40,000」「特別枠 1件 ¥20,000」の見出しが付く
      await tester.tap(find.text('7月'));
      await pumpTimes(tester);
      expect(find.text('生活収支'), findsOneWidget);
      expect(find.text('特別枠'), findsOneWidget);
      expect(find.text('2件'), findsOneWidget);
      expect(find.text('¥ 40,000'), findsOneWidget);
      expect(find.text('焼肉'), findsOneWidget);
      expect(find.text('ランチ'), findsOneWidget);
      expect(find.text('記念日'), findsOneWidget);

      // 7月を閉じる → 明細と見出しが消える
      await tester.tap(find.text('7月'));
      await pumpTimes(tester);
      expect(find.text('焼肉'), findsNothing);
      expect(find.text('生活収支'), findsNothing);
    });

    testWidgets('一覧で特別枠に絞ってから遷移すると、明細も特別枠だけになり帯に状態ピルが出る', (
      tester,
    ) async {
      await pumpApp(
        tester,
        home: YearlyExpenseListPage(period: period),
        fakes: buildFakes(),
      );
      await pumpTimes(tester);

      await tester.tap(find.text('特別枠'));
      await pumpTimes(tester);
      await tester.tap(find.text('食費'));
      await pumpTimes(tester);

      expect(find.byType(YearlyCategoryExpenseListPage), findsOneWidget);
      // 帯: 特別枠の合計20,000＋状態ピル「特別枠」
      expect(find.text('¥ 20,000'), findsNWidgets(2)); // 帯と7月の月計
      expect(find.byIcon(Icons.filter_alt_outlined), findsOneWidget);
      expect(find.text('特別枠'), findsOneWidget);
      // 月平均も特別枠の合計から: 20,000÷3=6,667
      expect(find.text('¥ 6,667'), findsOneWidget);
      // 生活収支の8月は月グループごと消える
      expect(find.text('8月'), findsNothing);
      expect(find.text('7月'), findsOneWidget);
      expect(find.text('1件'), findsOneWidget);

      // 開いても特別枠の明細だけ。単一の枠なので小見出しは付かない
      await tester.tap(find.text('7月'));
      await pumpTimes(tester);
      expect(find.text('記念日'), findsOneWidget);
      expect(find.text('焼肉'), findsNothing);
      expect(find.text('生活収支'), findsNothing);
    });

    testWidgets('絞り込み中にそのカテゴリーの記録が無ければ、枠名入りの空メッセージになる', (
      tester,
    ) async {
      // 交通費は生活収支のみ → 特別枠で絞ると空
      await pumpApp(
        tester,
        home: YearlyCategoryExpenseListPage(
          period: period,
          bigCategoryId: 2,
          bigCategoryName: '交通費',
          filter: ExpenseAccountFilter.special,
        ),
        fakes: buildFakes(),
      );
      await pumpTimes(tester);

      expect(find.text('特別枠の記録はありません'), findsOneWidget);
      expect(find.text('記録がまだありません'), findsNothing);
    });

    testWidgets('生活収支で絞った明細は特別枠の分を含まない', (tester) async {
      await pumpApp(
        tester,
        home: YearlyCategoryExpenseListPage(
          period: period,
          bigCategoryId: 1,
          bigCategoryName: '食費',
          filter: ExpenseAccountFilter.living,
        ),
        fakes: buildFakes(),
      );
      await pumpTimes(tester);

      // 帯: 生活収支の食費60,000＋状態ピル「生活収支」
      expect(find.text('¥ 60,000'), findsOneWidget);
      expect(find.text('生活収支'), findsOneWidget);
      expect(find.text('¥ 20,000'), findsNWidgets(2)); // 月平均（60,000÷3）と8月の月計
      // 7月は生活の2件のみ
      expect(find.text('2件'), findsOneWidget);
      expect(find.text('¥ 40,000'), findsOneWidget);
    });
  });
}
