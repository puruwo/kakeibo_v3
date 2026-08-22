import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';

import 'package:kakeibo/domain/core/export/export_value.dart';
import 'package:kakeibo/domain/core/export/export_income_value.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/logger.dart';

final exportUsecaseProvider = Provider<ExportUsecase>(ExportUsecase.new);

class ExportUsecase {
  ExportUsecase(this._ref);

  final Ref _ref;

  ExpenseRepository get _expenseRepositoryProvider =>
      _ref.read(expenseRepositoryProvider);

  ExpenseSmallCategoryRepository get _smallCategoryRepository =>
      _ref.read(expenseSmallCategoryRepositoryProvider);

  ExpenseBigCategoryRepository get _bigCategoryRepository =>
      _ref.read(expensebigCategoryRepositoryProvider);

  IncomeBigCategoryRepository get _incomeBigCategoryRepository =>
      _ref.read(incomeBigCategoryRepositoryProvider);

  IncomeRepository get _incomeRepository => _ref.read(incomeRepositoryProvider);

  IncomeSmallCategoryRepository get _incomeSmallCategoryRepository =>
      _ref.read(incomeSmallCategoryRepositoryProvider);

  /// [exportAll] メソッドは、支出・収入の情報を同一CSVファイルの別テーブルとして出力する
  ///
  /// 固定費実績もexpenseに入るため（v10）、固定費専用シートは廃止し、
  /// 支出シートに fixed_cost_id / is_confirmed / estimated_price 列を追加した（仕様 §10）。
  Future<void> exportAll() async {
    // ===== 支出データのエクスポート =====
    List<List> expenseExportList = [];

    // 通常の支出データを取得して追加
    final expenseList = await _expenseRepositoryProvider.fetchAll();
    for (var expense in expenseList) {
      // 支出のレコードからカテゴリーidを取得し、小カテゴリーの情報を取得する
      final expenseSmallCategory = await _smallCategoryRepository
          .fetchBySmallCategory(smallCategoryId: expense.paymentCategoryId);

      // 小カテゴリーのレコードから大カテゴリーidを取得し、大カテゴリーの情報を取得する
      final expenseBigCategory = await _bigCategoryRepository
          .fetchByBigCategory(
            bigCategoryId: expenseSmallCategory.bigCategoryKey,
          );

      final incomeBigCategory = await _incomeBigCategoryRepository
          .fetchByBigCategory(bigCategoryId: expense.incomeSourceBigCategory);

      // iconPathを加工
      final iconName = extractIconName(expenseBigCategory.resourcePath);

      final expenseHistoryTileValue = ExportValue(
        id: expense.id,
        date: expense.date,
        price: expense.effectivePrice,
        memo: expense.memo,
        bigCategoryName: expenseBigCategory.bigCategoryName,
        bigCategoryId: expenseBigCategory.id,
        smallCategoryName: expenseSmallCategory.smallCategoryName,
        smallCategoryId: expenseSmallCategory.id,
        colorCode: expenseBigCategory.colorCode,
        iconName: iconName,
        incomeSourceBigCategoryName: incomeBigCategory.name,
        incomeSourceBigCategoryId: incomeBigCategory.id,
        fixedCostId: expense.fixedCostId,
        isConfirmed: expense.isConfirmed,
        estimatedPrice: expense.estimatedPrice,
      );

      final list = toList(expenseHistoryTileValue);
      expenseExportList.add(list);
    }

    // ===== 収入データのエクスポート =====
    List<List> incomeExportList = [];

    // 全ての収入データを取得
    final incomeList = await _incomeRepository.fetchAll();
    for (var income in incomeList) {
      // 収入のレコードからカテゴリーidを取得し、小カテゴリーの情報を取得する
      final incomeSmallCategory = await _incomeSmallCategoryRepository
          .fetchBySmallCategory(smallCategoryId: income.categoryId);

      // 小カテゴリーのレコードから大カテゴリーidを取得し、大カテゴリーの情報を取得する
      final incomeBigCategory = await _incomeBigCategoryRepository
          .fetchByBigCategory(
            bigCategoryId: incomeSmallCategory.bigCategoryKey,
          );

      final incomeExportValue = ExportIncomeValue(
        id: income.id,
        date: income.date,
        price: income.price,
        memo: income.memo,
        bigCategoryName: incomeBigCategory.name,
        bigCategoryId: incomeBigCategory.id,
        smallCategoryName: incomeSmallCategory.smallCategoryName,
        smallCategoryId: incomeSmallCategory.id,
      );

      final list = incomeToList(incomeExportValue);
      incomeExportList.add(list);
    }

    // ===== CSVを構築 =====
    final csvString = buildExportCsvString(
      expenseRows: expenseExportList,
      incomeRows: incomeExportList,
    );

    // CSVファイルを作成
    await makeCsvFile('export.csv', csvString);

    // CSVファイルを共有
    await shareCsvFile('export.csv');
  }
}

/// 支出・収入の各行リストからエクスポート用のCSV文字列を構築する
///
/// ヘッダー定義と「【支出データ】→行→空行→【収入データ】→行」の
/// 連結・CSV変換までを担当する（ファイルI/O・共有シートの表示は含まない）。
/// 固定費専用シートはv10で廃止し、支出シートの固定費3列に統合した。
String buildExportCsvString({
  required List<List> expenseRows,
  required List<List> incomeRows,
}) {
  // 支出セクション
  const expenseHeader = [
    'ID',
    '日付',
    '購入金額',
    'メモ',
    '大カテゴリー名',
    '大カテゴリーID',
    'カテゴリー名',
    'カテゴリーID',
    '色コード',
    'アイコン情報',
    '拠出元',
    '拠出元ID',
    '固定費ID',
    '確定状態ID',
    '予想額',
  ];

  // 収入セクション
  const incomeHeader = [
    'ID',
    '日付',
    '金額',
    'メモ',
    '大カテゴリー名',
    '大カテゴリーID',
    'カテゴリー名',
    'カテゴリーID',
  ];

  // 全体をCSV形式に変換（支出テーブル → 空行 → 収入テーブル）
  final allData = [
    ['【支出データ】'],
    expenseHeader,
    ...expenseRows,
    [], // 空行でセクションを区切る
    ['【収入データ】'],
    incomeHeader,
    ...incomeRows,
  ];

  return const ListToCsvConverter().convert(allData);
}

/// アイコンのリソースパスからアイコン名を取り出す
///
/// assets/images/icon_〇〇.svg → 〇〇
String extractIconName(String resourcePath) {
  return resourcePath.split('/').last.split('.').first.split('_').last;
}

Future<void> makeCsvFile(String fileName, String csvString) async {
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/$fileName';

  // ファイルに書き込み
  final file = File(path);
  await file.writeAsString(csvString);

  logger.i('CSVファイルを作成し保存しました: $path');
}

Future<void> shareCsvFile(String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/$fileName';
  final file = File(path);

  // ハーフモーダル（共有シート）を表示
  await Share.shareXFiles([XFile(file.path)], text: 'CSVデータを共有します');
}
