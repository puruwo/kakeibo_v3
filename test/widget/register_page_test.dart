// 記録モーダル（lib/view/register_page/）のWidget結合テスト
//
// 本物の画面Widgetを描画し、「入力した内容がユースケース呼び出しに正しく渡るか」
// 「エラーが画面に見えるか」を検証する。金額バリデーションのロジック自体は
// expense_usecase_test / income_usecase_test（UT）で担保済みなので、
// ここでは画面経由で呼んだときの見え方だけを見る。
//
// 記録モーダルは単体でpumpできるため、Foundation経由ではなく直接pumpしている。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/view/component/app_inset_group.dart';
import 'package:kakeibo/view/register_page/category_area/icon_box/selected_icon_button.dart';
import 'package:kakeibo/view/register_page/expense_tab/expense_basic_group.dart';
import 'package:kakeibo/view/register_page/expense_tab/fixed_cost_register_group.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

import '../helper/fake_repositories.dart';
import '../helper/widget_test_helper.dart';

void main() {
  // 支出小カテゴリー（画面の並びは smallCategoryOrderKey 昇順 → 食費→日用品）
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

  const incomeBigCategories = [
    IncomeBigCategoryEntity(
      id: 1,
      name: '月次収入',
      colorCode: '00AAFF',
      iconPath: 'assets/images/icon_regular_income.svg',
    ),
  ];

  /// 記録モーダル用のFake束を組み立てる
  ///
  /// [withExpenseCategories] をfalseにすると支出小カテゴリーが0件になる
  /// （カテゴリー未登録の初期状態を再現する）。
  TestFakes buildFakes({bool withExpenseCategories = true}) => TestFakes(
    expenseSmallCategory: FakeExpenseSmallCategoryRepository(
      initialRecords: withExpenseCategories ? expenseSmallCategories : const [],
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

  /// 金額入力欄（画面上いちばん最初のTextFormField）
  Finder priceField() => find.byType(TextFormField).at(0);

  /// メモ入力欄（金額の次のTextFormField）
  Finder memoField() => find.byType(TextFormField).at(1);

  group('支出の記録', () {
    testWidgets('初期表示にピル・金額欄・拠出元・カテゴリーグリッドが並ぶ', (tester) async {
      await pumpApp(
        tester,
        home: const RegisaterPageBase.addExpense(
          transactionMode: TransactionMode.expense,
        ),
        fakes: buildFakes(),
      );
      await pumpTimes(tester);

      expect(find.text('記録'), findsOneWidget);
      expect(find.text('支出'), findsOneWidget); // 取引種別ピル
      expect(find.text('¥'), findsOneWidget);
      expect(find.text('拠出元'), findsOneWidget);
      expect(find.text('生活収支'), findsOneWidget); // 拠出元の既定値
      expect(find.text('メモ'), findsOneWidget);
      // システム日時は2025/7/6固定なので日付ピルは「7/6」
      expect(find.text('7/6'), findsOneWidget);
      // カテゴリーグリッド（カテゴリー2件）
      expect(find.text('食費'), findsOneWidget);
      expect(find.text('日用品'), findsOneWidget);
      expect(find.text('アイコンを並べ替える'), findsOneWidget);
      expect(find.text('追加'), findsOneWidget);

      await unmountRegisterPage(tester);
    });

    testWidgets('金額とメモの入力が画面に反映される', (tester) async {
      await pumpApp(
        tester,
        home: const RegisaterPageBase.addExpense(
          transactionMode: TransactionMode.expense,
        ),
        fakes: buildFakes(),
      );
      await pumpTimes(tester);

      await tester.enterText(priceField(), '1200');
      await tester.enterText(memoField(), '牛肉');
      await tester.pump();

      // 金額欄は3桁区切りのフォーマッタを通る
      expect(find.text('1,200'), findsOneWidget);
      expect(find.text('牛肉'), findsOneWidget);

      await unmountRegisterPage(tester);
    });

    testWidgets('カテゴリーをタップすると選択状態が入れ替わる', (tester) async {
      await pumpApp(
        tester,
        home: const RegisaterPageBase.addExpense(
          transactionMode: TransactionMode.expense,
        ),
        fakes: buildFakes(),
      );
      await pumpTimes(tester);

      // 初期選択は先頭カテゴリー（表示順1番の食費）
      expect(
        tester
            .widget<SelectedIconButton>(find.byType(SelectedIconButton))
            .categoryEntity
            .categoryName,
        '食費',
      );

      await tester.tap(find.text('日用品'));
      await tester.pump();

      expect(
        tester
            .widget<SelectedIconButton>(find.byType(SelectedIconButton))
            .categoryEntity
            .categoryName,
        '日用品',
      );

      await unmountRegisterPage(tester);
    });

    testWidgets('入力内容が支出リポジトリへそのままinsertされる', (tester) async {
      final fakes = buildFakes();
      await pumpApp(
        tester,
        home: const RegisaterPageBase.addExpense(
          transactionMode: TransactionMode.expense,
        ),
        fakes: fakes,
      );
      await pumpTimes(tester);

      await tester.enterText(priceField(), '1200');
      await tester.enterText(memoField(), '牛肉');
      await tester.tap(find.text('日用品')); // 小カテゴリーID=11
      await tester.pump();

      await tester.tap(find.text('追加'));
      await pumpTimes(tester);

      expect(fakes.expense.insertedEntities, hasLength(1));
      final inserted = fakes.expense.insertedEntities.single;
      expect(inserted.price, 1200);
      expect(inserted.memo, '牛肉');
      expect(inserted.paymentCategoryId, 11);
      // システム日時2025/7/6固定 → 日付の初期値もその日
      expect(inserted.date, '20250706');
      // 拠出元の既定値は給与（生活収支）
      expect(inserted.incomeSourceBigCategory, 1);

      await waitForSnackBarDismissed(tester);
      await unmountRegisterPage(tester);
    });

    testWidgets('拠出元を特別枠に変えるとinsert値に反映される', (tester) async {
      final fakes = buildFakes();
      await pumpApp(
        tester,
        home: const RegisaterPageBase.addExpense(
          transactionMode: TransactionMode.expense,
        ),
        fakes: fakes,
      );
      await pumpTimes(tester);

      await tester.enterText(priceField(), '5000');
      await tester.tap(find.text('生活収支')); // 拠出元ピルを開く
      await pumpTimes(tester, times: 5);
      await tester.tap(find.text('特別枠').last);
      await pumpTimes(tester, times: 5);

      await tester.tap(find.text('追加'));
      await pumpTimes(tester);

      expect(fakes.expense.insertedEntities, hasLength(1));
      // 特別枠の会計種別値=2
      expect(fakes.expense.insertedEntities.single.incomeSourceBigCategory, 2);

      await waitForSnackBarDismissed(tester);
      await unmountRegisterPage(tester);
    });

    testWidgets('日付ピッカーで日付を変えるとinsert値の日付が変わる', (tester) async {
      final fakes = buildFakes();
      await pumpApp(
        tester,
        home: const RegisaterPageBase.addExpense(
          transactionMode: TransactionMode.expense,
        ),
        fakes: fakes,
      );
      await pumpTimes(tester);

      await tester.enterText(priceField(), '800');
      await tester.tap(find.text('7/6')); // 日付ピルをタップ
      await pumpTimes(tester, times: 10);

      // カレンダーから同月の10日を選ぶ
      await tester.tap(find.text('10'));
      await pumpTimes(tester, times: 5);
      await tester.tap(find.text('OK'));
      await pumpTimes(tester, times: 10);

      expect(find.text('7/10'), findsOneWidget);

      await tester.tap(find.text('追加'));
      await pumpTimes(tester);

      expect(fakes.expense.insertedEntities.single.date, '20250710');

      await waitForSnackBarDismissed(tester);
      await unmountRegisterPage(tester);
    });

    testWidgets('0円のまま保存するとエラー文言のスナックバーが出てinsertされない', (tester) async {
      final fakes = buildFakes();
      await pumpApp(
        tester,
        home: const RegisaterPageBase.addExpense(
          transactionMode: TransactionMode.expense,
        ),
        fakes: fakes,
      );
      await pumpTimes(tester);

      await tester.tap(find.text('追加'));
      await pumpTimes(tester);

      expect(fakes.expense.insertedEntities, isEmpty);
      expect(find.text('0円以上で入力してください'), findsOneWidget);

      await waitForSnackBarDismissed(tester);
      await unmountRegisterPage(tester);
    });

    testWidgets('上限（1,888,888円）以上で保存するとエラー文言が出る', (tester) async {
      final fakes = buildFakes();
      await pumpApp(
        tester,
        home: const RegisaterPageBase.addExpense(
          transactionMode: TransactionMode.expense,
        ),
        fakes: fakes,
      );
      await pumpTimes(tester);

      // 支出の上限は 1888888（この値ちょうどでエラー）
      await tester.enterText(priceField(), '1888888');
      await tester.pump();
      await tester.tap(find.text('追加'));
      await pumpTimes(tester);

      expect(fakes.expense.insertedEntities, isEmpty);
      expect(find.text('金額の入力値が大き過ぎます'), findsOneWidget);

      await waitForSnackBarDismissed(tester);
      await unmountRegisterPage(tester);
    });

    testWidgets('上限の1円下（1,888,887円）なら保存できる', (tester) async {
      final fakes = buildFakes();
      await pumpApp(
        tester,
        home: const RegisaterPageBase.addExpense(
          transactionMode: TransactionMode.expense,
        ),
        fakes: fakes,
      );
      await pumpTimes(tester);

      await tester.enterText(priceField(), '1888887');
      await tester.pump();
      await tester.tap(find.text('追加'));
      await pumpTimes(tester);

      expect(fakes.expense.insertedEntities, hasLength(1));
      expect(fakes.expense.insertedEntities.single.price, 1888887);

      await waitForSnackBarDismissed(tester);
      await unmountRegisterPage(tester);
    });

    testWidgets('小カテゴリーが0件でもモーダルは開ける（初期選択で落ちない）', (tester) async {
      final fakes = buildFakes(withExpenseCategories: false);
      await pumpApp(
        tester,
        home: const RegisaterPageBase.addExpense(
          transactionMode: TransactionMode.expense,
        ),
        fakes: fakes,
      );
      // 初期選択カテゴリーの解決はpostFrameCallbackの非同期処理なので、
      // Zoneへ流れる例外まで拾って「1件も出ない」ことを見る
      final errors = await pumpCatchingZoneErrors(tester);
      expect(errors, isEmpty, reason: 'カテゴリー0件でも非同期エラーが出てはいけない');
      expect(tester.takeException(), isNull);

      // 画面自体は出て、カテゴリーグリッドだけが空になる
      expect(find.text('記録'), findsOneWidget);
      expect(find.byType(SelectedIconButton), findsNothing);
      expect(find.text('アイコンを並べ替える'), findsOneWidget);

      await unmountRegisterPage(tester);
    });

    testWidgets('小カテゴリー0件のまま保存するとカテゴリー未選択のエラーになる', (tester) async {
      final fakes = buildFakes(withExpenseCategories: false);
      await pumpApp(
        tester,
        home: const RegisaterPageBase.addExpense(
          transactionMode: TransactionMode.expense,
        ),
        fakes: fakes,
      );
      await pumpTimes(tester);

      // 金額は正しく入れて、カテゴリー未選択だけが引っかかる状態にする
      await tester.enterText(priceField(), '1200');
      await tester.pump();
      await tester.tap(find.text('追加'));
      await pumpTimes(tester);

      expect(fakes.expense.insertedEntities, isEmpty);
      expect(find.text('カテゴリーを選択してください'), findsOneWidget);

      await waitForSnackBarDismissed(tester);
      await unmountRegisterPage(tester);
    });
  });

  group('収入の記録', () {
    testWidgets('ピルから収入モードへ切り替えると収入用の画面になる', (tester) async {
      await pumpApp(
        tester,
        home: const RegisaterPageBase.addExpense(
          transactionMode: TransactionMode.expense,
        ),
        fakes: buildFakes(),
      );
      await pumpTimes(tester);

      // 支出モードでは拠出元行があり、収入カテゴリー（給与）は無い
      expect(find.text('拠出元'), findsOneWidget);
      expect(find.text('給与'), findsNothing);

      await tester.tap(find.text('支出')); // 取引種別ピルを開く
      await pumpTimes(tester, times: 5);
      await tester.tap(find.text('収入').last);
      await pumpTimes(tester, times: 10);

      // 収入モードでは拠出元行が消え、収入カテゴリーが並ぶ
      expect(find.text('拠出元'), findsNothing);
      expect(find.text('給与'), findsOneWidget);

      await unmountRegisterPage(tester);
    });

    testWidgets('日付・メモは支出と同じインセットグループで表示される', (tester) async {
      await pumpApp(
        tester,
        home: const RegisaterPageBase.addIncome(),
        fakes: buildFakes(),
      );
      await pumpTimes(tester);

      // 支出タブと同じ行構成（日付＝ナビ行／メモ＝テキストフィールド行。仕様 §6.9）
      expect(find.byType(AppInsetGroup), findsOneWidget);
      expect(find.text('日付'), findsOneWidget);
      expect(find.text('メモ'), findsOneWidget);
      // 収入に拠出元は無い
      expect(find.text('拠出元'), findsNothing);
      // 日付の初期値はシステム日時（基準シナリオ2025/7/6）
      expect(find.text('7/6'), findsOneWidget);

      await unmountRegisterPage(tester);
    });

    testWidgets('収入の保存で収入リポジトリへinsertされる', (tester) async {
      final fakes = buildFakes();
      await pumpApp(
        tester,
        home: const RegisaterPageBase.addIncome(),
        fakes: fakes,
      );
      await pumpTimes(tester);

      await tester.enterText(priceField(), '250000');
      await tester.enterText(memoField(), '7月給与');
      await tester.pump();
      await tester.tap(find.text('追加'));
      await pumpTimes(tester);

      expect(fakes.income.insertedEntities, hasLength(1));
      final inserted = fakes.income.insertedEntities.single;
      expect(inserted.price, 250000);
      expect(inserted.memo, '7月給与');
      expect(inserted.categoryId, 1); // 収入小カテゴリー「給与」
      expect(inserted.date, '20250706');
      // 支出側には書き込まれない
      expect(fakes.expense.insertedEntities, isEmpty);

      await waitForSnackBarDismissed(tester);
      await unmountRegisterPage(tester);
    });
  });

  group('編集モード', () {
    // 集計期間6/25〜7/24内の支出を編集対象にする（UTの基準シナリオに合わせる）
    const editTarget = ExpenseEntity(
      id: 42,
      date: '20250701',
      price: 3400,
      paymentCategoryId: 11,
      memo: '洗剤',
    );

    testWidgets('既存エンティティの値が初期表示される', (tester) async {
      await pumpApp(
        tester,
        home: const RegisaterPageBase.editExpense(expenseEntity: editTarget),
        fakes: buildFakes(),
      );
      await pumpTimes(tester);

      expect(find.text('編集'), findsOneWidget);
      expect(find.text('更新'), findsOneWidget);
      expect(find.text('3,400'), findsOneWidget);
      expect(find.text('洗剤'), findsOneWidget);
      expect(find.text('7/1'), findsOneWidget);
      // 初期選択カテゴリーは元エンティティの小カテゴリー（ID=11 日用品）
      expect(
        tester
            .widget<SelectedIconButton>(find.byType(SelectedIconButton))
            .categoryEntity
            .categoryName,
        '日用品',
      );

      await unmountRegisterPage(tester);
    });

    testWidgets('金額を変えて更新するとupdateが記録される', (tester) async {
      final fakes = buildFakes();
      await pumpApp(
        tester,
        home: const RegisaterPageBase.editExpense(expenseEntity: editTarget),
        fakes: fakes,
      );
      await pumpTimes(tester);

      await tester.enterText(priceField(), '5000');
      await tester.pump();
      await tester.tap(find.text('更新'));
      await pumpTimes(tester);

      expect(fakes.expense.updatedEntities, hasLength(1));
      final updated = fakes.expense.updatedEntities.single;
      expect(updated.id, 42); // 元エンティティのIDを引き継ぐ
      expect(updated.price, 5000);
      expect(updated.memo, '洗剤');
      expect(updated.date, '20250701');
      expect(fakes.expense.insertedEntities, isEmpty);

      await waitForSnackBarDismissed(tester);
      await unmountRegisterPage(tester);
    });

    testWidgets('何も変えずに更新すると「変更がありません」が表示される', (tester) async {
      final fakes = buildFakes();
      await pumpApp(
        tester,
        home: const RegisaterPageBase.editExpense(expenseEntity: editTarget),
        fakes: fakes,
      );
      await pumpTimes(tester);

      await tester.tap(find.text('更新'));
      await pumpTimes(tester);

      expect(fakes.expense.updatedEntities, isEmpty);
      expect(find.text('変更がありません'), findsOneWidget);

      await waitForSnackBarDismissed(tester);
      await unmountRegisterPage(tester);
    });

    testWidgets('削除ボタン→確認ダイアログOKでdeleteが記録される', (tester) async {
      final fakes = buildFakes();
      await pumpApp(
        tester,
        home: const RegisaterPageBase.editExpense(expenseEntity: editTarget),
        fakes: fakes,
      );
      await pumpTimes(tester);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await pumpTimes(tester, times: 5);

      expect(find.text('登録履歴の削除'), findsOneWidget);
      expect(find.text('削除したデータは戻せません。\n本当に削除しますか？'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await pumpTimes(tester, times: 10);

      expect(fakes.expense.deletedIds, [42]);

      await unmountRegisterPage(tester);
    });

    testWidgets('確認ダイアログをキャンセルすると削除されない', (tester) async {
      final fakes = buildFakes();
      await pumpApp(
        tester,
        home: const RegisaterPageBase.editExpense(expenseEntity: editTarget),
        fakes: fakes,
      );
      await pumpTimes(tester);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await pumpTimes(tester, times: 5);
      await tester.tap(find.text('キャンセル'));
      await pumpTimes(tester, times: 10);

      expect(fakes.expense.deletedIds, isEmpty);
      expect(find.text('登録履歴の削除'), findsNothing);

      await unmountRegisterPage(tester);
    });
  });

  group('固定費として登録（支出タブのトグル）', () {
    testWidgets('トグルOFFでは固定費の入力行が出ない', (tester) async {
      await pumpApp(
        tester,
        home: const RegisaterPageBase.addExpense(
          transactionMode: TransactionMode.expense,
        ),
        fakes: buildFakes(),
      );
      await pumpTimes(tester);

      // 基本グループは拠出元・日付・メモの3行
      expect(find.text('拠出元'), findsOneWidget);
      expect(find.text('日付'), findsOneWidget);
      expect(find.text('メモ'), findsOneWidget);
      // 固定費グループはトグルの1行だけ
      expect(find.text('固定費として登録'), findsOneWidget);
      expect(find.text('名称'), findsNothing);
      expect(find.text('初回支払日'), findsNothing);
      expect(find.text('頻度'), findsNothing);
      expect(find.text('支払い額が毎回変わる'), findsNothing);

      await unmountRegisterPage(tester);
    });

    testWidgets('トグルONで基本グループが縮み、メモと日付が固定費側へ引き継がれる', (tester) async {
      await pumpApp(
        tester,
        home: const RegisaterPageBase.addExpense(
          transactionMode: TransactionMode.expense,
        ),
        fakes: buildFakes(),
      );
      await pumpTimes(tester);

      await tester.enterText(memoField(), '電気代');
      await tester.pump();

      // 固定費グループのトグル（OFF時の画面で唯一のSwitch）
      await tester.tap(find.byType(Switch));
      await pumpTimes(tester);

      // 基本グループは拠出元のみに縮む（仕様 §6.1）
      expect(find.text('拠出元'), findsOneWidget);
      expect(find.text('日付'), findsNothing);
      expect(find.text('メモ'), findsNothing);
      // 固定費グループの4行が展開する
      expect(find.text('名称'), findsOneWidget);
      expect(find.text('初回支払日'), findsOneWidget);
      expect(find.text('頻度'), findsOneWidget);
      expect(find.text('支払い額が毎回変わる'), findsOneWidget);
      // メモは名称へ、日付（システム日時2025/7/6）は初回支払日へ引き継がれる
      expect(find.text('電気代'), findsOneWidget);
      expect(find.text('7/6'), findsOneWidget);

      await unmountRegisterPage(tester);
    });

    testWidgets('トグルの展開・収縮はアニメーションする', (tester) async {
      await pumpApp(
        tester,
        home: const RegisaterPageBase.addExpense(
          transactionMode: TransactionMode.expense,
        ),
        fakes: buildFakes(),
      );
      await pumpTimes(tester);

      // 高さの変化はAnimatedSizeで補間する（レイアウトジャンプ防止。仕様 §6.8）
      expect(
        find.descendant(
          of: find.byType(FixedCostRegisterGroup),
          matching: find.byType(AnimatedSize),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(ExpenseBasicGroup),
          matching: find.byType(AnimatedSize),
        ),
        findsOneWidget,
      );

      final collapsedHeight =
          tester.getSize(find.byType(FixedCostRegisterGroup)).height;

      await tester.tap(find.byType(Switch));
      // 1フレーム目はまだ展開前の高さのまま（一気に伸びない）
      await tester.pump();
      expect(
        tester.getSize(find.byType(FixedCostRegisterGroup)).height,
        collapsedHeight,
      );

      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(FixedCostRegisterGroup)).height,
        greaterThan(collapsedHeight),
      );

      await unmountRegisterPage(tester);
    });

    testWidgets('変動ONにすると金額表示が---になる', (tester) async {
      await pumpApp(
        tester,
        home: const RegisaterPageBase.addFixedCost(),
        fakes: buildFakes(),
      );
      await pumpTimes(tester);

      // 追加導線からはトグルON状態で開く（仕様 §6.3）
      expect(find.text('名称'), findsOneWidget);
      expect(find.text('---'), findsNothing);

      // 「支払い額が毎回変わる」はトグルON時の2つ目のSwitch
      await tester.tap(find.byType(Switch).last);
      await pumpTimes(tester);

      expect(find.text('---'), findsOneWidget);

      await unmountRegisterPage(tester);
    });

    testWidgets('トグルONで追加すると固定費マスタが小カテゴリーIDで登録される', (tester) async {
      final fakes = buildFakes();
      await pumpApp(
        tester,
        home: const RegisaterPageBase.addExpense(
          transactionMode: TransactionMode.expense,
        ),
        fakes: fakes,
      );
      await pumpTimes(tester);

      await tester.enterText(priceField(), '8000');
      await tester.enterText(memoField(), '電気代');
      await tester.tap(find.text('日用品')); // 小カテゴリーID=11
      await tester.pump();

      await tester.tap(find.byType(Switch));
      await pumpTimes(tester);

      await tester.tap(find.text('追加'));
      await pumpTimes(tester);

      expect(fakes.fixedCost.insertedEntities, hasLength(1));
      final inserted = fakes.fixedCost.insertedEntities.single;
      expect(inserted.name, '電気代');
      expect(inserted.price, 8000);
      expect(inserted.variable, 0);
      // カテゴリーは支出小カテゴリーID（仕様 §3）
      expect(inserted.expenseSmallCategoryId, 11);
      expect(inserted.firstPaymentDate, '20250706');

      // 初回支払いが当月内なので実績行も同時に生成される（既存のadd経路のまま）
      expect(fakes.expense.insertedEntities, hasLength(1));
      expect(fakes.expense.insertedEntities.single.fixedCostId, isNotNull);

      await waitForSnackBarDismissed(tester);
      await unmountRegisterPage(tester);
    });
  });

  group('既存支出の固定費化', () {
    // 集計期間6/25〜7/24内の通常支出を固定費化の対象にする
    const conversionTarget = ExpenseEntity(
      id: 42,
      date: '20250701',
      price: 3400,
      paymentCategoryId: 11,
      memo: 'Netflix',
    );

    testWidgets('編集シートの固定費トグルONで固定費化の入力行が出る', (tester) async {
      await pumpApp(
        tester,
        home: const RegisaterPageBase.editExpense(
          expenseEntity: conversionTarget,
        ),
        fakes: buildFakes(),
      );
      await pumpTimes(tester);

      // トグルOFFのときは固定費化の説明文を添える
      expect(
        find.text('ONにすると、この支出を初回の支払いとして固定費を作成します（頻度・名称を続けて入力）'),
        findsOneWidget,
      );

      await tester.tap(find.byType(Switch));
      await pumpTimes(tester);

      expect(find.text('名称'), findsOneWidget);
      // 名称はメモ、初回支払日は当該行の日付を引き継ぐ（仕様 §6.6）
      expect(find.text('Netflix'), findsOneWidget);
      expect(find.text('7/1'), findsOneWidget);

      await unmountRegisterPage(tester);
    });

    testWidgets('固定費トグルONで更新すると固定費マスタが作られ当該行に紐づく', (tester) async {
      final fakes = buildFakes();
      await pumpApp(
        tester,
        home: const RegisaterPageBase.editExpense(
          expenseEntity: conversionTarget,
        ),
        fakes: fakes,
      );
      await pumpTimes(tester);

      await tester.tap(find.byType(Switch));
      await pumpTimes(tester);

      await tester.tap(find.text('更新'));
      await pumpTimes(tester);

      // 固定費マスタが当該レコードの値で作られる
      expect(fakes.fixedCost.insertedEntities, hasLength(1));
      final master = fakes.fixedCost.insertedEntities.single;
      expect(master.name, 'Netflix');
      expect(master.price, 3400);
      expect(master.expenseSmallCategoryId, 11);
      expect(master.firstPaymentDate, '20250701');
      // 推定額は当該レコードの金額で初期化される（仕様 §6.5）
      expect(master.estimatedPrice, 3400);

      // 当該行に fixed_cost_id が付与される（遡及生成はしない）
      expect(fakes.expense.updatedEntities, hasLength(1));
      final updated = fakes.expense.updatedEntities.single;
      expect(updated.id, 42);
      expect(updated.fixedCostId, isNotNull);
      expect(updated.isConfirmed, 1);

      await waitForSnackBarDismissed(tester);
      await unmountRegisterPage(tester);
    });
  });
}
