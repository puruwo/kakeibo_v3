// 月間固定費ページ（lib/view/monthly_page/monthly_fixed_cost/）のWidget結合テスト
//
// 確定済み／未確定の固定費が正しく振り分けて表示されるか、
// 未確定タイルから編集シートを開いて金額を確定させたときに
// リポジトリへ正しいIDが渡るかを見る。
// 金額の集計ロジックそのものは monthly_fixed_cost_summary_usecase_test（UT）で担保済み。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/monthly_fixed_cost_page.dart';
import 'package:kakeibo/view/register_page/category_area/category_area.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

import '../helper/fake_repositories.dart';
import '../helper/widget_test_helper.dart';

void main() {
  // 支出大カテゴリー（1:住居 / 2:光熱費）
  // v10で固定費カテゴリーは支出カテゴリーへ移設され、
  // 月間固定費ページのグルーピングも支出大カテゴリー基準になった（仕様 §8.3）
  const expenseBigCategories = [
    ExpenseBigCategoryEntity(
      id: 1,
      colorCode: 'FFAA00',
      bigCategoryName: '住居',
      resourcePath: 'assets/images/icon_home.svg',
      displayOrder: 1,
      isDisplayed: 1,
    ),
    ExpenseBigCategoryEntity(
      id: 2,
      colorCode: '00AAFF',
      bigCategoryName: '光熱費',
      resourcePath: 'assets/images/icon_bolt.svg',
      displayOrder: 2,
      isDisplayed: 1,
    ),
  ];

  // 支出小カテゴリー（11:家賃→大1 / 12:電気→大2）
  const expenseSmallCategories = [
    ExpenseSmallCategoryEntity(
      id: 11,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 1,
      displayedOrderInBig: 1,
      smallCategoryName: '家賃',
      defaultDisplayed: 1,
    ),
    ExpenseSmallCategoryEntity(
      id: 12,
      smallCategoryOrderKey: 2,
      bigCategoryKey: 2,
      displayedOrderInBig: 1,
      smallCategoryName: '電気',
      defaultDisplayed: 1,
    ),
  ];

  // 固定費マスタ（10は毎月80,000円の固定額 / 30は想定額6,000円の変動費）
  const fixedCosts = [
    FixedCostEntity(
      id: 10,
      name: '家賃',
      variable: 0,
      price: 80000,
      expenseSmallCategoryId: 11,
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
      expenseSmallCategoryId: 12,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
      nextPaymentDate: '20250805',
    ),
  ];

  // 集計期間6/25〜7/24内の固定費行（確定80,000＋未確定の予想額6,000）
  const expenseFixedCostRows = [
    ExpenseEntity(
      id: 100,
      date: '20250701',
      price: 80000,
      paymentCategoryId: 11,
      memo: '家賃',
      fixedCostId: 10,
      isConfirmed: 1,
    ),
    ExpenseEntity(
      id: 200,
      date: '20250705',
      price: null,
      paymentCategoryId: 12,
      memo: '電気代',
      fixedCostId: 30,
      isConfirmed: 0,
      estimatedPrice: 6000,
    ),
  ];

  /// 月間固定費ページ用のFake束を組み立てる
  ///
  /// [withRecords] をfalseにすると固定費行が1件も無い状態（空状態）になる。
  TestFakes buildFakes({bool withRecords = true}) => TestFakes(
    fixedCost: FakeFixedCostRepository(
      initialRecords: withRecords ? fixedCosts : const [],
    ),
    expenseBigCategory: FakeExpenseBigCategoryRepository(
      initialRecords: expenseBigCategories,
    ),
    expenseSmallCategory: FakeExpenseSmallCategoryRepository(
      initialRecords: expenseSmallCategories,
    ),
    expense: FakeExpenseRepository(
      initialRecords: withRecords ? expenseFixedCostRows : const [],
    ),
  );

  testWidgets('ヘッダーに今月の固定費・確定分・未確定分（予想）の金額が出る', (tester) async {
    await pumpApp(
      tester,
      home: const MonthlyFixedCostPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    expect(find.text('固定費'), findsOneWidget); // AppBar
    expect(find.text('今月の固定費'), findsOneWidget);
    // 今月の固定費＝確定80,000＋未確定の予想6,000
    expect(find.text('¥ 86,000'), findsOneWidget);
    expect(find.text('確定分'), findsOneWidget);
    // 確定分はヘッダーと確定済みタイルの2箇所に出る
    expect(find.text('¥ 80,000'), findsNWidgets(2));
    expect(find.text('未確定分（予想）'), findsOneWidget);
    expect(find.text('¥ 6,000'), findsOneWidget);
  });

  testWidgets('確定済みの固定費がカテゴリー別に並ぶ', (tester) async {
    await pumpApp(
      tester,
      home: const MonthlyFixedCostPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    // カテゴリーヘッダー（アイコン付きなので見出しに先頭スペースは付かない）
    expect(find.text('住居'), findsOneWidget);
    // 1行目は固定費名、2行目は「小カテゴリー › 日付」（案A。仕様 §8.5）
    expect(find.text('家賃'), findsWidgets);
    // 支払い日は 'yyyy/M/d'（20250701 → 2025/7/1）。2行目はTextSpan構成なのでリッチテキストで探す
    expect(
      find.textContaining('家賃 › 2025/7/1', findRichText: true),
      findsOneWidget,
    );
    // 支払い頻度ラベル（intervalNumber=1・intervalUnit=1 → 毎月）
    expect(find.text('毎月'), findsWidgets);
  });

  testWidgets('未確定の固定費は「未入力」と想定額の平均ラベルで出る', (tester) async {
    await pumpApp(
      tester,
      home: const MonthlyFixedCostPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    expect(find.text('光熱費'), findsOneWidget);
    expect(find.text('電気代'), findsOneWidget);
    // 2行目は「小カテゴリー › 日付」
    expect(
      find.textContaining('電気 › 2025/7/5', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('未入力'), findsOneWidget);
    // 未確定タイルの金額下ラベルは「平均 <想定額> / <頻度>」
    expect(find.text('平均 ¥ 6,000 / 毎月'), findsOneWidget);
  });

  testWidgets('未確定タイルをタップすると固定費行の編集シートが開く', (tester) async {
    await pumpApp(
      tester,
      home: const MonthlyFixedCostPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('電気代'));
    await pumpTimes(tester);

    // v10で未確定の確定操作は編集シートに一本化した（旧・金額入力ダイアログは廃止。仕様 §6.6）
    expect(find.byType(RegisaterPageBase), findsOneWidget);
    expect(find.text('編集'), findsOneWidget);
    // 上部グループは変更不可の項目のみ（名称が最上段。仕様 §6.8）
    expect(find.text('名称'), findsOneWidget);
    expect(find.text('カテゴリー'), findsOneWidget);
    expect(find.text('光熱費 › 電気'), findsOneWidget);
    expect(find.text('頻度'), findsOneWidget);
    expect(find.text('支払日'), findsOneWidget);
    // 変動型なので予想額の行が出る
    expect(find.text('予想額'), findsOneWidget);
    // マスタ属性の変更は設定画面へ誘導する
    expect(find.text('固定費の設定を開く ›'), findsOneWidget);
    // 未確定行のボタン文言
    expect(find.text('金額を確定'), findsOneWidget);

    await unmountRegisterPage(tester);
  });

  testWidgets('金額を入れて確定すると固定費支出IDで実績行が更新される', (tester) async {
    final fakes = buildFakes();
    await pumpApp(tester, home: const MonthlyFixedCostPage(), fakes: fakes);
    await pumpTimes(tester);

    await tester.tap(find.text('電気代'));
    await pumpTimes(tester);

    // シート上の最初のTextFormFieldが金額欄
    await tester.enterText(find.byType(TextFormField).first, '7200');
    await tester.pump();
    await tester.tap(find.text('金額を確定'));
    await pumpTimes(tester);

    // 更新するのは固定費マスタID(30)ではなく実績行のID(200)
    // （確定操作のID取り違えを起こした本番バグの回帰検知）
    expect(fakes.expense.updatedEntities, hasLength(1));
    expect(fakes.expense.updatedEntities.single.id, 200);
    expect(fakes.expense.updatedEntities.single.price, 7200);
    // 金額入力＝確定操作（仕様 §6.4）
    expect(fakes.expense.updatedEntities.single.isConfirmed, 1);

    // 確定後は変動費の想定額更新まで走る（対象は固定費マスタID=30）
    expect(fakes.fixedCost.updatedEntities, hasLength(1));
    expect(fakes.fixedCost.updatedEntities.single.id, 30);
  });

  testWidgets('金額未入力のまま確定するとエラー文言が出て確定されない', (tester) async {
    final fakes = buildFakes();
    await pumpApp(tester, home: const MonthlyFixedCostPage(), fakes: fakes);
    await pumpTimes(tester);

    await tester.tap(find.text('電気代'));
    await pumpTimes(tester);
    await tester.tap(find.text('金額を確定'));
    await pumpTimes(tester);

    expect(find.textContaining('0円以上で入力してください'), findsOneWidget);
    expect(fakes.expense.updatedEntities, isEmpty);

    await waitForSnackBarDismissed(tester);
    await unmountRegisterPage(tester);
  });

  testWidgets('確定済みタイルをタップすると更新ボタンの編集シートが開く', (tester) async {
    await pumpApp(
      tester,
      home: const MonthlyFixedCostPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('家賃').first);
    await pumpTimes(tester);

    expect(find.byType(RegisaterPageBase), findsOneWidget);
    // 確定済み行のボタン文言は「更新」（仕様 §6.6）
    expect(find.text('更新'), findsOneWidget);
    expect(find.text('金額を確定'), findsNothing);
    // 下部グループで編集できるのは拠出元のみ。日付・メモ行は出さない（仕様 §6.8）
    expect(find.text('拠出元'), findsOneWidget);
    expect(find.text('メモ'), findsNothing);
    expect(find.text('日付'), findsNothing);
    // 確定型のマスタなので予想額の行は出さない
    expect(find.text('予想額'), findsNothing);
    // カテゴリーグリッドは表示しない
    expect(find.byType(CategoryArea), findsNothing);

    await unmountRegisterPage(tester);
  });

  testWidgets('固定費支出が1件も無いときは記録なしメッセージになる', (tester) async {
    await pumpApp(
      tester,
      home: const MonthlyFixedCostPage(),
      fakes: buildFakes(withRecords: false),
    );
    await pumpTimes(tester);

    expect(find.text('記録がまだありません'), findsOneWidget);
    // 合計はすべて0円（支払い予定・確定分・未確定分の3箇所）
    expect(find.text('¥ 0'), findsNWidgets(3));
  });

  testWidgets('フッターの「固定費を管理」で固定費マスタ一覧へ遷移する', (tester) async {
    await pumpApp(
      tester,
      home: const MonthlyFixedCostPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    expect(find.text('固定費を登録'), findsOneWidget);

    await tester.tap(find.text('固定費を管理'));
    await pumpTimes(tester);

    // 遷移先（固定費マスタ一覧）のFABラベル
    expect(find.text('固定費を追加'), findsOneWidget);
  });
}
