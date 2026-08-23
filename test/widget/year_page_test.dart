// ホームタブ（lib/view/year_page/）のWidget結合テスト
//
// 年度の集計結果が画面に出るか・各導線が正しい画面へ遷移するかを見る。
// 金額の計算そのものは yearly_balance_usecase_test / annual_balance_chart_usecase_test
// （UT）で担保済みなので、ここでは「Fakeに入れた値が画面に出る」までを確認する。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/view/component/app_empty_state.dart';
import 'package:kakeibo/view/year_page/annual_balance_chart/annual_balance_chart.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_plan_area.dart';
import 'package:kakeibo/view/year_page/year_page.dart';

import '../helper/fake_repositories.dart';
import '../helper/widget_test_helper.dart';

void main() {
  /// セクション見出しのFinder
  ///
  /// [AppContentsHeader] はアイコン無しのとき見出しの頭に半角スペースを足して
  /// アイコンありの行と左端を揃えるため、探す文字列も先頭スペース込みにする。
  Finder sectionTitle(String title) => find.text(' $title');

  // システム日時2025/7/6・開始日25日・開始月4月 → 年度は2025/4/25〜2026/4/24。
  // Fakeの期間別マップは「期間開始日のyyyyMMdd」がキーなので、年度＝20250425。
  const yearKey = '20250425';
  // 年度内の各月度の開始日（生活収支チャート用）
  const mayKey = '20250525';
  const juneKey = '20250625';

  /// 年間収支・ボーナス・生活収支チャートに値が入った状態のFake束を作る
  ///
  /// [income] 年度の収入合計 / [expense] 年度の支出合計
  /// （v10で固定費実績もexpenseに入るため、支出はこの1つの値に含まれる）
  /// [bonusIncome] [bonusExpense] 年度のボーナス収入・支出
  /// [fixedCostRecords] 固定費マスタ（有効件数の表示に使う）
  TestFakes buildFakes({
    int income = 3000000,
    int expense = 1000000,
    int bonusIncome = 400000,
    int bonusExpense = 150000,
    Map<String, int> monthlyIncome = const {},
    Map<String, int> monthlyExpense = const {},
    List<FixedCostEntity>? fixedCostRecords,
  }) {
    final incomeRepository = FakeIncomeRepository()
      // 年間収支カードの総収入（カテゴリー指定なしの期間合計）
      ..sumWithPeriodResultByPeriodStart[yearKey] = income
      // ボーナス収入（大カテゴリー指定つき）。生活収支チャートも同じマップを見る
      ..sumWithAccountTypeAndPeriodResultByPeriodStart[yearKey] = bonusIncome
      ..sumWithAccountTypeAndPeriodResultByPeriodStart.addAll(monthlyIncome);
    final expenseRepository = FakeExpenseRepository()
      ..totalExpenseByPeriodResultByPeriodStart[yearKey] = expense
      ..totalExpenseByPeriodWithBigCategoryResultByPeriodStart[yearKey] =
          bonusExpense
      ..totalExpenseByPeriodWithBigCategoryResultByPeriodStart.addAll(
        monthlyExpense,
      );
    return TestFakes(
      income: incomeRepository,
      expense: expenseRepository,
      fixedCost: FakeFixedCostRepository(initialRecords: fixedCostRecords),
      // 固定費一覧は支出大カテゴリーでグループ化するのでマスタが要る（仕様 §8.4）
      expenseBigCategory: FakeExpenseBigCategoryRepository(
        initialRecords: const [
          ExpenseBigCategoryEntity(
            id: 1,
            colorCode: 'FFAA00',
            bigCategoryName: '住居',
            resourcePath: 'assets/images/icon_home.svg',
            displayOrder: 1,
            isDisplayed: 1,
          ),
        ],
      ),
      expenseSmallCategory: FakeExpenseSmallCategoryRepository(
        initialRecords: const [
          ExpenseSmallCategoryEntity(
            id: 11,
            smallCategoryOrderKey: 1,
            bigCategoryKey: 1,
            displayedOrderInBig: 1,
            smallCategoryName: '家賃',
            defaultDisplayed: 1,
          ),
        ],
      ),
    );
  }

  /// 固定費マスタ1件（有効件数の表示確認用）
  const fixedCostRecord = FixedCostEntity(
    id: 1,
    name: '家賃',
    variable: 0,
    price: 80000,
    expenseSmallCategoryId: 11,
    intervalNumber: 1,
    intervalUnit: 1,
    firstPaymentDate: '20250625',
    recentPaymentDate: null,
    nextPaymentDate: '20250725',
    deleteFlag: 0,
  );

  testWidgets('ヘッダーに期間レンジと年度ラベルが2段で並ぶ', (tester) async {
    await pumpApp(tester, home: const YearPage(), fakes: buildFakes());
    await pumpTimes(tester);

    // 年度2025/4/25〜2026/4/24 → 「2025年4月 - 2026年4月」＋「2025年度」
    expect(find.text('2025年4月 - 2026年4月'), findsOneWidget);
    expect(find.text('2025年度'), findsOneWidget);
  });

  testWidgets('年間収支カードに総支出・総収入・残金が出る', (tester) async {
    await pumpApp(
      tester,
      home: const YearPage(),
      // 支出1,972,000＝一般1,000,000＋確定固定費900,000＋未確定固定費72,000
      // （v10ではSQL側で合算済みの1つの値として返る）
      fakes: buildFakes(income: 3000000, expense: 1972000),
    );
    await pumpTimes(tester);

    expect(sectionTitle('年間収支'), findsOneWidget);
    // 総収入・総支出はText.richで組まれている（末尾に「>」アイコンを埋めている）
    expect(find.textContaining('総収入', findRichText: true), findsOneWidget);
    expect(find.textContaining('総支出', findRichText: true), findsOneWidget);
    expect(find.text('¥ 1,972,000'), findsOneWidget);
    expect(find.text('¥ 3,000,000'), findsOneWidget);
    // 残金＝収入3,000,000－支出1,972,000
    expect(find.text('残金'), findsOneWidget);
    expect(find.text('¥ 1,028,000'), findsOneWidget);
  });

  testWidgets('生活収支チャートが描画される', (tester) async {
    await pumpApp(
      tester,
      home: const YearPage(),
      fakes: buildFakes(
        // 5月度・6月度に記録を入れて「記録なし」状態を外す
        monthlyIncome: const {mayKey: 300000, juneKey: 300000},
        monthlyExpense: const {mayKey: 120000, juneKey: 150000},
      ),
    );
    await pumpTimes(tester);

    expect(sectionTitle('生活収支'), findsOneWidget);
    expect(find.byType(AnnualBalanceChart), findsOneWidget);
    expect(find.text('まだ記録がありません'), findsNothing);
  });

  testWidgets('固定費が0件なら登録誘導カード、1件以上なら一覧行になる', (tester) async {
    await pumpApp(tester, home: const YearPage(), fakes: buildFakes());
    await pumpTimes(tester);

    // 固定費マスタ0件 → 誘導カード
    expect(find.text('固定費を登録しましょう'), findsOneWidget);
    // ADR-022: 誘導カードは共通コンポーネント AppEmptyState で表示される
    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('固定費一覧'), findsNothing);
  });

  testWidgets('固定費一覧行をタップすると固定費登録リストへ遷移する', (tester) async {
    await pumpApp(
      tester,
      home: const YearPage(),
      fakes: buildFakes(fixedCostRecords: const [fixedCostRecord]),
    );
    await pumpTimes(tester);

    expect(find.text('固定費一覧'), findsOneWidget);
    expect(find.text('1件'), findsOneWidget); // 有効な固定費の件数

    await tester.tap(find.text('固定費一覧'));
    await pumpTimes(tester);

    // 遷移先（固定費登録リスト）のヘッダーと登録済み固定費が出る
    expect(find.text('固定費'), findsOneWidget);
    expect(find.text('家賃'), findsOneWidget);
  });

  testWidgets('ボーナスエリアに収入・利用額・残額が出る', (tester) async {
    await pumpApp(
      tester,
      home: const YearPage(),
      fakes: buildFakes(bonusIncome: 400000, bonusExpense: 150000),
    );
    await pumpTimes(tester);

    expect(sectionTitle('特別枠の利用状況'), findsOneWidget);
    expect(find.byType(BonusPlanArea), findsOneWidget);
    expect(find.text('¥ 400,000'), findsOneWidget); // ボーナス収入
    expect(find.text('¥ 150,000'), findsOneWidget); // 利用額
    expect(find.text('残額'), findsOneWidget);
    expect(find.text('¥ 250,000'), findsOneWidget);
  });

  testWidgets('記録はあるがボーナスが未登録なら登録誘導カード（AppEmptyState）になる', (tester) async {
    await pumpApp(
      tester,
      home: const YearPage(),
      fakes: buildFakes(
        bonusIncome: 0,
        bonusExpense: 0,
        // 生活収支に記録があるときだけボーナス誘導カードが出る（記録ゼロなら非表示）
        monthlyIncome: const {mayKey: 300000},
        monthlyExpense: const {mayKey: 120000},
      ),
    );
    await pumpTimes(tester);

    // Q-15: ボーナス誘導カードも ADR-022 の AppEmptyState で表示される
    expect(find.text('特別枠の収入を登録しましょう'), findsOneWidget);
    expect(find.text('＋ 収入を登録する'), findsOneWidget);
    expect(sectionTitle('特別枠の利用状況'), findsNothing);
    expect(find.byType(BonusPlanArea), findsNothing);
    // 固定費0件の誘導カードと並ぶ（別アクション同士の並存はADR-022の例外として許容）
    expect(find.text('固定費を登録しましょう'), findsOneWidget);
    expect(find.byType(AppEmptyState), findsNWidgets(2));
  });

  testWidgets('ボーナスの「さらに表示する」でボーナスホームへ遷移する', (tester) async {
    await pumpApp(
      tester,
      home: const YearPage(),
      fakes: buildFakes(bonusIncome: 400000, bonusExpense: 150000),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('さらに表示する'));
    await pumpTimes(tester);

    // ボーナスホーム画面のヘッダー（セクション見出しではなくページタイトル）
    expect(find.text('特別枠の利用状況'), findsOneWidget);
  });

  testWidgets('総収入行をタップすると年間収入リストへ遷移する', (tester) async {
    await pumpApp(tester, home: const YearPage(), fakes: buildFakes());
    await pumpTimes(tester);

    await tester.tap(find.textContaining('総収入', findRichText: true));
    await pumpTimes(tester);

    expect(find.text('収入一覧'), findsOneWidget);
  });

  testWidgets('総支出行をタップすると年間支出リストへ遷移する', (tester) async {
    await pumpApp(tester, home: const YearPage(), fakes: buildFakes());
    await pumpTimes(tester);

    await tester.tap(find.textContaining('総支出', findRichText: true));
    await pumpTimes(tester);

    expect(find.text('支出一覧'), findsOneWidget);
  });

  testWidgets('記録が1件も無いときは空状態（記録をはじめる案内）になる', (tester) async {
    await pumpApp(
      tester,
      home: const YearPage(),
      fakes: buildFakes(income: 0, expense: 0, bonusIncome: 0, bonusExpense: 0),
    );
    await pumpTimes(tester);

    expect(find.text('家計簿をはじめましょう'), findsOneWidget);
    expect(find.text('＋ 記録を追加する'), findsOneWidget);
    // 記録なしのときは年間収支ヘッダー・生活収支セクション・ボーナスは出ない
    expect(sectionTitle('年間収支'), findsNothing);
    expect(sectionTitle('生活収支'), findsNothing);
    expect(sectionTitle('特別枠の利用状況'), findsNothing);
  });

  testWidgets('ヘッダーをタップすると年度ピッカーが開く', (tester) async {
    await pumpApp(tester, home: const YearPage(), fakes: buildFakes());
    await pumpTimes(tester);

    await tester.tap(find.text('2025年度'));
    await pumpTimes(tester);

    // ピッカーの確定ボタン
    expect(find.text('適用'), findsOneWidget);
  });
}
