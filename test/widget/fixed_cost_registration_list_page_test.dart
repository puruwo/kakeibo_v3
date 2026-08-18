// 固定費マスタ一覧ページ
// （lib/view/year_page/fixed_cost_button_area/fixed_cost_registration_list_page/）
// のWidget結合テスト
//
// 登録済み固定費がカテゴリー別に並ぶか、追加・編集の導線が開くかを見る。
// グルーピングのロジックは fixed_cost_registration_list_usecase_test（UT）で担保済み。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_entity.dart';
import 'package:kakeibo/view/year_page/fixed_cost_button_area/fixed_cost_registration_list_page/fixed_cost_registration_list_page.dart';

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

  // 固定費マスタ（10は固定額・次回支払日あり / 30は想定額6,000円の変動費）
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
      nextPaymentDate: '20250801',
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
    // 年1回払い（頻度ラベルの分岐確認用・削除済みなので一覧には出ない）
    FixedCostEntity(
      id: 40,
      name: '自動車税',
      variable: 0,
      price: 39500,
      fixedCostCategoryId: 1,
      intervalNumber: 1,
      intervalUnit: 2,
      firstPaymentDate: '20250501',
      deleteFlag: 1,
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

  /// 固定費マスタ一覧用のFake束を組み立てる
  ///
  /// [withRecords] をfalseにすると固定費が1件も登録されていない状態になる。
  TestFakes buildFakes({bool withRecords = true}) => TestFakes(
    fixedCost: FakeFixedCostRepository(
      initialRecords: withRecords ? fixedCosts : const [],
    ),
    fixedCostCategory: FakeFixedCostCategoryRepository(
      initialRecords: fixedCostCategories,
    ),
    expenseSmallCategory: FakeExpenseSmallCategoryRepository(
      initialRecords: expenseSmallCategories,
    ),
    expenseBigCategory: FakeExpenseBigCategoryRepository(
      initialRecords: expenseBigCategories,
    ),
  );

  testWidgets('カテゴリー別に固定費マスタが名前・金額・頻度で並ぶ', (tester) async {
    await pumpApp(
      tester,
      home: const FixedCostRegistrationListPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    // カテゴリーヘッダー（固定費が1件も無いカテゴリーは出ない）
    expect(find.text('住居'), findsOneWidget);
    expect(find.text('光熱費'), findsOneWidget);

    expect(find.text('家賃'), findsOneWidget);
    expect(find.text('¥ 80,000'), findsOneWidget);
    // 次回支払日は 'yyyy/MM/dd' で「次回：」付き
    expect(find.text('次回：2025/08/01'), findsOneWidget);
    // 支払い頻度（intervalUnit=1・intervalNumber=1 → 毎月）は2件ぶん
    expect(find.text('毎月'), findsNWidgets(2));

    // deleteFlag=1 の固定費は fetchAllActive で除外される
    expect(find.text('自動車税'), findsNothing);
  });

  testWidgets('変動費は「平均」ラベルと変動ありチップ付きで想定額が出る', (tester) async {
    await pumpApp(
      tester,
      home: const FixedCostRegistrationListPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    expect(find.text('電気代'), findsOneWidget);
    expect(find.text('平均'), findsOneWidget);
    expect(find.text('¥ 6,000'), findsOneWidget); // 想定額
    expect(find.text('変動あり'), findsOneWidget);
    // 次回支払日が未設定なら「次回：」行そのものが出ない
    expect(find.textContaining('次回：'), findsOneWidget);
  });

  testWidgets('FAB「固定費を追加」で固定費の記録モーダルが開く', (tester) async {
    await pumpApp(
      tester,
      home: const FixedCostRegistrationListPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('固定費を追加'));
    await pumpTimes(tester);

    // 記録モーダル（追加モード）のヘッダー
    expect(find.text('記録'), findsOneWidget);
    // 固定費タブの追加モードは初回支払い日・支払い頻度のピルが並ぶ
    expect(find.text('初回'), findsOneWidget);
    expect(find.text('頻度'), findsOneWidget);
    expect(find.text('支払い額変あり'), findsOneWidget);

    await unmountRegisterPage(tester);
  });

  testWidgets('タイル長押しのメニューから編集で固定費の編集モーダルが開く', (tester) async {
    await pumpApp(
      tester,
      home: const FixedCostRegistrationListPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    // 【発見事項】タイルのonTapは空実装（`onTap: () {}`）で、
    // 編集導線は長押しメニュー経由のみ。仕様どおり長押しから検証する。
    await tester.longPress(find.text('家賃'));
    await pumpTimes(tester);

    expect(find.text('編集'), findsOneWidget);
    expect(find.text('削除'), findsOneWidget);

    await tester.tap(find.text('編集'));
    await pumpTimes(tester);

    // 編集モーダルには対象固定費の値が初期表示される
    expect(find.text('80,000'), findsOneWidget);

    await unmountRegisterPage(tester);
  });

  testWidgets('固定費が1件も登録されていないときは空メッセージになる', (tester) async {
    await pumpApp(
      tester,
      home: const FixedCostRegistrationListPage(),
      fakes: buildFakes(withRecords: false),
    );
    await pumpTimes(tester);

    expect(find.text('固定費が登録されていません'), findsOneWidget);
    // 空状態ではFAB（追加導線）ごと出ない
    expect(find.text('固定費を追加'), findsNothing);
  });

  testWidgets('AppBarの歯車から設定画面へ遷移する', (tester) async {
    await pumpApp(
      tester,
      home: const FixedCostRegistrationListPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.byIcon(Icons.settings));
    await pumpTimes(tester);

    expect(find.text('設定'), findsOneWidget);
    expect(find.text('集計期間を設定する'), findsOneWidget);
  });
}
