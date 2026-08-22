// Widget結合テスト用の共通ヘルパー
//
// 本番の main.dart は ProviderScope.overrides で実装リポジトリを注入し、
// MaterialApp（ダークテーマ固定・textScaler 1.0）で画面を包んでいる。
// Widgetテストでも同じ構成を再現し、リポジトリだけを Fake に差し替える。
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_repository.dart';
import 'package:kakeibo/domain/core/daily_expense_entity/daily_expense_repository.dart';
import 'package:kakeibo/domain/db/batch_history/batch_history_repository.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_repository.dart';
import 'package:kakeibo/theme/app_colors.dart';

import 'fake_repositories.dart';
import 'test_container.dart';

/// UTと揃えた基準シナリオのシステム日時
///
/// 集計設定が既定（開始日25日・開始月4月）のとき、
/// この日を「今日」とすると集計期間は 2025/6/25〜2025/7/24 になる。
final DateTime kTestSystemDate = DateTime(2025, 7, 6);

/// テストで使う画面サイズ（iPhone 14 / 15 相当の論理サイズ）
const Size kTestScreenSize = Size(390, 844);

/// テストで使うデバイスピクセル比（iPhoneの実機相当）
const double kTestDevicePixelRatio = 3.0;

/// 本番 main.dart が override している全リポジトリのFake束
///
/// テストからはコンストラクタで必要なFakeだけ差し替え、
/// 残りは「空のFake」が入る。pumpApp の戻り値として受け取れば、
/// 書き込み記録（insertedEntities など）をそのまま検証できる。
///
/// 集計設定まわり（開始日・開始月・代表月/年の基準）は
/// [aggregationSettingOverrides] が別途Fakeを注入するためここには含めない。
class TestFakes {
  TestFakes({
    FakeCategoryAccountingRepository? categoryAccounting,
    FakeSmallCategoryTileRepository? smallCategoryTile,
    FakeDailyExpenseRepository? dailyExpense,
    FakeExpenseSmallCategoryRepository? expenseSmallCategory,
    FakeExpenseBigCategoryRepository? expenseBigCategory,
    FakeIncomeBigCategoryRepository? incomeBigCategory,
    FakeIncomeSmallCategoryRepository? incomeSmallCategory,
    FakeExpenseRepository? expense,
    FakeBudgetRepository? budget,
    FakeIncomeRepository? income,
    FakeFixedCostRepository? fixedCost,
    FakeBatchHistoryRepository? batchHistory,
    FakeFixedCostExpenseRepository? fixedCostExpense,
    FakeFixedCostCategoryRepository? fixedCostCategory,
  }) : categoryAccounting =
           categoryAccounting ?? FakeCategoryAccountingRepository(),
       smallCategoryTile =
           smallCategoryTile ?? FakeSmallCategoryTileRepository(),
       dailyExpense = dailyExpense ?? FakeDailyExpenseRepository(),
       expenseSmallCategory =
           expenseSmallCategory ?? FakeExpenseSmallCategoryRepository(),
       expenseBigCategory =
           expenseBigCategory ?? FakeExpenseBigCategoryRepository(),
       incomeBigCategory =
           incomeBigCategory ?? FakeIncomeBigCategoryRepository(),
       incomeSmallCategory =
           incomeSmallCategory ?? FakeIncomeSmallCategoryRepository(),
       expense = expense ?? FakeExpenseRepository(),
       budget = budget ?? FakeBudgetRepository(),
       income = income ?? FakeIncomeRepository(),
       fixedCost = fixedCost ?? FakeFixedCostRepository(),
       // バッチ未実行だと起動時バッチが走るため、既定は基準シナリオの
       // 集計期間終了日（20250724）にして「実行済み」の状態から始める
       batchHistory =
           batchHistory ??
           FakeBatchHistoryRepository(initialLatestDate: '20250724'),
       fixedCostExpense = fixedCostExpense ?? FakeFixedCostExpenseRepository(),
       fixedCostCategory =
           fixedCostCategory ?? FakeFixedCostCategoryRepository() {
    // 固定費マスタの削除・推定額の同期はexpenseの固定費行にも効く
    // （本物は同一トランザクションで両テーブルを更新する。仕様 §6.4・§6.5）
    this.fixedCost.expenseRepository ??= this.expense;
  }

