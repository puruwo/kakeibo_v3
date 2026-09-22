// 記録画面のカテゴリー（旧・カテゴリー並び替えページ）
// （lib/view/register_page/category_area/category_reorder_page.dart）
// のWidget結合テスト
//
// 記録モーダルの「並べ替え」から開く画面。
// ドラッグ＆ドロップで並び順が入れ替わり、「−」で外し、「＋ 追加」で全カテゴリーの一覧から
// 加え、保存でリポジトリへ表示順と表示フラグが書かれるかを見る（KP-032）。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view/category_list_page/category_big_list_page.dart';
import 'package:kakeibo/view/category_list_page/category_small_list_page.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/register_page/category_area/category_reorder_page.dart';

import '../helper/fake_repositories.dart';
import '../helper/widget_test_helper.dart';

void main() {
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

  // 並び順は smallCategoryOrderKey 昇順（食費 → 日用品 → 交通）。
  // 「娯楽」は記録画面に出していない（default_displayed = 0）
  const expenseSmallCategories = [
    ExpenseSmallCategoryEntity(
      id: 10,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 1,
      displayedOrderInBig: 1,
      smallCategoryName: '食費',
      defaultDisplayed: 1,
    ),
    ExpenseSmallCategoryEntity(
      id: 11,
      smallCategoryOrderKey: 2,
      bigCategoryKey: 1,
      displayedOrderInBig: 2,
      smallCategoryName: '日用品',
      defaultDisplayed: 1,
    ),
    ExpenseSmallCategoryEntity(
      id: 12,
      smallCategoryOrderKey: 3,
      bigCategoryKey: 1,
      displayedOrderInBig: 3,
      smallCategoryName: '交通',
      defaultDisplayed: 1,
    ),
    ExpenseSmallCategoryEntity(
      id: 13,
      smallCategoryOrderKey: 4,
      bigCategoryKey: 1,
      displayedOrderInBig: 4,
      smallCategoryName: '娯楽',
      defaultDisplayed: 0,
    ),
  ];

  TestFakes buildFakes({
    List<ExpenseSmallCategoryEntity> smalls = expenseSmallCategories,
  }) => TestFakes(
    expenseSmallCategory: FakeExpenseSmallCategoryRepository(
      initialRecords: smalls,
    ),
    expenseBigCategory: FakeExpenseBigCategoryRepository(
      initialRecords: expenseBigCategories,
    ),
  );

  /// 記録画面に出している小カテゴリーを [count] 件作る
  List<ExpenseSmallCategoryEntity> manyDisplayed(int count) => List.generate(
    count,
    (i) => ExpenseSmallCategoryEntity(
      id: 100 + i,
      smallCategoryOrderKey: i,
      bigCategoryKey: 1,
      displayedOrderInBig: i,
      smallCategoryName: 'カテゴリー${i + 1}',
      defaultDisplayed: 1,
    ),
  );

  /// [from] のアイコンを長押しして [to] の位置へドラッグする
  Future<void> dragCategory(
    WidgetTester tester, {
    required String from,
    required String to,
  }) async {
    final gesture = await tester.startGesture(
      tester.getCenter(find.text(from)),
    );
    // LongPressDraggable のドラッグ開始判定（長押し500ms）を通すため時間を進める
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveTo(tester.getCenter(find.text(to)));
    await tester.pump();
    await gesture.up();
    await pumpTimes(tester, times: 5);
  }

  /// 保存ボタン（画面下部の MainButton）
  MainButton saveButton(WidgetTester tester) =>
      tester.widget<MainButton>(find.byType(MainButton));

  /// リポジトリの現在の値を id → (表示順, 表示フラグ) で返す
  Map<int, (int, int)> gridState(TestFakes fakes) => {
    for (final e in fakes.expenseSmallCategory.records)
      e.id: (e.smallCategoryOrderKey, e.defaultDisplayed),
  };

  testWidgets('表示中のカテゴリーが並び順どおりに出て、見出しに件数・末尾に「＋ 追加」が出る', (tester) async {
    await pumpApp(
      tester,
      home: const CategoryReorderPage(transactionMode: TransactionMode.expense),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    expect(find.text('記録画面のカテゴリー'), findsOneWidget); // AppBar
    expect(find.text('記録画面に表示'), findsOneWidget);
    expect(find.text('3／29'), findsOneWidget);
    expect(find.text('長押しして並び替え'), findsOneWidget);
    expect(find.text('食費'), findsOneWidget);
    expect(find.text('日用品'), findsOneWidget);
    expect(find.text('交通'), findsOneWidget);
    // 記録画面に出していないカテゴリーはグリッドに無い
    expect(find.text('娯楽'), findsNothing);
    // 末尾の「＋ 追加」セルと、下の「記録画面に追加」リンク・「カテゴリーを設定」リンク
    expect(find.text('追加'), findsOneWidget);
    expect(
      tester.getCenter(find.text('追加')).dx,
      greaterThan(tester.getCenter(find.text('交通')).dx),
    );
    expect(find.text('記録画面に追加'), findsOneWidget);
    expect(find.text('カテゴリーを設定'), findsOneWidget);
    // 各セルに「−」が付く（3件）
    expect(find.byIcon(AppIcons.deleteRow), findsNWidgets(3));

    // 未変更なので保存ボタンは押せない（onPressed が null）
    expect(find.text('保存'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNull);
  });

  testWidgets('並び替えを保存しないままカテゴリー設定を開いて戻っても、並び順は保持される', (tester) async {
    // KP-027: リンクからカテゴリー設定を開く。設定側で何も変えなければ
    // 未保存の並び順は残り、保存ボタンも活性のまま（KP-032 で文言を「カテゴリーを設定」に）
    await pumpApp(
      tester,
      home: const CategoryReorderPage(transactionMode: TransactionMode.expense),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await dragCategory(tester, from: '食費', to: '交通');
    expect(saveButton(tester).onPressed, isNotNull);

    await tester.tap(find.text('カテゴリーを設定'));
    await pumpTimes(tester);
    expect(find.byType(CategorySettingPage), findsOneWidget);
    expect(
      tester
          .widget<CategorySettingPage>(find.byType(CategorySettingPage))
          .initialCategoryType,
      CategoryType.expense,
    );

    // 左上の閉じるで並び替え画面へ戻る
    await tester.tap(find.byIcon(AppIcons.close).last);
    await pumpTimes(tester);

    expect(find.byType(CategorySettingPage), findsNothing);
    expect(saveButton(tester).onPressed, isNotNull);
  });

  testWidgets('ドラッグで並び替えて保存すると新しい表示順がupdateされる', (tester) async {
    final fakes = buildFakes();
    await pumpApp(
      tester,
      home: const CategoryReorderPage(transactionMode: TransactionMode.expense),
      fakes: fakes,
    );
    await pumpTimes(tester);

    // 先頭の食費を日用品の位置へ動かす → [日用品, 食費, 交通]
    await dragCategory(tester, from: '食費', to: '日用品');

    // 変更が入ったので保存ボタンが有効になる
    expect(saveButton(tester).onPressed, isNotNull);

    await tester.tap(find.text('保存'));
    await pumpTimes(tester);

    // 表示順は0始まりのindexで書き直され、外していない娯楽は表示中の後ろで非表示のまま
    expect(gridState(fakes), {11: (0, 1), 10: (1, 1), 12: (2, 1), 13: (3, 0)});
  });

  testWidgets('「−」で外すとグリッドから消え、保存で非表示（0）になる', (tester) async {
    final fakes = buildFakes();
    await pumpApp(
      tester,
      home: const CategoryReorderPage(transactionMode: TransactionMode.expense),
      fakes: fakes,
    );
    await pumpTimes(tester);

    // 日用品のセルの「−」（セルの右上＝ラベルより右上にあるもの）
    final removeBadges = find.byIcon(AppIcons.deleteRow);
    final labelCenter = tester.getCenter(find.text('日用品'));
    final target = removeBadges.evaluate().firstWhere((e) {
      final center = tester.getCenter(find.byWidget(e.widget));
      return (center.dx - labelCenter.dx).abs() < 40 &&
          center.dy < labelCenter.dy;
    });
    await tester.tap(find.byWidget(target.widget));
    await pumpTimes(tester);

    expect(find.text('日用品'), findsNothing);
    expect(find.text('2／29'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNotNull);

    await tester.tap(find.text('保存'));
    await pumpTimes(tester);

    expect(gridState(fakes), {10: (0, 1), 12: (1, 1), 11: (2, 0), 13: (3, 0)});
  });

  testWidgets('表示中が1件のときは「−」が非活性で外せない', (tester) async {
    await pumpApp(
      tester,
      home: const CategoryReorderPage(transactionMode: TransactionMode.expense),
      fakes: buildFakes(smalls: [expenseSmallCategories[0]]),
    );
    await pumpTimes(tester);

    expect(find.text('1／29'), findsOneWidget);
    final badge = tester.widget<Icon>(find.byIcon(AppIcons.deleteRow));
    expect(badge.color, AppColors.light.textTertiary);

    await tester.tap(find.byIcon(AppIcons.deleteRow));
    await pumpTimes(tester);

    expect(find.text('食費'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNull);
  });

  testWidgets('「＋ 追加」から全カテゴリーの一覧を開いて選ぶと末尾に加わり、保存で表示（1）になる', (tester) async {
    final fakes = buildFakes();
    await pumpApp(
      tester,
      home: const CategoryReorderPage(transactionMode: TransactionMode.expense),
      fakes: fakes,
    );
    await pumpTimes(tester);

    await tester.tap(find.text('追加'));
    await pumpTimes(tester);

    // 画面1: 大カテゴリー一覧（追加モードのタイトル）
    expect(find.byType(CategoryBigListPage), findsOneWidget);
    expect(find.text('記録画面に追加'), findsOneWidget);
    expect(find.text('生活費'), findsOneWidget);

    await tester.tap(find.text('生活費'));
    await pumpTimes(tester);

    // 画面2: 小カテゴリー一覧。表示中の項目は「表示中」でタップできない
    expect(find.byType(CategorySmallListPage), findsOneWidget);
    expect(find.text('表示中'), findsNWidgets(3));
    await tester.tap(find.text('食費'));
    await pumpTimes(tester);
    expect(find.byType(CategorySmallListPage), findsOneWidget);

    await tester.tap(find.text('娯楽'));
    await pumpTimes(tester);

    // 一覧が両方閉じ、末尾に娯楽が加わる
    expect(find.byType(CategoryBigListPage), findsNothing);
    expect(find.text('記録画面のカテゴリー'), findsOneWidget);
    expect(find.text('娯楽'), findsOneWidget);
    expect(find.text('4／29'), findsOneWidget);
    expect(
      tester.getCenter(find.text('娯楽')).dx,
      greaterThan(tester.getCenter(find.text('交通')).dx),
    );
    expect(saveButton(tester).onPressed, isNotNull);

    await tester.tap(find.text('保存'));
    await pumpTimes(tester);

    expect(gridState(fakes), {10: (0, 1), 11: (1, 1), 12: (2, 1), 13: (3, 1)});
  });

  testWidgets('「記録画面に追加」のリンクからも一覧が開く', (tester) async {
    await pumpApp(
      tester,
      home: const CategoryReorderPage(transactionMode: TransactionMode.expense),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('記録画面に追加'));
    await pumpTimes(tester);

    expect(find.byType(CategoryBigListPage), findsOneWidget);
  });

  testWidgets('29件で上限に達すると「＋ 追加」が出ず、リンクは非活性で注意文が出る', (tester) async {
    await pumpApp(
      tester,
      home: const CategoryReorderPage(transactionMode: TransactionMode.expense),
      fakes: buildFakes(smalls: manyDisplayed(29)),
    );
    await pumpTimes(tester);

    expect(find.text('29／29'), findsOneWidget);
    expect(find.text('表示できるのは 29 件までです。外してから追加してください'), findsOneWidget);
    expect(find.text('長押しして並び替え'), findsNothing);
    expect(find.text('追加'), findsNothing);

    // リンクは非活性（押しても一覧は開かない）
    await tester.tap(find.text('記録画面に追加'));
    await pumpTimes(tester);
    expect(find.byType(CategoryBigListPage), findsNothing);
  });
}
