// 全カテゴリーの一覧（lib/view/category_list_page/）のWidget結合テスト
//
// 記録モーダルの「すべて」から開く選択モードと、記録画面のカテゴリーから開く追加モードで、
// カテゴリー設定と同じ listTile の2段構成（大 → 小）で並び、タップで小カテゴリーが返るかを見る（KP-032）。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/domain/core/category_entity/i_category_entity.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/view/category_list_page/category_big_list_page.dart';
import 'package:kakeibo/view/category_list_page/category_small_list_page.dart';
import 'package:kakeibo/view/component/category_list_tile.dart';
import 'package:kakeibo/view/component/modal.dart';

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
    ExpenseBigCategoryEntity(
      id: 2,
      colorCode: '00AAFF',
      bigCategoryName: '交通費',
      resourcePath: 'assets/images/icon_transportation.svg',
      displayOrder: 2,
      isDisplayed: 1,
    ),
  ];

  // 大カテゴリー内の並びは displayedOrderInBig（外食 → 食費）。
  // Fake は records の順で返すため、本物の SQL（displayed_order_in_big 昇順）と同じ並びで置く
  const expenseSmallCategories = [
    ExpenseSmallCategoryEntity(
      id: 11,
      smallCategoryOrderKey: 2,
      bigCategoryKey: 1,
      displayedOrderInBig: 1,
      smallCategoryName: '外食',
      defaultDisplayed: 0,
    ),
    ExpenseSmallCategoryEntity(
      id: 10,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 1,
      displayedOrderInBig: 2,
      smallCategoryName: '食費',
      defaultDisplayed: 1,
    ),
    ExpenseSmallCategoryEntity(
      id: 20,
      smallCategoryOrderKey: 3,
      bigCategoryKey: 2,
      displayedOrderInBig: 1,
      smallCategoryName: '電車',
      defaultDisplayed: 1,
    ),
  ];

  const incomeBigCategories = [
    IncomeBigCategoryEntity(
      id: 1,
      name: '月次収入',
      colorCode: '0000FF',
      iconPath: 'assets/images/icon_regular_income.svg',
    ),
  ];

  const incomeSmallCategories = [
    IncomeSmallCategoryEntity(
      id: 1,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 1,
      displayedOrderInBig: 1,
      smallCategoryName: '給与',
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
    incomeSmallCategory: FakeIncomeSmallCategoryRepository(
      initialRecords: incomeSmallCategories,
    ),
    incomeBigCategory: FakeIncomeBigCategoryRepository(
      initialRecords: incomeBigCategories,
    ),
  );

  /// モーダルとして一覧を開くための土台画面
  ///
  /// 実際の呼び出し元（記録モーダル・記録画面のカテゴリー）と同じく
  /// root の Navigator に積み、閉じたときの結果を [onResult] で受け取る。
  Widget launcher({
    required CategoryListMode mode,
    TransactionMode transactionMode = TransactionMode.expense,
    int? selectedCategoryId,
    Set<int> displayedIds = const {},
    required void Function(ICategoryEntity?) onResult,
  }) {
    return Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () async {
              final result = await showAppModalBottomSheet<ICategoryEntity>(
                context,
                child: CategoryBigListPage(
                  transactionMode: transactionMode,
                  mode: mode,
                  selectedCategoryId: selectedCategoryId,
                  displayedIds: displayedIds,
                ),
              );
              onResult(result);
            },
            child: const Text('開く'),
          ),
        ),
      ),
    );
  }

  group('選択モード（記録モーダルの「すべて」）', () {
    testWidgets('大カテゴリー一覧はカテゴリー設定と同じ行で、小カテゴリー一覧は大のアイコンを継承する', (tester) async {
      ICategoryEntity? result;
      await pumpApp(
        tester,
        home: launcher(
          mode: CategoryListMode.select,
          selectedCategoryId: 10,
          onResult: (r) => result = r,
        ),
        fakes: buildFakes(),
      );
      await tester.tap(find.text('開く'));
      await pumpTimes(tester);

      // 画面1: 凡例行と大カテゴリー行（名前＋小カテゴリー名のカンマ列挙＋「＞」）
      expect(find.text('すべてのカテゴリー'), findsOneWidget);
      expect(find.text('カテゴリー'), findsOneWidget);
      expect(find.text('項目'), findsOneWidget);
      expect(find.text('詳細'), findsOneWidget);
      expect(find.byType(CategoryListTile), findsNWidgets(2));
      expect(find.text('生活費'), findsOneWidget);
      expect(find.text('外食,食費'), findsOneWidget);
      expect(find.text('交通費'), findsOneWidget);
      expect(find.byIcon(AppIcons.next), findsNWidgets(2));

      await tester.tap(find.text('生活費'));
      await pumpTimes(tester);

      // 画面2: 大カテゴリー名のタイトル・戻る・凡例「項目／選択」・大内表示順（外食 → 食費）
      expect(find.byType(CategorySmallListPage), findsOneWidget);
      expect(find.text('生活費'), findsOneWidget);
      expect(find.byIcon(AppIcons.back), findsOneWidget);
      expect(find.text('項目'), findsOneWidget);
      expect(find.text('選択'), findsOneWidget);
      expect(rowsInOrder(tester, ['外食', '食費']), ['外食', '食費']);
      // 行のアイコンは大カテゴリーのもの（2行とも同じアセット）
      expect(find.byType(CategoryListTile), findsNWidgets(2));
      // 選択中（食費）の行にチェック
      expect(find.byIcon(AppIcons.done), findsOneWidget);
      expect(
        tester.getCenter(find.byIcon(AppIcons.done)).dy,
        closeTo(tester.getCenter(find.text('食費')).dy, 1),
      );

      // 外食を選ぶと両画面が閉じ、結果として返る
      await tester.tap(find.text('外食'));
      await pumpTimes(tester);

      expect(find.byType(CategoryBigListPage), findsNothing);
      expect(find.byType(CategorySmallListPage), findsNothing);
      expect(result?.id, 11);
      expect(result?.categoryName, '外食');
    });

    testWidgets('画面2の戻るで画面1へ戻り、閉じるで何も選ばずに閉じる', (tester) async {
      var called = false;
      ICategoryEntity? result;
      await pumpApp(
        tester,
        home: launcher(
          mode: CategoryListMode.select,
          onResult: (r) {
            called = true;
            result = r;
          },
        ),
        fakes: buildFakes(),
      );
      await tester.tap(find.text('開く'));
      await pumpTimes(tester);
      await tester.tap(find.text('交通費'));
      await pumpTimes(tester);
      expect(find.text('電車'), findsOneWidget);

      await tester.tap(find.byIcon(AppIcons.back));
      await pumpTimes(tester);
      expect(find.byType(CategorySmallListPage), findsNothing);
      expect(find.text('すべてのカテゴリー'), findsOneWidget);

      await tester.tap(find.byIcon(AppIcons.close));
      await pumpTimes(tester);
      expect(find.byType(CategoryBigListPage), findsNothing);
      expect(called, isTrue);
      expect(result, isNull);
    });

    testWidgets('収入モードでは収入の大・小カテゴリーが並ぶ', (tester) async {
      ICategoryEntity? result;
      await pumpApp(
        tester,
        home: launcher(
          mode: CategoryListMode.select,
          transactionMode: TransactionMode.income,
          onResult: (r) => result = r,
        ),
        fakes: buildFakes(),
      );
      await tester.tap(find.text('開く'));
      await pumpTimes(tester);

      expect(find.text('月次収入'), findsOneWidget);
      expect(find.text('生活費'), findsNothing);

      await tester.tap(find.text('月次収入'));
      await pumpTimes(tester);
      await tester.tap(find.text('給与'));
      await pumpTimes(tester);

      expect(result?.categoryName, '給与');
    });
  });

  group('追加モード（記録画面のカテゴリー）', () {
    testWidgets('表示中の項目は薄く「表示中」でタップしても閉じず、表示していない項目だけ選べる', (tester) async {
      ICategoryEntity? result;
      await pumpApp(
        tester,
        home: launcher(
          mode: CategoryListMode.add,
          displayedIds: {10, 20},
          onResult: (r) => result = r,
        ),
        fakes: buildFakes(),
      );
      await tester.tap(find.text('開く'));
      await pumpTimes(tester);

      expect(find.text('記録画面に追加'), findsOneWidget);
      await tester.tap(find.text('生活費'));
      await pumpTimes(tester);

      expect(find.text('表示'), findsOneWidget); // 凡例
      expect(find.text('表示中'), findsOneWidget);
      expect(
        tester.getCenter(find.text('表示中')).dy,
        closeTo(tester.getCenter(find.text('食費')).dy, 1),
      );
      expect(find.byIcon(AppIcons.done), findsNothing);

      // 表示中の食費はタップしても閉じない
      await tester.tap(find.text('食費'));
      await pumpTimes(tester);
      expect(find.byType(CategorySmallListPage), findsOneWidget);
      expect(result, isNull);

      await tester.tap(find.text('外食'));
      await pumpTimes(tester);
      expect(find.byType(CategoryBigListPage), findsNothing);
      expect(result?.id, 11);
    });
  });
}
