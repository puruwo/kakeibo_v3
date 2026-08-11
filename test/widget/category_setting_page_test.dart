// カテゴリー設定画面（lib/view/category_edit_page/category_setting_page.dart）
// のWidget結合テスト
//
// 一般（支出）・固定費・収入の3タブの切り替えと、各タブの一覧表示、
// 詳細編集ページへの導線を見る。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';

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
      id: 20,
      smallCategoryOrderKey: 3,
      bigCategoryKey: 2,
      displayedOrderInBig: 1,
      smallCategoryName: '電車',
      defaultDisplayed: 1,
    ),
  ];

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

  const incomeBigCategories = [
    IncomeBigCategoryEntity(
      id: 1,
      name: '月次収入',
      colorCode: '0000FF',
      iconPath: 'assets/images/icon_regular_income.svg',
    ),
    IncomeBigCategoryEntity(
      id: 2,
      name: 'ボーナス',
      colorCode: '00FF00',
      iconPath: 'assets/images/icon_extra_income.svg',
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
    IncomeSmallCategoryEntity(
      id: 2,
      smallCategoryOrderKey: 2,
      bigCategoryKey: 2,
      displayedOrderInBig: 1,
      smallCategoryName: '賞与',
      defaultDisplayed: 1,
    ),
  ];

  TestFakes buildFakes() => TestFakes(
    expenseBigCategory: FakeExpenseBigCategoryRepository(
      initialRecords: expenseBigCategories,
    ),
    expenseSmallCategory: FakeExpenseSmallCategoryRepository(
      initialRecords: expenseSmallCategories,
    ),
    fixedCostCategory: FakeFixedCostCategoryRepository(
      initialRecords: fixedCostCategories,
    ),
    incomeBigCategory: FakeIncomeBigCategoryRepository(
      initialRecords: incomeBigCategories,
    ),
    incomeSmallCategory: FakeIncomeSmallCategoryRepository(
      initialRecords: incomeSmallCategories,
    ),
  );

  testWidgets('初期表示は一般タブで支出大カテゴリーが小カテゴリー付きで並ぶ', (tester) async {
    await pumpApp(
      tester,
      home: const CategorySettingPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    expect(find.text('カテゴリー設定'), findsOneWidget); // AppBar
    // タブは3つ
    expect(find.text('一般'), findsOneWidget);
    expect(find.text('固定費'), findsOneWidget);
    expect(find.text('収入'), findsOneWidget);

    // 一覧の凡例
    expect(find.text('カテゴリー'), findsOneWidget);
    expect(find.text('項目'), findsOneWidget);
    expect(find.text('詳細'), findsOneWidget);

    expect(find.text('生活費'), findsOneWidget);
    expect(find.text('交通費'), findsOneWidget);
    // 小カテゴリー名はカンマ区切りでまとめて出る
    expect(find.text('食費,日用品'), findsOneWidget);
    expect(find.text('電車'), findsOneWidget);
    expect(find.text('+ 新しいカテゴリーを追加'), findsOneWidget);
  });

  testWidgets('固定費タブに切り替えると固定費カテゴリーが並ぶ', (tester) async {
    await pumpApp(
      tester,
      home: const CategorySettingPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    // 切り替え前は固定費カテゴリーが見えない
    expect(find.text('住居'), findsNothing);

    await tester.tap(find.text('固定費'));
    await pumpTimes(tester);

    expect(find.text('住居'), findsOneWidget);
    expect(find.text('光熱費'), findsOneWidget);
    // 一般タブの内容は消える
    expect(find.text('生活費'), findsNothing);
  });

  testWidgets('収入タブに切り替えると収入カテゴリーが並びフッターが出ない', (tester) async {
    await pumpApp(
      tester,
      home: const CategorySettingPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    // 一般タブでは並び替えフッターが出る
    expect(find.text('表示・並び替え'), findsOneWidget);

    await tester.tap(find.text('収入'));
    await pumpTimes(tester);

    expect(find.text('月次収入'), findsOneWidget);
    expect(find.text('ボーナス'), findsOneWidget);
    expect(find.text('給与'), findsOneWidget);
    // 収入タブは並び替え・表示ON/OFFを持たないためフッターが無い
    expect(find.text('表示・並び替え'), findsNothing);
  });

  testWidgets('カテゴリー行のタップで詳細編集ページへ遷移する', (tester) async {
    await pumpApp(
      tester,
      home: const CategorySettingPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('生活費'));
    await pumpTimes(tester);

    expect(find.text('カテゴリーの設定'), findsOneWidget); // 遷移先のAppBar
    // 選択した大カテゴリーの小カテゴリーが編集対象として並ぶ
    expect(find.text('食費'), findsOneWidget);
    expect(find.text('日用品'), findsOneWidget);
    expect(find.text('+ 新しい項目を追加'), findsOneWidget);
  });

  testWidgets('「+ 新しいカテゴリーを追加」で新規作成モードの詳細編集へ遷移する', (tester) async {
    await pumpApp(
      tester,
      home: const CategorySettingPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('+ 新しいカテゴリーを追加'));
    await pumpTimes(tester);

    expect(find.text('カテゴリーの設定'), findsOneWidget);
    // 新規作成なので既存の小カテゴリーは1件も引き継がれない
    expect(find.text('食費'), findsNothing);
    expect(find.text('カテゴリー名を入力'), findsOneWidget); // 空の名前入力欄のヒント
  });

  testWidgets('「表示・並び替え」で並び替え編集モードのフッターに変わる', (tester) async {
    await pumpApp(
      tester,
      home: const CategorySettingPage(),
      fakes: buildFakes(),
    );
    await pumpTimes(tester);

    await tester.tap(find.text('表示・並び替え'));
    await pumpTimes(tester);

    expect(find.text('編集をキャンセル'), findsOneWidget);
    expect(find.text('編集を完了'), findsOneWidget);
    expect(find.text('表示・並び替え'), findsNothing);
  });
}
