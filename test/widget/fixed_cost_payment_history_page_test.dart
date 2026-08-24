// 固定費の支払い履歴ページ
// （lib/view/fixed_cost_setting_page/fixed_cost_payment_history_page.dart）のWidget結合テスト
//
// サマリーカード（変動型は3列目が平均）と、確定行の実額・未確定行の「未入力」表示を見る。
// 取得・集計のロジックは usecase 層のUTで担保済み。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/view/fixed_cost_setting_page/fixed_cost_payment_history_page.dart';

import '../helper/fake_repositories.dart';
import '../helper/widget_test_helper.dart';

void main() {
  // 支出カテゴリー（大: 光熱費 › 小: 電気）
  const expenseBigCategories = [
    ExpenseBigCategoryEntity(
      id: 2,
      colorCode: '00AAFF',
      bigCategoryName: '光熱費',
      resourcePath: 'assets/images/icon_bolt.svg',
      displayOrder: 1,
      isDisplayed: 1,
    ),
  ];
  const expenseSmallCategories = [
    ExpenseSmallCategoryEntity(
      id: 12,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 2,
      displayedOrderInBig: 1,
      smallCategoryName: '電気',
      defaultDisplayed: 1,
    ),
  ];

  // 変動型の固定費マスタ（サマリー3列目が「平均（確定分）」になる）
  const target = FixedCostEntity(
    id: 10,
    name: '電気代',
    variable: 1,
    estimatedPrice: 8000,
    expenseSmallCategoryId: 12,
    intervalNumber: 1,
    intervalUnit: 1,
    firstPaymentDate: '20250701',
  );

  // 確定1件＋未確定1件（未確定は実額NULL・予想額のみ。v10仕様）
  const expenseRows = [
    ExpenseEntity(
      id: 100,
      date: '20250701',
      price: 8000,
      paymentCategoryId: 12,
      fixedCostId: 10,
      isConfirmed: 1,
    ),
    ExpenseEntity(
      id: 101,
      date: '20250801',
      paymentCategoryId: 12,
      fixedCostId: 10,
      isConfirmed: 0,
      estimatedPrice: 8000,
    ),
  ];

  /// 支払い履歴ページ用のFake束を組み立てる
  TestFakes buildFakes() => TestFakes(
    fixedCost: FakeFixedCostRepository(initialRecords: const [target]),
    expense: FakeExpenseRepository(initialRecords: expenseRows),
    expenseBigCategory: FakeExpenseBigCategoryRepository(
      initialRecords: expenseBigCategories,
    ),
    expenseSmallCategory: FakeExpenseSmallCategoryRepository(
      initialRecords: expenseSmallCategories,
    ),
  );

  testWidgets('サマリーと履歴が出て、未確定行は金額ではなく「未入力」を出す', (tester) async {
    await pumpApp(
      tester,
      home: const FixedCostPaymentHistoryPage(fixedCostId: 10),
      fakes: buildFakes(),
    );
    await pumpTimes(tester, times: 5);

    expect(find.widgetWithText(AppBar, '支払い履歴'), findsOneWidget);
    expect(find.text('電気代'), findsOneWidget);

    // サマリー: 合計・回数は確定分のみ。変動型なので3列目は平均（確定分）（仕様 §6.8）
    expect(find.text('支払い合計'), findsOneWidget);
    expect(find.text('支払い回数'), findsOneWidget);
    expect(find.text('1回'), findsOneWidget);
    expect(find.text('平均（確定分）'), findsOneWidget);

    // 確定行は実額（サマリーの合計・平均、年小計にも同額が出るため複数件を許容）
    expect(find.text('7/1'), findsOneWidget);
    expect(find.text('¥ 8,000'), findsWidgets);

    // 未確定行は推定額を出さず「未入力」（案件: 固定費バッジデザイン調整 決定C-1）
    expect(find.text('8/1'), findsOneWidget);
    expect(find.text('未入力'), findsOneWidget);
  });
}
