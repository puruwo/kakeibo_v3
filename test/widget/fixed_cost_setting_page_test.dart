// 固定費の設定画面（lib/view/fixed_cost_setting_page/）のWidget結合テスト
//
// マスタ属性の編集・保存・削除の導線と、変動スイッチによる金額行の切り替えを見る。
// 保存内容の妥当性検証（推定額の同期など）は fixed_cost_usecase_test（UT）で担保済み。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/view/fixed_cost_setting_page/fixed_cost_setting_page.dart';

import '../helper/fake_repositories.dart';
import '../helper/widget_test_helper.dart';

void main() {
  // 支出大カテゴリー（1:住居 / 2:光熱費）
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

  // 編集対象の固定費マスタ（毎月80,000円の確定型）
  const target = FixedCostEntity(
    id: 10,
    name: '家賃',
    variable: 0,
    price: 80000,
    expenseSmallCategoryId: 11,
    intervalNumber: 1,
    intervalUnit: 1,
    firstPaymentDate: '20250101',
    nextPaymentDate: '20250801',
  );

  // 支払い履歴（マスタID=10の確定済み1件）
  const expenseRows = [
    ExpenseEntity(
      id: 100,
      date: '20250701',
      price: 80000,
      paymentCategoryId: 11,
      memo: '家賃',
      fixedCostId: 10,
      isConfirmed: 1,
    ),
  ];

  /// 固定費の設定画面用のFake束を組み立てる
  TestFakes buildFakes({List<ExpenseEntity> rows = expenseRows}) => TestFakes(
    fixedCost: FakeFixedCostRepository(initialRecords: const [target]),
    expense: FakeExpenseRepository(initialRecords: rows),
    expenseBigCategory: FakeExpenseBigCategoryRepository(
      initialRecords: expenseBigCategories,
    ),
    expenseSmallCategory: FakeExpenseSmallCategoryRepository(
      initialRecords: expenseSmallCategories,
    ),
  );

  testWidgets('マスタの値が各グループに初期表示される', (tester) async {
    await pumpApp(
      tester,
      home: const FixedCostSettingPage(fixedCostEntity: target),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    expect(find.text('固定費の設定'), findsOneWidget);
    // 「固定費」グループ
    expect(find.text('名称'), findsOneWidget);
    expect(find.text('家賃'), findsWidgets);
    expect(find.text('カテゴリー'), findsOneWidget);
    expect(find.text('住居 › 家賃'), findsOneWidget);
    // 「設定」グループ（確定型なので金額はテキストフィールド）
    expect(find.text('金額'), findsOneWidget);
    expect(find.text('80,000'), findsOneWidget);
    expect(find.text('頻度'), findsOneWidget);
    expect(find.text('次回支払日'), findsOneWidget);
    expect(find.text('8/1'), findsOneWidget);
    expect(find.text('支払い額が毎回変わる'), findsOneWidget);
    // 「支払い履歴」グループ
    expect(find.text('支払い履歴'), findsOneWidget);
    expect(find.text('すべての支払いを見る'), findsOneWidget);
    // フッター
    expect(find.text('この固定費を削除'), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);
  });

  testWidgets('変動スイッチONで金額行が予想額の表示に切り替わる', (tester) async {
    await pumpApp(
      tester,
      home: const FixedCostSettingPage(fixedCostEntity: target),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.byType(Switch));
    await pumpTimes(tester);

    // 変動型は実額を持たないため入力させない（仕様 §6.7）
    expect(find.text('金額'), findsNothing);
    expect(find.text('予想額'), findsOneWidget);
    // 確定行（80,000円）の平均を予想額に出す。0円にしない（仕様 §6.8）
    expect(find.text('¥ 80,000（自動）'), findsOneWidget);
  });

  testWidgets('確定行が無いときの変動スイッチONはマスタの金額を予想額に出す', (tester) async {
    await pumpApp(
      tester,
      home: const FixedCostSettingPage(fixedCostEntity: target),
      fakes: buildFakes(rows: const []),
    );
    await pumpTimes(tester);

    await tester.tap(find.byType(Switch));
    await pumpTimes(tester);

    expect(find.text('¥ 80,000（自動）'), findsOneWidget);
  });

  testWidgets('変動スイッチONで保存すると予想額がマスタに反映される', (tester) async {
    final fakes = buildFakes();
    await pumpApp(
      tester,
      home: const FixedCostSettingPage(fixedCostEntity: target),
      fakes: fakes,
    );
    await pumpTimes(tester);

    await tester.tap(find.byType(Switch));
    await pumpTimes(tester);
    await tester.tap(find.text('保存'));
    await pumpTimes(tester);

    final updated = fakes.fixedCost.updatedEntities.last;
    expect(updated.variable, 1);
    expect(updated.estimatedPrice, 80000);

    await waitForSnackBarDismissed(tester);
  });

  testWidgets('「すべての支払いを見る」で支払い履歴ページ（準備中）へ遷移する', (tester) async {
    await pumpApp(
      tester,
      home: const FixedCostSettingPage(fixedCostEntity: target),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('すべての支払いを見る'));
    await pumpTimes(tester, times: 5);

    // 本実装は本案件クローズ後。いまは仮ページ（仕様 §6.8）
    // 遷移元の「支払い履歴」グループ見出しもツリーに残るためAppBarで特定する
    expect(find.widgetWithText(AppBar, '支払い履歴'), findsOneWidget);
    expect(find.text('この画面は準備中です'), findsOneWidget);
  });

  testWidgets('カテゴリー選択シートは大カテゴリー→小カテゴリーの2段で選ぶ', (tester) async {
    final fakes = buildFakes();
    await pumpApp(
      tester,
      home: const FixedCostSettingPage(fixedCostEntity: target),
      fakes: fakes,
    );
    await pumpTimes(tester);

    await tester.tap(find.text('住居 › 家賃'));
    await pumpTimes(tester, times: 5);

    // 1段目は大カテゴリーの一覧（小カテゴリー名は出さない）
    expect(find.text('カテゴリーを選ぶ'), findsOneWidget);
    expect(find.text('住居'), findsOneWidget);
    expect(find.text('光熱費'), findsOneWidget);
    expect(find.text('電気'), findsNothing);

    // 2段目へ。上部にどの大カテゴリーかを出す
    await tester.tap(find.text('光熱費'));
    await pumpTimes(tester, times: 5);
    expect(find.text('光熱費'), findsOneWidget);
    expect(find.text('電気'), findsOneWidget);
    expect(find.text('住居'), findsNothing);

    // 小カテゴリーを選ぶとシートが閉じ、カテゴリー行に反映される
    await tester.tap(find.text('電気'));
    await pumpTimes(tester, times: 5);
    expect(find.text('光熱費 › 電気'), findsOneWidget);
  });

  testWidgets('支払い履歴が0件のときは案内文が出る', (tester) async {
    await pumpApp(
      tester,
      home: const FixedCostSettingPage(fixedCostEntity: target),
      fakes: buildFakes(rows: const []),
    );
    await pumpTimes(tester);

    expect(find.text('まだ支払いの記録がありません'), findsOneWidget);
  });

  testWidgets('名称と金額を変えて保存するとマスタが更新される', (tester) async {
    final fakes = buildFakes();
    await pumpApp(
      tester,
      home: const FixedCostSettingPage(fixedCostEntity: target),
      fakes: fakes,
    );
    await pumpTimes(tester);

    // 0番目が名称、1番目が金額のテキストフィールド
    await tester.enterText(find.byType(TextFormField).at(0), '家賃（新居）');
    await tester.enterText(find.byType(TextFormField).at(1), '85000');
    await tester.pump();

    await tester.tap(find.text('保存'));
    await pumpTimes(tester);

    expect(fakes.fixedCost.updatedEntities, hasLength(1));
    final updated = fakes.fixedCost.updatedEntities.single;
    expect(updated.id, 10);
    expect(updated.name, '家賃（新居）');
    expect(updated.price, 85000);
    expect(updated.expenseSmallCategoryId, 11);

    await waitForSnackBarDismissed(tester);
  });

  testWidgets('削除は確認ダイアログを経てマスタの論理削除が呼ばれる', (tester) async {
    final fakes = buildFakes();
    await pumpApp(
      tester,
      home: const FixedCostSettingPage(fixedCostEntity: target),
      fakes: fakes,
    );
    await pumpTimes(tester);

    await tester.tap(find.text('この固定費を削除'));
    await pumpTimes(tester, times: 5);

    // 固定費マスタ専用の削除確認ダイアログ（→ ADR-007）
    expect(find.text('固定費を削除'), findsOneWidget);
    expect(
      find.text('支払日が過ぎた記録は残りますが、\n未確定分と今後の予定は削除されます。\n本当に削除しますか？'),
      findsOneWidget,
    );

    await tester.tap(find.text('OK'));
    await pumpTimes(tester, times: 10);

    expect(fakes.fixedCost.deletedWithUnpaidExpensesArgs, hasLength(1));
    expect(fakes.fixedCost.deletedWithUnpaidExpensesArgs.single.id, 10);
  });

  testWidgets('削除の確認ダイアログをキャンセルすると削除されない', (tester) async {
    final fakes = buildFakes();
    await pumpApp(
      tester,
      home: const FixedCostSettingPage(fixedCostEntity: target),
      fakes: fakes,
    );
    await pumpTimes(tester);

    await tester.tap(find.text('この固定費を削除'));
    await pumpTimes(tester, times: 5);
    await tester.tap(find.text('キャンセル'));
    await pumpTimes(tester, times: 10);

    expect(fakes.fixedCost.deletedWithUnpaidExpensesArgs, isEmpty);
    expect(find.text('固定費を削除'), findsNothing);
  });
}
