// 大カテゴリー支出履歴ページ
// （lib/view/monthly_page/category_tile/big_category_expense_history_page/）
// のWidget結合テスト
//
// 上部のカテゴリーサマリー＋小カテゴリー内訳と、下部の日別支出履歴の表示、
// 小カテゴリー展開・支出編集の導線を見る。
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_entity.dart';
import 'package:kakeibo/domain/db/budget/budget_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_entity.dart';
import 'package:kakeibo/view/monthly_page/category_tile/big_category_expense_history_page/category_expense_hisotry_page.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

import '../helper/fake_repositories.dart';
import '../helper/widget_test_helper.dart';

void main() {
  // システム日時2025/7/6・開始日25日 → 集計期間は2025/6/25〜7/24（代表月202506）
  const monthKey = '202506';

  const expenseBigCategories = [
    ExpenseBigCategoryEntity(
      id: 1,
      colorCode: 'FFAA00',
      bigCategoryName: '食費',
      resourcePath: 'assets/images/icon_meal.svg',
      displayOrder: 1,
      isDisplayed: 1,
    ),
  ];

  // 大カテゴリー1に属する小カテゴリー2件
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
      id: 11,
      smallCategoryOrderKey: 2,
      bigCategoryKey: 1,
      displayedOrderInBig: 2,
      smallCategoryName: '中食',
      defaultDisplayed: 1,
    ),
  ];

  // 集計期間6/25〜7/24内の支出（外食30,000＝2件／中食5,000＝1件）
  const expenses = [
    ExpenseEntity(
      id: 1,
      date: '20250701',
      price: 12000,
      paymentCategoryId: 10,
      memo: 'ランチ',
    ),
    ExpenseEntity(
      id: 2,
      date: '20250705',
      price: 18000,
      paymentCategoryId: 10,
      memo: 'ディナー',
    ),
    ExpenseEntity(
      id: 3,
      date: '20250703',
      price: 5000,
      paymentCategoryId: 11,
      memo: 'スーパー',
    ),
    // 固定費由来の支出行（明細に「固定費」チップが付く。仕様 §7.2）
    ExpenseEntity(
      id: 4,
      date: '20250702',
      price: 2000,
      paymentCategoryId: 11,
      memo: '宅配ミール',
      fixedCostId: 10,
      isConfirmed: 1,
    ),
  ];

  // カード上部のサマリー（大カテゴリー合計＝35,000）
  const categoryAccountings = [
    CategoryAccountingEntity(
      id: 1,
      categoryColor: 'FFAA00',
      bigCategoryName: '食費',
      categoryIconPath: 'assets/images/icon_meal.svg',
      totalExpenseByBigCategory: 35000,
    ),
  ];

  // カード内の小カテゴリー内訳
  const smallCategoryTiles = {
    1: [
      SmallCategoryTileEntity(
        id: 10,
        smallCategoryName: '外食',
        totalExpenseBySmallCategory: 30000,
        recordCount: 2,
      ),
      SmallCategoryTileEntity(
        id: 11,
        smallCategoryName: '中食',
        totalExpenseBySmallCategory: 5000,
        recordCount: 1,
      ),
    ],
  };

  /// 大カテゴリー支出履歴ページ用のFake束を組み立てる
  ///
  /// [withRecords] をfalseにすると、その大カテゴリーの記録が1件も無い状態になる。
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
    budget: FakeBudgetRepository(
      initialRecords: const [
        BudgetEntity(
          id: 1,
          expenseBigCategoryId: 1,
          month: monthKey,
          price: 50000,
        ),
      ],
    ),
    categoryAccounting: FakeCategoryAccountingRepository(
      categories: withRecords ? categoryAccountings : const [],
    ),
    smallCategoryTile: FakeSmallCategoryTileRepository(
      tilesByBigCategoryId: withRecords ? smallCategoryTiles : const {},
    ),
  );

  /// 描画中に例外（RenderFlexオーバーフロー等）が1件も出ないことを確認する
  ///
  /// かつて `expanded_category_sum_tile.dart` の小カテゴリー行は幅を
  /// `screenWidth - 64` から 0.45/0.15/0.4 で按分しており、実際の行幅は
  /// それより2px狭いため iPhone14/15幅(390pt) では小カテゴリー1行につき
  /// 1件のオーバーフローが必ず出ていた。行の制約を按分基準にする修正が
  /// 入っているので、例外ゼロを回帰検知に使う。
  void expectNoRenderErrors(List<FlutterErrorDetails> errors) {
    expect(
      errors.map((error) => error.exceptionAsString()),
      isEmpty,
      reason: '小カテゴリー行が溢れて例外を出してはいけない',
    );
  }

  /// FlutterErrorを1件ずつ回収しながら [body] を実行する
  ///
  /// 小カテゴリーが複数あると1フレームに複数の例外が出るため、
  /// `tester.takeException()` は「Multiple exceptions」の要約に化けて
  /// 中身が検証できない。FlutterError.onError を差し替えて個別に受け取る。
  Future<List<FlutterErrorDetails>> collectingErrors(
    Future<void> Function() body,
  ) async {
    final collected = <FlutterErrorDetails>[];
    final previousOnError = FlutterError.onError;
    FlutterError.onError = collected.add;
    try {
      await body();
    } finally {
      FlutterError.onError = previousOnError;
    }
    return collected;
  }

  /// ページをpumpし、その間に出た例外を回収して返す
  Future<List<FlutterErrorDetails>> pumpHistoryPage(
    WidgetTester tester,
    TestFakes fakes,
  ) async {
    return collectingErrors(() async {
      await pumpApp(
        tester,
        home: const CategoryExpenseHistoryPage(bigId: 1),
        fakes: fakes,
      );
      await pumpTimes(tester);
    });
  }

  testWidgets('カテゴリーサマリーに支出合計と予算が出る', (tester) async {
    final errors = await pumpHistoryPage(tester, buildFakes());
    expectNoRenderErrors(errors);

    expect(find.text('カテゴリー別利用状況'), findsOneWidget); // AppBar
    // 大カテゴリー名はサマリーカードと支出タイル4件（固定費行を含む）の計5箇所に出る
    expect(find.text('食費'), findsNWidgets(5));
    expect(find.text('¥ 35,000'), findsOneWidget); // 大カテゴリー合計
    // 予算ラベルはRichText（「予算 」＋金額）
    expect(
      find.textContaining('予算 ¥ 50,000', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('小カテゴリーの内訳が名前・件数・金額で並ぶ', (tester) async {
    final errors = await pumpHistoryPage(tester, buildFakes());
    expectNoRenderErrors(errors);

    // 小カテゴリー名は内訳行と履歴タイルの両方に出る
    expect(find.text('外食'), findsWidgets);
    expect(find.text('中食'), findsWidgets);
    expect(find.text('2件'), findsOneWidget);
    expect(find.text('1件'), findsOneWidget);
    expect(find.text('¥ 30,000'), findsOneWidget);
    expect(find.text('¥ 5,000'), findsWidgets);
  });

  testWidgets('日付ごとに支出履歴が新しい順で並ぶ', (tester) async {
    final errors = await pumpHistoryPage(tester, buildFakes());
    expectNoRenderErrors(errors);

    // 日付ヘッダー（7/5 → 7/3 → 7/1 の降順）
    expect(find.text('2025年7月5日(土)'), findsOneWidget);
    expect(find.text('2025年7月3日(木)'), findsOneWidget);
    expect(find.text('2025年7月1日(火)'), findsOneWidget);
    // 支出タイル（小カテゴリー名・メモは先頭スペース付きで描画される）
    expect(find.text(' ランチ'), findsOneWidget);
    expect(find.text(' ディナー'), findsOneWidget);
    expect(find.text(' スーパー'), findsOneWidget);
    expect(find.text('¥ 12,000'), findsOneWidget);
    expect(find.text('¥ 18,000'), findsOneWidget);
  });

  testWidgets('日付別明細の固定費行にだけ「固定費」チップが付く', (tester) async {
    final errors = await pumpHistoryPage(tester, buildFakes());
    expectNoRenderErrors(errors);

    // 固定費由来の1行だけにチップが出る
    expect(find.text('固定費'), findsOneWidget);
    expect(find.text(' 宅配ミール'), findsOneWidget);
    // 小カテゴリー一覧は固定費/変動費を区別しない（内訳行も追加しない）
    expect(find.text('外食'), findsOneWidget);
    expect(find.text('中食'), findsOneWidget);
    expect(find.text('変動費'), findsNothing);
  });

  testWidgets('小カテゴリー行のタップで小カテゴリー展開ページへ遷移する', (tester) async {
    final errors = await pumpHistoryPage(tester, buildFakes());
    expectNoRenderErrors(errors);

    // 内訳行の「中食」（カード内の先頭側）をタップする
    final afterTap = await collectingErrors(() async {
      await tester.tap(find.text('中食').first);
      await pumpTimes(tester);
    });
    expectNoRenderErrors(afterTap);

    // 遷移先は小カテゴリー1件分の履歴だけになる
    expect(find.text('カテゴリー別利用状況'), findsOneWidget);
    expect(find.text(' スーパー'), findsOneWidget);
    expect(find.text(' ランチ'), findsNothing);
  });

  testWidgets('支出タイルのタップで編集モーダルが開く', (tester) async {
    final errors = await pumpHistoryPage(tester, buildFakes());
    expectNoRenderErrors(errors);

    final afterTap = await collectingErrors(() async {
      await tester.tap(find.text(' ランチ'));
      await pumpTimes(tester);
    });
    expectNoRenderErrors(afterTap);

    expect(find.byType(RegisaterPageBase), findsOneWidget);
    expect(find.text('編集'), findsOneWidget);
    expect(find.text('12,000'), findsWidgets); // 元の支出金額

    await unmountRegisterPage(tester);
  });

  testWidgets('記録が1件も無いときは記録なしメッセージになる', (tester) async {
    final errors = await pumpHistoryPage(
      tester,
      buildFakes(withRecords: false),
    );
    expectNoRenderErrors(errors);

    expect(find.text('記録がまだありません'), findsOneWidget);
  });
}
