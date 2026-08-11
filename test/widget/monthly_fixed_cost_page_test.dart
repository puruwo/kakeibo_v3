// 月間固定費ページ（lib/view/monthly_page/monthly_fixed_cost/）のWidget結合テスト
//
// 確定済み／未確定の固定費が正しく振り分けて表示されるか、
// 未確定タイルから金額を確定させたときにリポジトリへ正しいIDが渡るかを見る。
// 金額の集計ロジックそのものは monthly_fixed_cost_summary_usecase_test（UT）で担保済み。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_entity.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/monthly_fixed_cost_page.dart';

import '../helper/fake_repositories.dart';
import '../helper/widget_test_helper.dart';

void main() {
  // 固定費カテゴリー（1:住居 / 2:光熱費）
  const fixedCostCategories = [
    FixedCostCategoryEntity(
      id: 1,
      categoryName: '住居',
      colorCode: 'FFAA00',
      resourcePath: 'assets/images/icon_home.svg',
    ),
    FixedCostCategoryEntity(
      id: 2,
      categoryName: '光熱費',
      colorCode: '00AAFF',
      resourcePath: 'assets/images/icon_bolt.svg',
    ),
  ];

  // 固定費マスタ（10は毎月80,000円の固定額 / 30は想定額6,000円の変動費）
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
    FixedCostEntity(
      id: 30,
      name: '電気代',
      variable: 1,
      estimatedPrice: 6000,
      fixedCostCategoryId: 2,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
    ),
  ];

  // 集計期間6/25〜7/24内の固定費支出（確定80,000＋未確定＝想定6,000）
  const fixedCostExpenses = [
    FixedCostExpenseEntity(
      id: 100,
      fixedCostId: 10,
      fixedCostCategoryId: 1,
      date: '20250701',
      price: 80000,
      name: '家賃',
      isConfirmed: 1,
    ),
    FixedCostExpenseEntity(
      id: 200,
      fixedCostId: 30,
      fixedCostCategoryId: 2,
      date: '20250705',
      name: '電気代',
      confirmedCostType: 1,
      isConfirmed: 0,
    ),
  ];

  /// 月間固定費ページ用のFake束を組み立てる
  ///
  /// [withRecords] をfalseにすると固定費支出が1件も無い状態（空状態）になる。
  TestFakes buildFakes({bool withRecords = true}) => TestFakes(
    fixedCost: FakeFixedCostRepository(
      initialRecords: withRecords ? fixedCosts : const [],
    ),
    fixedCostCategory: FakeFixedCostCategoryRepository(
      initialRecords: withRecords ? fixedCostCategories : const [],
    ),
    fixedCostExpense: FakeFixedCostExpenseRepository(
      initialRecords: withRecords ? fixedCostExpenses : const [],
    ),
  );

  testWidgets('ヘッダーに支払い予定・確定分・未確定分（想定）の金額が出る', (tester) async {
    await pumpApp(
      tester,
      home: const MonthlyFixedCostPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    expect(find.text('固定費'), findsOneWidget); // AppBar
    expect(find.text('今月の支払い予定'), findsOneWidget);
    // 支払い予定＝確定80,000＋未確定の想定6,000
    expect(find.text('¥ 86,000'), findsOneWidget);
    expect(find.text('確定分'), findsOneWidget);
    // 確定分はヘッダーと確定済みタイルの2箇所に出る
    expect(find.text('¥ 80,000'), findsNWidgets(2));
    expect(find.text('未確定分（想定）'), findsOneWidget);
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
    expect(find.text('家賃'), findsOneWidget);
    // 支払い日は 'yyyy/M/d'（20250701 → 2025/7/1）
    expect(find.text('2025/7/1'), findsOneWidget);
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
    expect(find.text('2025/7/5'), findsOneWidget);
    expect(find.text('未入力'), findsOneWidget);
    // 未確定タイルの金額下ラベルは「平均 <想定額> / <頻度>」
    expect(find.text('平均 ¥ 6,000 / 毎月'), findsOneWidget);
  });

  testWidgets('未確定タイルをタップすると金額確定ダイアログが開く', (tester) async {
    await pumpApp(
      tester,
      home: const MonthlyFixedCostPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('電気代'));
    await pumpTimes(tester);

    expect(find.text('未確定固定費の金額を入力'), findsOneWidget);
    expect(find.text('キャンセル'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets('金額を入れてOKすると固定費支出IDでconfirmExpenseが呼ばれる', (tester) async {
    final fakes = buildFakes();
    await pumpApp(tester, home: const MonthlyFixedCostPage(), fakes: fakes);
    await pumpTimes(tester);

    await tester.tap(find.text('電気代'));
    await pumpTimes(tester);

    await tester.enterText(find.byType(TextFormField), '7200');
    await tester.pump();
    await tester.tap(find.text('OK'));
    await pumpTimes(tester);

    // 渡すのは固定費マスタID(30)ではなく固定費支出のID(200)
    // （確定操作のID取り違えを起こした本番バグの回帰検知）
    expect(fakes.fixedCostExpense.confirmedExpenses, hasLength(1));
    expect(fakes.fixedCostExpense.confirmedExpenses.single.id, 200);
    expect(fakes.fixedCostExpense.confirmedExpenses.single.price, 7200);

    // 確定後は変動費の想定額更新まで走る（対象は固定費マスタID=30）
    expect(fakes.fixedCost.updatedEntities, hasLength(1));
    expect(fakes.fixedCost.updatedEntities.single.id, 30);
  });

  testWidgets('金額未入力のままOKするとエラー文言が出て確定されない', (tester) async {
    final fakes = buildFakes();
    await pumpApp(tester, home: const MonthlyFixedCostPage(), fakes: fakes);
    await pumpTimes(tester);

    await tester.tap(find.text('電気代'));
    await pumpTimes(tester);
    await tester.tap(find.text('OK'));
    await pumpTimes(tester);

    expect(find.text('金額を入力してください'), findsOneWidget);
    expect(fakes.fixedCostExpense.confirmedExpenses, isEmpty);

    await waitForSnackBarDismissed(tester);
  });

  testWidgets('ダイアログをキャンセルすると確定されずダイアログが閉じる', (tester) async {
    final fakes = buildFakes();
    await pumpApp(tester, home: const MonthlyFixedCostPage(), fakes: fakes);
    await pumpTimes(tester);

    await tester.tap(find.text('電気代'));
    await pumpTimes(tester);
    await tester.enterText(find.byType(TextFormField), '7200');
    await tester.tap(find.text('キャンセル'));
    await pumpTimes(tester);

    expect(find.text('未確定固定費の金額を入力'), findsNothing);
    expect(fakes.fixedCostExpense.confirmedExpenses, isEmpty);
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
