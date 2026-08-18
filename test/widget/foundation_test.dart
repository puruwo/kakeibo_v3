// アプリの土台（lib/view/foundation.dart）のWidget結合テスト
//
// グローバルナビゲーションとタブ切替、起動時処理（バッチ・記録モーダル）を確認する。
// 各タブの中身は個別のテストファイル（year_page_test / monthly_page_test /
// expense_history_page_test）で見るため、ここでは「入れ替わること」だけを見る。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/view/family_page/family_page.dart';
import 'package:kakeibo/view/foundation.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

import '../helper/fake_repositories.dart';
import '../helper/widget_test_helper.dart';

void main() {
  // 起動時に自動表示される記録モーダルがカテゴリーを引くため、最低限のマスタを積む
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

  TestFakes buildFakes({FakeBatchHistoryRepository? batchHistory}) => TestFakes(
    expenseSmallCategory: FakeExpenseSmallCategoryRepository(
      initialRecords: expenseSmallCategories,
    ),
    expenseBigCategory: FakeExpenseBigCategoryRepository(
      initialRecords: expenseBigCategories,
    ),
    batchHistory: batchHistory,
  );

  testWidgets('起動時に記録モーダルが自動表示される（現行の実挙動）', (tester) async {
    await pumpApp(tester, home: const Foundation(), fakes: buildFakes());
    await pumpTimes(tester);

    // foundation.dart の initState で _showExpenseEntrySheet を呼んでいるため、
    // 起動直後は記録モーダルが最前面に出ている
    expect(find.byType(RegisaterPageBase), findsOneWidget);
    expect(find.text('記録'), findsOneWidget);

    await unmountRegisterPage(tester);
  });

  testWidgets('グロナビに5つの項目（全体・月間分析・＋・家族・履歴）が並ぶ', (tester) async {
    await pumpApp(tester, home: const Foundation(), fakes: buildFakes());
    await pumpTimes(tester);
    await closeRegisterModal(tester);

    expect(find.text('全体'), findsOneWidget);
    expect(find.text('月間分析'), findsOneWidget);
    expect(find.text('家族'), findsOneWidget);
    expect(find.text('履歴'), findsOneWidget);

    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart_rounded), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget); // 中央の＋ボタン
    expect(find.byIcon(Icons.people_rounded), findsOneWidget);
    expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
  });

  testWidgets('タブをタップすると表示中の画面が入れ替わる', (tester) async {
    await pumpApp(tester, home: const Foundation(), fakes: buildFakes());
    await pumpTimes(tester);
    await closeRegisterModal(tester);

    // IndexedStackなので全タブがツリー上にはいる。表示中のindexで判定する
    IndexedStack currentStack() =>
        tester.widget<IndexedStack>(find.byType(IndexedStack));

    expect(currentStack().index, 0); // 起動時は「全体」

    await tester.tap(find.text('家族'));
    await pumpTimes(tester);
    expect(currentStack().index, 3);
    // 家族タブの中身（プレースホルダー画面）が見えている
    expect(find.text('準備中'), findsOneWidget);

    await tester.tap(find.text('履歴'));
    await pumpTimes(tester);
    expect(currentStack().index, 4);

    await tester.tap(find.text('全体'));
    await pumpTimes(tester);
    expect(currentStack().index, 0);
  });

  testWidgets('中央の＋ボタンで記録モーダルが起動する（タブindexは変わらない）', (tester) async {
    await pumpApp(tester, home: const Foundation(), fakes: buildFakes());
    await pumpTimes(tester);
    await closeRegisterModal(tester);

    expect(find.byType(RegisaterPageBase), findsNothing);

    await tester.tap(find.byIcon(Icons.add_rounded));
    // かつては1つ前のモーダルの dispose が LateInitializationError で中断され、
    // ConsumerStatefulElement の購読解除まで到達しないまま開き直すと
    // 破棄済みElementへ通知が飛んでアサーション（_ElementLifecycle.defunct）が出た。
    // dispose修正後は開き直しても非同期エラーが出ないことを担保する。
    final errors = await pumpCatchingZoneErrors(tester);
    expect(errors, isEmpty, reason: 'モーダルを開き直しても非同期エラーが出てはいけない');

    expect(find.byType(RegisaterPageBase), findsOneWidget);
    expect(find.text('記録'), findsOneWidget);
    // ＋は画面切替ではなくモーダル表示なので、IndexedStackのindexは0のまま
    // （モーダルの裏に隠れるのでskipOffstage: falseで探す）
    expect(
      tester
          .widget<IndexedStack>(find.byType(IndexedStack, skipOffstage: false))
          .index,
      0,
    );

    await unmountRegisterPage(tester);
  });

  testWidgets('未実行の期間があると起動時バッチが走りバッチ履歴が記録される', (tester) async {
    // 集計期間6/25〜7/24のうち、6/24までしかバッチ未実行の状態から始める
    final batchHistory = FakeBatchHistoryRepository(
      initialLatestDate: '20250624',
    );
    await pumpApp(
      tester,
      home: const Foundation(),
      fakes: buildFakes(batchHistory: batchHistory),
    );
    await pumpTimes(tester);
    await closeRegisterModal(tester);

    // 6/25〜7/24の1期間ぶんのバッチ履歴が積まれる
    expect(batchHistory.insertedEntities, hasLength(1));
    expect(batchHistory.insertedEntities.single.endDate, '20250724');
  });

  testWidgets('実行済みなら起動時バッチは走らない（スモーク）', (tester) async {
    // TestFakesの既定は「20250724まで実行済み」
    final fakes = buildFakes();
    await pumpApp(tester, home: const Foundation(), fakes: fakes);
    await pumpTimes(tester);
    await closeRegisterModal(tester);

    expect(fakes.batchHistory.insertedEntities, isEmpty);
    // 非表示タブの画面もIndexedStackで構築済み（クラッシュしていない）
    expect(find.byType(FamilyPage, skipOffstage: false), findsOneWidget);
  });
}
