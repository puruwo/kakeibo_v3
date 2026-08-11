// DB結合テスト用の基盤ヘルパー
//
// UTの Fake が「模していた」SQLを、本物の [DatabaseHelper] と本物のDDL/DMLで検証するための土台。
// sqflite_common_ffi でデスクトップ上にSQLiteを立ち上げ、
// path_provider が返すドキュメントディレクトリをテスト用の一時ディレクトリへ差し替える。
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/debug_seeder.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// path_provider の既定実装 `MethodChannelPathProvider` が使うメソッドチャネル。
///
/// flutter test では各プラットフォーム実装（path_provider_foundation 等）の
/// registerWith が走らないため、`PathProviderPlatform.instance` は既定の
/// メソッドチャネル実装のままになる。よってこのチャネルを差し替えれば
/// `getApplicationDocumentsDirectory()` をテスト用ディレクトリへ向けられる。
const MethodChannel _pathProviderChannel = MethodChannel(
  'plugins.flutter.io/path_provider',
);

/// このスイート専用のドキュメントディレクトリ（= DBファイルの置き場）
Directory? _documentsDirectory;

/// DB結合テストの共通セットアップを登録する。
///
/// 各テストファイルの `main()` 冒頭で1回だけ呼ぶ。以下を行う。
/// - sqflite を FFI 実装（デスクトップ用）に差し替える
/// - `getApplicationDocumentsDirectory()` をスイート固有の一時ディレクトリへ向ける
///   （flutter test はスイートを並列実行するため、固定パスだとDBファイルが衝突する）
/// - [DebugSeeder] を無効化する（flutter test は kDebugMode = true のため、
///   切らないと onCreate で約1500行のモックデータが混入する）
/// - 各テストの前にDBファイルを削除し、onCreate からの再作成を保証する
void setUpDbTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // FFI実装の初期化はテスト本体より前（main実行時）に済ませておく
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUpAll(() async {
    // スイートごとに一意な一時ディレクトリを作る（並列実行時の衝突回避）
    _documentsDirectory = await Directory.systemTemp.createTemp(
      'kakeibo_db_test_',
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, (call) async {
          // DatabaseHelper が使うのは getApplicationDocumentsDirectory のみ
          return _documentsDirectory!.path;
        });
  });

  setUp(() async {
    await resetDatabase();
  });

  tearDownAll(() async {
    // DB接続を閉じてからチャネルとディレクトリを片付ける
    await closeDatabase();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, null);
    final directory = _documentsDirectory;
    _documentsDirectory = null;
    if (directory != null && directory.existsSync()) {
      await directory.delete(recursive: true);
    }
  });
}

/// DBを初期状態へ戻す。
///
/// [DatabaseHelper.deleteDatabaseFile] は「接続close + staticリセット + ファイル削除」を行うので、
/// 次に `DatabaseHelper.instance.database` を触った時点で onCreate から再作成される。
Future<void> resetDatabase() async {
  // onCreate 時にモックデータが入らないことを毎回保証する
  DebugSeeder.enabled = false;
  await DatabaseHelper.instance.deleteDatabaseFile();
}

/// DB接続を閉じ、DBファイルも破棄する（tearDownAll の後片付け用）。
Future<void> closeDatabase() async {
  await DatabaseHelper.instance.deleteDatabaseFile();
}

/// 現在の（テスト用一時ディレクトリ配下の）DBファイルパスを返す
Future<String> currentDatabasePath() =>
    DatabaseHelper.instance.getDatabasePath();

/// DB接続を取得する（未作成なら onCreate が走る）
Future<Database> openTestDatabase() async {
  final db = await DatabaseHelper.instance.database;
  return db!;
}

// ---------------------------------------------------------------------------
// void戻り（fire-and-forget）の書き込み完了待ち
// ---------------------------------------------------------------------------

/// `void insert/update/delete` のような await できない書き込みの完了を待つ。
///
/// リポジトリの書き込みメソッドは戻り値が void で、内部の `db.insert(...)` を
/// await していない。呼び出し直後に検証すると未反映のことがあるため、
/// イベントキューを十分に排出してから検証する。
Future<void> settleDbWrites({int times = 50}) async {
  await pumpEventQueue(times: times);
}

/// 条件が満たされるまでポーリングする（[settleDbWrites] で足りないときの保険）
Future<void> waitUntil(
  Future<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 5),
  String description = 'DB書き込みの反映',
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (await condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  fail('$description を $timeout 以内に確認できませんでした');
}

/// [table] のレコード数が [expected] になるまで待つ
Future<void> waitUntilRowCount(String table, int expected) async {
  await settleDbWrites();
  await waitUntil(
    () async => await DatabaseHelper.instance.queryRowCount(table) == expected,
    description: '$table のレコード数が $expected 件になること',
  );
}