  final FakeCategoryAccountingRepository categoryAccounting;
  final FakeSmallCategoryTileRepository smallCategoryTile;
  final FakeDailyExpenseRepository dailyExpense;
  final FakeExpenseSmallCategoryRepository expenseSmallCategory;
  final FakeExpenseBigCategoryRepository expenseBigCategory;
  final FakeIncomeBigCategoryRepository incomeBigCategory;
  final FakeIncomeSmallCategoryRepository incomeSmallCategory;
  final FakeExpenseRepository expense;
  final FakeBudgetRepository budget;
  final FakeIncomeRepository income;
  final FakeFixedCostRepository fixedCost;
  final FakeBatchHistoryRepository batchHistory;
  final FakeFixedCostExpenseRepository fixedCostExpense;
  final FakeFixedCostCategoryRepository fixedCostCategory;

  /// main.dart の ProviderScope.overrides と同じ並びのoverride列
  List<Override> get overrides => [
    categoryAccountingRepositoryProvider.overrideWithValue(categoryAccounting),
    smallCategoryTileRepositoryProvider.overrideWithValue(smallCategoryTile),
    dailyExpenseRepositoryProvider.overrideWithValue(dailyExpense),
    expenseSmallCategoryRepositoryProvider.overrideWithValue(
      expenseSmallCategory,
    ),
    expensebigCategoryRepositoryProvider.overrideWithValue(expenseBigCategory),
    incomeBigCategoryRepositoryProvider.overrideWithValue(incomeBigCategory),
    incomeSmallCategoryRepositoryProvider.overrideWithValue(
      incomeSmallCategory,
    ),
    expenseRepositoryProvider.overrideWithValue(expense),
    budgetRepositoryProvider.overrideWithValue(budget),
    incomeRepositoryProvider.overrideWithValue(income),
    fixedCostRepositoryProvider.overrideWithValue(fixedCost),
    batchHistoryRepositoryProvider.overrideWithValue(batchHistory),
    fixedCostExpenseRepositoryProvider.overrideWithValue(fixedCostExpense),
    fixedCostCategoryRepositoryProvider.overrideWithValue(fixedCostCategory),
  ];
}

/// アプリ同梱フォントをテストへ読み込む
///
/// 読み込まないとテスト用の等幅フォント（1文字＝1em）で計測されるため、
/// 実機では収まっている固定幅のピル等が偽のオーバーフローを起こす。
/// 本番と同じ noto_sans / sf_ui を読ませて文字幅を実機に近づける。
/// テストファイルは1ファイル＝1プロセスなので、初回だけ読み込めばよい。
bool _appFontsLoaded = false;

Future<void> loadAppFonts() async {
  if (_appFontsLoaded) return;
  _appFontsLoaded = true;

  // 実際に使われるウェイトのみ読み込む（全ウェイトを読むと起動が遅くなる）
  await _loadFontFamily('noto_sans', const [
    'assets/fonts/noto-sans-jp-light-300.ttf',
    'assets/fonts/noto-sans-jp-regular-400.ttf',
    'assets/fonts/noto-sans-jp-medium-500.ttf',
    'assets/fonts/noto-sans-jp-semibold-600.ttf',
    'assets/fonts/noto-sans-jp-bold-700.ttf',
  ]);
  await _loadFontFamily('sf_ui', const [
    'assets/fonts/sf-ui-display-regular.otf',
    'assets/fonts/sf-ui-display-medium.otf',
    'assets/fonts/sf-ui-display-semibold.otf',
    'assets/fonts/sf-ui-display-bold.otf',
  ]);
}

Future<void> _loadFontFamily(String family, List<String> assetPaths) async {
  final loader = FontLoader(family);
  for (final path in assetPaths) {
    loader.addFont(rootBundle.load(path));
  }
  await loader.load();
}

