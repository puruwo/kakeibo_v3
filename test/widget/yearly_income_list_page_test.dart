// 収入一覧ページ（lib/view/yearly_income_list_page/）のWidget結合テスト
//
// 指定期間の収入が月別アコーディオン（初期は全月閉じた状態）で並ぶか、
// 合計が出るか、タイル・FABから記録モーダルへ入れるかを見る。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';
import 'package:kakeibo/view/yearly_income_list_page/yearly_income_list_page.dart';

import '../helper/fake_repositories.dart';
import '../helper/widget_test_helper.dart';

void main() {
  // システム日時2025/7/6・開始日25日・開始月4月 → 年度は2025/4/25〜2026/4/24
  final yearPeriod = PeriodValue(
    startDatetime: DateTime(2025, 4, 25),
    endDatetime: DateTime(2026, 4, 24),
  );

  const incomeBigCategories = [
    IncomeBigCategoryEntity(
      id: 1,
      name: '月次収入',
      colorCode: '21D19F',
      iconPath: 'assets/images/icon_regular_income.svg',
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

  // 年度内の収入（6月と7月にまたがる＝月別グループが2つできる）
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
      date: '20250705',
      price: 260000,
      memo: '7月分',
    ),
  ];

  // 記録モーダルは開いた瞬間に支出モードのカテゴリーも解決するため、
  // 空のマスタだと落ちる。モーダルを開くテスト用に最小限のマスタを積んでおく。
  const expenseSmallCategories = [
    ExpenseSmallCategoryEntity(
      id: 10,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 1,
      displayedOrderInBig: 1,
      smallCategoryName: '食費',
      defaultDisplayed: 1,
    ),
  ];
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

  /// 収入一覧ページ用のFake束を組み立てる
  ///
  /// [withRecords] をfalseにすると収入が1件も無い状態になる。
  TestFakes buildFakes({bool withRecords = true}) => TestFakes(
    income: FakeIncomeRepository(
      initialRecords: withRecords ? incomes : const [],
      smallCategoryToBigCategory: const {1: 1},
    ),
    incomeBigCategory: FakeIncomeBigCategoryRepository(
      initialRecords: incomeBigCategories,
    ),
    incomeSmallCategory: FakeIncomeSmallCategoryRepository(
      initialRecords: incomeSmallCategories,
    ),
    expenseSmallCategory: FakeExpenseSmallCategoryRepository(
      initialRecords: expenseSmallCategories,
    ),
    expenseBigCategory: FakeExpenseBigCategoryRepository(
      initialRecords: expenseBigCategories,
    ),
  );

  testWidgets('月別アコーディオン（初期は全月閉じた状態）と総収入が出る', (tester) async {
    await pumpApp(
      tester,
      home: YearlyIncomeListPage(period: yearPeriod),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    expect(find.text('収入一覧'), findsOneWidget); // AppBar
    // 月ヘッダーは新しい順（7月 → 6月）。期間開始年（2025年）は省略される
    expect(find.text('7月'), findsOneWidget);
    expect(find.text('6月'), findsOneWidget);
    expect(find.text('1件'), findsNWidgets(2));
    expect(find.text('¥ 260,000'), findsOneWidget); // 7月の月計
    expect(find.text('¥ 250,000'), findsOneWidget); // 6月の月計

    // グラフエリアの総収入（250,000＋260,000）
    expect(find.text('総収入'), findsOneWidget);
    // グラフエリアの合計とカテゴリー別内訳（給与のみ）で同じ金額が2箇所に出る
    expect(find.text('¥ 510,000'), findsNWidgets(2));

    // 初期は全月閉じた状態: 明細タイルは1件も出ない
    expect(find.text('7月5日'), findsNothing);
    expect(find.text('6月25日'), findsNothing);
  });

  testWidgets('月ヘッダーのタップでアコーディオンが開閉する', (tester) async {
    await pumpApp(
      tester,
      home: YearlyIncomeListPage(period: yearPeriod),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    // 7月を開く → 明細が出る（金額は月計と合わせて2箇所になる）
    await tester.tap(find.text('7月'));
    await pumpTimes(tester);
    expect(find.text('7月5日'), findsOneWidget);
    expect(find.text('7月分'), findsOneWidget);
    expect(find.text('¥ 260,000'), findsNWidgets(2));
    // 6月は閉じたまま
    expect(find.text('6月25日'), findsNothing);

    // 7月を閉じる → 明細が消える
    await tester.tap(find.text('7月'));
    await pumpTimes(tester);
    expect(find.text('7月5日'), findsNothing);
  });

  testWidgets('収入タイルのタップで編集モーダルが開く', (tester) async {
    await pumpApp(
      tester,
      home: YearlyIncomeListPage(period: yearPeriod),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    // 明細は月ヘッダーを開いてから触る
    await tester.tap(find.text('7月'));
    await pumpTimes(tester);

    await tester.tap(find.text('7月分'));
    await pumpTimes(tester);

    expect(find.byType(RegisaterPageBase), findsOneWidget);
    expect(find.text('編集'), findsOneWidget);
    expect(find.text('260,000'), findsWidgets); // 元の収入金額

    await unmountRegisterPage(tester);
  });

  testWidgets('FAB「収入を追加」で収入の記録モーダルが開く', (tester) async {
    await pumpApp(
      tester,
      home: YearlyIncomeListPage(period: yearPeriod),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('収入を追加'));
    await pumpTimes(tester);

    expect(find.byType(RegisaterPageBase), findsOneWidget);
    expect(find.text('記録'), findsOneWidget);
    // システム日時2025/7/6固定なので日付ピルはその日
    expect(find.text('7/6'), findsOneWidget);

    await unmountRegisterPage(tester);
  });

  testWidgets('収入が1件も無いときは空メッセージになる', (tester) async {
    await pumpApp(
      tester,
      home: YearlyIncomeListPage(period: yearPeriod),
      fakes: buildFakes(withRecords: false),
    );
    await pumpTimes(tester);

    expect(find.text('収入が登録されていません'), findsOneWidget);
  });
}
