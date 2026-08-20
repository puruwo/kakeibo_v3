// ボーナス利用状況ページ
// （lib/view/year_page/bonus_plan_area/bonus_home_page/）のWidget結合テスト
//
// ボーナス支出／ボーナス収入のタブ切り替えと一覧表示、
// タイルからの編集モーダル起動、フッターの追加導線を見る。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_home_page/bonus_home_page.dart';

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
      smallCategoryName: '家電',
      defaultDisplayed: 1,
    ),
  ];

  const incomeBigCategories = [
    IncomeBigCategoryEntity(
      id: 2,
      name: 'ボーナス',
      colorCode: '00FF00',
      iconPath: 'assets/images/icon_extra_income.svg',
    ),
  ];

  const incomeSmallCategories = [
    IncomeSmallCategoryEntity(
      id: 2,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 2,
      displayedOrderInBig: 1,
      smallCategoryName: '賞与',
      defaultDisplayed: 1,
    ),
  ];

  // 年度2025/4/25〜2026/4/24 の中の記録。
  // 拠出元がボーナス（incomeSourceBigCategory=2）の支出だけが一覧に出る
  const expenses = [
    ExpenseEntity(
      id: 1,
      date: '20250705',
      price: 120000,
      paymentCategoryId: 10,
      memo: '冷蔵庫',
      incomeSourceBigCategory: 2,
    ),
    // 拠出元が給与（既定=1）の支出はボーナス一覧に出ない
    ExpenseEntity(
      id: 2,
      date: '20250706',
      price: 3000,
      paymentCategoryId: 10,
      memo: 'ランチ',
    ),
  ];

  const incomes = [
    IncomeEntity(id: 1, categoryId: 2, date: '20250630', price: 400000),
  ];

  /// ボーナスページ用のFake束を組み立てる
  ///
  /// [withRecords] をfalseにすると支出・収入とも記録なしになる。
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
    income: FakeIncomeRepository(
      initialRecords: withRecords ? incomes : const [],
      smallCategoryToBigCategory: const {2: 2},
    ),
    incomeBigCategory: FakeIncomeBigCategoryRepository(
      initialRecords: incomeBigCategories,
    ),
    incomeSmallCategory: FakeIncomeSmallCategoryRepository(
      initialRecords: incomeSmallCategories,
    ),
  );

  testWidgets('初期表示はボーナス支出タブで拠出元がボーナスの支出だけが並ぶ', (tester) async {
    await pumpApp(tester, home: const BonusHomePage(), fakes: buildFakes());
    await pumpTimes(tester);

    expect(find.text('特別枠の利用状況'), findsOneWidget); // AppBar
    expect(find.text('特別枠支出'), findsOneWidget);
    expect(find.text('特別枠収入'), findsOneWidget);

    // ボーナス拠出の支出タイル（大カテゴリー＋小カテゴリー＋日付＋メモ）
    expect(find.text('生活費'), findsOneWidget);
    expect(find.text('家電'), findsOneWidget);
    expect(find.text('7月5日'), findsOneWidget);
    expect(find.text('冷蔵庫'), findsOneWidget);
    expect(find.text('¥ 120,000'), findsOneWidget);
    // 給与拠出の支出は出ない
    expect(find.text('ランチ'), findsNothing);

    // 支出タブのフッター
    expect(find.text('新しい支出を追加'), findsOneWidget);
  });

  testWidgets('ボーナス収入タブに切り替えると収入一覧とフッターが変わる', (tester) async {
    await pumpApp(tester, home: const BonusHomePage(), fakes: buildFakes());
    await pumpTimes(tester);

    await tester.tap(find.text('特別枠収入'));
    await pumpTimes(tester);

    expect(find.text('賞与'), findsOneWidget);
    expect(find.text('6月30日'), findsOneWidget);
    // 上部のボーナス計画エリアにも同じ金額が出るため複数一致する
    expect(find.text('¥ 400,000'), findsWidgets);
    // 支出タブの内容とフッターは切り替わる
    expect(find.text('冷蔵庫'), findsNothing);
    expect(find.text('新しい収入を追加'), findsOneWidget);
    expect(find.text('新しい支出を追加'), findsNothing);
  });

  testWidgets('支出タイルのタップで編集モーダルが開く', (tester) async {
    await pumpApp(tester, home: const BonusHomePage(), fakes: buildFakes());
    await pumpTimes(tester);

    await tester.tap(find.text('冷蔵庫'));
    await pumpTimes(tester);

    expect(find.byType(RegisaterPageBase), findsOneWidget);
    expect(find.text('編集'), findsOneWidget);
    expect(find.text('120,000'), findsWidgets); // 元の支出金額

    await unmountRegisterPage(tester);
  });

  testWidgets('収入タイルのタップで編集モーダルが開く', (tester) async {
    await pumpApp(tester, home: const BonusHomePage(), fakes: buildFakes());
    await pumpTimes(tester);

    await tester.tap(find.text('特別枠収入'));
    await pumpTimes(tester);

    await tester.tap(find.text('賞与'));
    await pumpTimes(tester);

    expect(find.byType(RegisaterPageBase), findsOneWidget);
    expect(find.text('編集'), findsOneWidget);
    expect(find.text('400,000'), findsWidgets);

    await unmountRegisterPage(tester);
  });

  testWidgets('記録が1件も無いときは両タブとも記録なしメッセージになる', (tester) async {
    await pumpApp(
      tester,
      home: const BonusHomePage(),
      fakes: buildFakes(withRecords: false),
    );
    await pumpTimes(tester);

    expect(find.text('記録がまだありません'), findsOneWidget);

    await tester.tap(find.text('特別枠収入'));
    await pumpTimes(tester);

    expect(find.text('記録がまだありません'), findsOneWidget);
  });
}