/// Widgetテストの共通初期化
///
/// - GoogleFontsのランタイム取得を止める（テスト中にHTTPを叩かせない）
/// - 画面サイズをiPhone相当に固定し、テスト終了時に元へ戻す
void setUpWidgetTest(WidgetTester tester, {Size size = kTestScreenSize}) {
  // フォントはフォールバック描画にする（未取得フォントのHTTPフェッチを禁止）
  GoogleFonts.config.allowRuntimeFetching = false;

  tester.view.devicePixelRatio = kTestDevicePixelRatio;
  tester.view.physicalSize = size * kTestDevicePixelRatio;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// 本番と同じラッパーで [home] を描画する
///
/// - `ProviderScope` … main.dart と同じリポジトリ注入（Fake版）
/// - `MaterialApp` … ダークテーマ固定・`AppColors.dark` ThemeExtension・
///   textScaler 1.0固定（main.dart の builder と同じ）
///
/// [overrides] はリポジトリ以外のProviderを差し替えるためのもの。
/// リポジトリを差し替えたいときは [fakes] にデータ入りFakeを渡す
/// （同じProviderを二重にoverrideしない）。
Future<TestFakes> pumpApp(
  WidgetTester tester, {
  required Widget home,
  TestFakes? fakes,
  List<Override> overrides = const [],
  DateTime? systemDate,
  Size size = kTestScreenSize,
}) async {
  setUpWidgetTest(tester, size: size);
  await loadAppFonts();

  final testFakes = fakes ?? TestFakes();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...testFakes.overrides,
        ...aggregationSettingOverrides(
          systemDate: systemDate ?? kTestSystemDate,
        ),
        ...overrides,
      ],
      child: MaterialApp(
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: const TextScaler.linear(1.0),
              boldText: false,
            ),
            child: child!,
          );
        },
        home: home,
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(extensions: const [AppColors.light]),
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark().copyWith(
          appBarTheme: const AppBarTheme(
            scrolledUnderElevation: 0,
            elevation: 0,
          ),
          extensions: const [AppColors.dark],
        ),
      ),
    ),
  );

  return testFakes;
}

/// 記録モーダル（RegisaterPageBase）を含む画面を破棄する
///
/// かつて `RegisaterPageBase` は未初期化の `late TabController` を
/// `dispose()` で参照し、破棄のたびに `LateInitializationError` を投げていた。
/// 修正済みなので、ここでは「破棄しても例外が出ない」ことを担保する
/// （再発したらこのヘルパーを使う全テストが落ちる）。
Future<void> unmountRegisterPage(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  expect(tester.takeException(), isNull, reason: '記録モーダルの破棄で例外が出てはいけない');
}

/// 開いている記録モーダルを閉じる（ヘッダー左の×ボタン）
///
/// Foundationは起動時に記録モーダルを自動表示するため、
/// 下の画面を操作するテストではまずこれで閉じる。
/// 閉じる過程で例外が出ないことも併せて担保する。
Future<void> closeRegisterModal(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.close_rounded));
  final exceptions = await pumpAndCollectExceptions(tester);
  expect(exceptions, isEmpty, reason: 'モーダルを閉じるときに例外が出てはいけない');
}

/// Zoneへ投げられる非同期エラーを回収しながらpumpする
///
/// riverpodはリスナー実行時の例外を `Zone.current.handleUncaughtError` へ流すため、
/// `tester.takeException()` では捕まえられずテストが即失敗する。
/// 非同期エラーの有無まで検証したい箇所では、これで受け止めて内容を確認する。
Future<List<Object>> pumpCatchingZoneErrors(
  WidgetTester tester, {
  int times = 10,
  Duration duration = const Duration(milliseconds: 100),
}) async {
  final errors = <Object>[];
  await runZonedGuarded(() async {
    for (var i = 0; i < times; i++) {
      await tester.pump(duration);
    }
  }, (error, stack) => errors.add(error));
  return errors;
}

/// 1フレームずつpumpしながら、その間に発生した例外を回収する
///
/// `tester.takeException()` は1フレームに複数例外が出ると
/// 「Multiple exceptions」という要約に化けて中身が見えなくなるため、
/// 既知の不具合を確認したい箇所では1フレームごとに回収する。
Future<List<Object>> pumpAndCollectExceptions(
  WidgetTester tester, {
  int times = 10,
  Duration duration = const Duration(milliseconds: 100),
}) async {
  final collected = <Object>[];
  for (var i = 0; i < times; i++) {
    await tester.pump(duration);
    final exception = tester.takeException();
    if (exception != null) collected.add(exception as Object);
  }
  return collected;
}

/// スナックバーが自動的に消えるまで待つ
///
/// スナックバー（表示2秒）を出したままテストを終えると
/// 「A Timer is still pending」でテストが落ちるため、
/// スナックバーを検証したテストは最後にこれを呼んでタイマーを消化する。
Future<void> waitForSnackBarDismissed(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await pumpTimes(tester, times: 5);
}

/// 非同期Providerの解決を待つための回数指定pump
///
/// ローディング表示（`CircularProgressIndicator`）は無限アニメーションなので、
/// `pumpAndSettle` はタイムアウトする。代わりに固定回数だけフレームを進める。
Future<void> pumpTimes(
  WidgetTester tester, {
  int times = 10,
  Duration duration = const Duration(milliseconds: 100),
}) async {
  for (var i = 0; i < times; i++) {
    await tester.pump(duration);
  }
}