// ---------------------------------------------------------------------------
// フィクスチャ投入ヘルパー
//
// 検証の前提データは決定的にしたいので、リポジトリ経由ではなく
// DatabaseHelper 経由の直接insertで作る（idを明示指定できるようにしてある）。
// 列名は table_calmn_name.dart の定数を使う。
// ---------------------------------------------------------------------------

/// 支出行を1件投入する
///
/// [date] は 'yyyyMMdd' 形式の文字列（DB上の日付表現）。
/// [incomeSourceBigCategory] は拠出元大カテゴリー（1=給与 / 2=ボーナス）。
Future<int> insertExpenseRow({
  required String date,
  required int price,
  int smallCategoryId = 1,
  String memo = '',
  int incomeSourceBigCategory = 1,
  int? id,
}) {
  return DatabaseHelper.instance.insert(SqfExpense.tableName, {
    SqfExpense.id: ?id,
    SqfExpense.expenseSmallCategoryId: smallCategoryId,
    SqfExpense.date: date,
    SqfExpense.price: price,
    SqfExpense.memo: memo,
    SqfExpense.incomeSourceBigCategory: incomeSourceBigCategory,
  });
}

/// 収入行を1件投入する
///
/// [smallCategoryId] は onCreate が投入する収入小カテゴリー
/// （1=給与 / 2=ボーナス / 3=小遣い / 4=臨時収入）を指す。
/// 大カテゴリーとの紐付けは 1・3・4 → 大1（月次収入）、2 → 大2（ボーナス）。
Future<int> insertIncomeRow({
  required String date,
  required int price,
  int smallCategoryId = 1,
  String memo = '',
  int? id,
}) {
  return DatabaseHelper.instance.insert(SqfIncome.tableName, {
    SqfIncome.id: ?id,
    SqfIncome.incomeSmallCategoryId: smallCategoryId,
    SqfIncome.date: date,
    SqfIncome.price: price,
    SqfIncome.memo: memo,
  });
}

/// 予算行を1件投入する（[month] は 'yyyyMM' 形式）
Future<int> insertBudgetRow({
  required int expenseBigCategoryId,
  required String month,
  required int price,
  int? id,
}) {
  return DatabaseHelper.instance.insert(SqfBudget.tableName, {
    SqfBudget.id: ?id,
    SqfBudget.expenseBigCategoryId: expenseBigCategoryId,
    SqfBudget.month: month,
    SqfBudget.price: price,
  });
}

/// バッチ実行履歴を1件投入する（[startDate]/[endDate] は 'yyyyMMdd' 形式）
Future<int> insertBatchHistoryRow({
  required String startDate,
  required String endDate,
  int status = 1,
  int? id,
}) {
  return DatabaseHelper.instance.insert(SqfBatchHistory.tableName, {
    SqfBatchHistory.id: ?id,
    SqfBatchHistory.startDate: startDate,
    SqfBatchHistory.endDate: endDate,
    SqfBatchHistory.status: status,
  });
}

/// 固定費マスタを1件投入する
Future<int> insertFixedCostRow({
  required String name,
  required int fixedCostCategoryId,
  int variable = 0,
  int? price,
  int? estimatedPrice,
  int intervalNumber = 1,
  int intervalUnit = 1,
  String firstPaymentDate = '20250101',
  String? recentPaymentDate,
  String nextPaymentDate = '20250101',
  int deleteFlag = 0,
  int? id,
}) {
  return DatabaseHelper.instance.insert(SqfFixedCost.tableName, {
    SqfFixedCost.id: ?id,
    SqfFixedCost.name: name,
    SqfFixedCost.variable: variable,
    SqfFixedCost.price: price,
    SqfFixedCost.estimatedPrice: estimatedPrice,
    SqfFixedCost.fixedCostCategoryId: fixedCostCategoryId,
    SqfFixedCost.intervalNumber: intervalNumber,
    SqfFixedCost.intervalUnit: intervalUnit,
    SqfFixedCost.firstPaymentDate: firstPaymentDate,
    SqfFixedCost.recentPaymentDate: recentPaymentDate,
    SqfFixedCost.nextPaymentDate: nextPaymentDate,
    SqfFixedCost.deleteFlag: deleteFlag,
  });
}

/// 固定費支出（支払実績）を1件投入する
Future<int> insertFixedCostExpenseRow({
  required int fixedCostId,
  required int fixedCostCategoryId,
  required String date,
  required int price,
  required String name,
  int confirmedCostType = 0,
  int isConfirmed = 0,
  int? id,
}) {
  return DatabaseHelper.instance.insert(SqfFixedCostExpense.tableName, {
    SqfFixedCostExpense.id: ?id,
    SqfFixedCostExpense.fixedCostId: fixedCostId,
    SqfFixedCostExpense.fixedCostCategoryId: fixedCostCategoryId,
    SqfFixedCostExpense.date: date,
    SqfFixedCostExpense.price: price,
    SqfFixedCostExpense.name: name,
    SqfFixedCostExpense.confirmedCostType: confirmedCostType,
    SqfFixedCostExpense.isConfirmed: isConfirmed,
  });
}
