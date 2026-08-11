// カテゴリー並び替えページ
// （lib/view/register_page/category_area/category_reorder_page.dart）
// のWidget結合テスト
//
// 記録モーダルの「アイコンを並べ替える」から開く画面。
// ドラッグ＆ドロップで並び順が入れ替わり、保存でリポジトリへ表示順が書かれるかを見る。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
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

  // 並び順は smallCategoryOrderKey 昇順（食費 → 日用品 → 交通）
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
  ];

  TestFakes buildFakes() => TestFakes(
    expenseSmallCategory: FakeExpenseSmallCategoryRepository(
      initialRecords: expenseSmallCategories,
    ),
    expenseBigCategory: FakeExpenseBigCategoryRepository(
      initialRecords: expenseBigCategories,
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

  testWidgets('カテゴリーが並び順どおりに一覧表示され保存ボタンは無効', (tester) async {
    await pumpApp(
      tester,
      home: const CategoryReorderPage(transactionMode: TransactionMode.expense),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    expect(find.text('アイコンの並び替え'), findsOneWidget); // AppBar
    expect(find.text('アイコンを長押しして並び替えができます'), findsOneWidget);
    expect(find.text('食費'), findsOneWidget);
    expect(find.text('日用品'), findsOneWidget);
    expect(find.text('交通'), findsOneWidget);

    // 未変更なので保存ボタンは押せない（onPressed が null）
    expect(find.text('保存'), findsOneWidget);
    expect(
      tester.widget<MainButton>(find.byType(MainButton)).onPressed,
      isNull,
    );
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
    expect(
      tester.widget<MainButton>(find.byType(MainButton)).onPressed,
      isNotNull,
    );

    await tester.tap(find.text('保存'));
    await pumpTimes(tester);

    // 表示順は0始まりのindexで全件書き直される
    final updated = {
      for (final e in fakes.expenseSmallCategory.updatedEntities)
        e.id: e.smallCategoryOrderKey,
    };
    expect(updated, {11: 0, 10: 1, 12: 2});
  });
}
