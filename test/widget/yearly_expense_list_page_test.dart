// 支出一覧画面（lib/view/yearly_expense_list_page/）のWidget結合テスト
//
// 案件 UIデザイン改修 §6 の本実装。総支出カード・カテゴリー別内訳・
// 月別タブへの切り替え・カテゴリー明細（月毎グルーピング）への遷移を見る。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/view/yearly_expense_list_page/yearly_category_expense_list_page.dart';
import 'package:kakeibo/view/yearly_expense_list_page/yearly_expense_list_page.dart';

import '../helper/fake_repositories.dart';
import '../helper/widget_test_helper.dart';

void main() {
  // 年度期間: 2025/4/25〜2026/4/24
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

  // 食費: 7月に2件（30,000+10,000）、8月に1件（20,000）／交通費: 7月に1件（40,000）
  // 総支出100,000 → 食費60%・交通費40%
  const expenses = [
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

  TestFakes buildFakes({List<ExpenseEntity> records = expenses}) => TestFakes(
        expense: FakeExpenseRepository(initialRecords: records),
        expenseBigCategory: FakeExpenseBigCategoryRepository(
          initialRecords: expenseBigCategories,
        ),
        expenseSmallCategory: FakeExpenseSmallCategoryRepository(
          initialRecords: expenseSmallCategories,
        ),
      );

  testWidgets('総支出カードとカテゴリー別内訳（金額降順・構成比つき）が出る', (tester) async {
    await pumpApp(
      tester,
      home: YearlyExpenseListPage(period: period),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    expect(find.text('支出一覧'), findsOneWidget); // AppBar
    expect(find.text('総支出'), findsOneWidget);
    expect(find.text('¥ 100,000'), findsOneWidget);

    // カテゴリー別（初期表示）: 金額降順で 食費60,000 → 交通費40,000
    expect(find.text('食費'), findsOneWidget);
    expect(find.text('¥ 60,000'), findsOneWidget);
    expect(find.text('60.0%'), findsOneWidget);
    expect(find.text('交通費'), findsOneWidget);
    expect(find.text('¥ 40,000'), findsOneWidget);
    expect(find.text('40.0%'), findsOneWidget);
  });

  testWidgets('月別タブに切り替えると月見出し（月計つき）と明細タイルが出る', (tester) async {
    await pumpApp(
      tester,
      home: YearlyExpenseListPage(period: period),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('月別'));
    await pumpTimes(tester);

    // 新しい月が上（8月→7月）。月見出しの右端に月計
    expect(find.text('8月'), findsOneWidget);
    // 8月は1件のみのため月計とタイル金額が同額で2つ並ぶ
    expect(find.text('¥ 20,000'), findsNWidgets(2));
    expect(find.text('7月'), findsOneWidget);
    expect(find.text('¥ 80,000'), findsOneWidget);
    // 明細タイル（メモ）が出る
    expect(find.text('寿司'), findsOneWidget);
    expect(find.text('定期券'), findsOneWidget);
  });

  testWidgets('カテゴリー行のタップで明細画面へ遷移し、月毎グルーピングで出る', (tester) async {
    await pumpApp(
      tester,
      home: YearlyExpenseListPage(period: period),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('食費'));
    await pumpTimes(tester);

    expect(find.byType(YearlyCategoryExpenseListPage), findsOneWidget);
    // 合計カード: 食費60,000・総支出の60%
    expect(find.text('合計'), findsOneWidget);
    expect(find.text('¥ 60,000'), findsOneWidget);
    expect(find.text('総支出の 60.0%'), findsOneWidget);
    // 月毎グルーピング（8月¥20,000 → 7月¥40,000）と明細
    expect(find.text('8月'), findsOneWidget);
    // 8月は1件のみのため月計とタイル金額が同額で2つ並ぶ
    expect(find.text('¥ 20,000'), findsNWidgets(2));
    expect(find.text('7月'), findsOneWidget);
    expect(find.text('¥ 40,000'), findsOneWidget);
    expect(find.text('焼肉'), findsOneWidget);
    // 交通費の明細は出ない
    expect(find.text('定期券'), findsNothing);
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
}
