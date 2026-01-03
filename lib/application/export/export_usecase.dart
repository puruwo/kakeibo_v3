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
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
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

  FixedCostExpenseRepository get _fixedCostExpenseRepository =>
      _ref.read(fixedCostExpenseRepositoryProvider);

  FixedCostCategoryRepository get _fixedCostCategoryRepository =>
      _ref.read(fixedCostCategoryRepositoryProvider);

  /// [exportAll] メソッドは、支出・収入・固定費の情報を同一CSVファイルの別テーブルとして出力する
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
      final expenseBigCategory =
          await _bigCategoryRepository.fetchByBigCategory(
              bigCategoryId: expenseSmallCategory.bigCategoryKey);

      final incomeBigCategory = await _incomeBigCategoryRepository
          .fetchByBigCategory(bigCategoryId: expense.incomeSourceBigCategory);

      // iconPathを加工
      // assets/images/icon_〇〇.svg → 〇〇
      final iconName = expenseBigCategory.resourcePath
          .split('/')
          .last
          .split('.')
          .first
          .split('_')
          .last;

      final expenseHistoryTileValue = ExportValue(
        id: expense.id,
        date: expense.date,
        price: expense.price,
        memo: expense.memo,
        bigCategoryName: expenseBigCategory.bigCategoryName,
        bigCategoryId: expenseBigCategory.id,
        smallCategoryName: expenseSmallCategory.smallCategoryName,
        smallCategoryId: expenseSmallCategory.id,
        colorCode: expenseBigCategory.colorCode,
        iconName: iconName,
        incomeSourceBigCategoryName: incomeBigCategory.name,
        incomeSourceBigCategoryId: incomeBigCategory.id,
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
      final incomeBigCategory =
          await _incomeBigCategoryRepository.fetchByBigCategory(
              bigCategoryId: incomeSmallCategory.bigCategoryKey);

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

    // ===== 固定費支出データのエクスポート =====
    List<List> fixedCostExportList = [];

    // 全ての固定費支出データを取得
    final fixedCostExpenseList = await _fixedCostExpenseRepository.fetchAll();
    for (var fixedCostExpense in fixedCostExpenseList) {
      // 固定費カテゴリーの情報を取得する
      final fixedCostCategory = await _fixedCostCategoryRepository.fetch(
          id: fixedCostExpense.fixedCostCategoryId);

      // iconPathを加工
      // assets/images/icon_〇〇.svg → 〇〇
      final iconName = fixedCostCategory.resourcePath
          .split('/')
          .last
          .split('.')
          .first
          .split('_')
          .last;

      fixedCostExportList.add([
        fixedCostExpense.id,
        fixedCostExpense.date,
        fixedCostExpense.price,
        fixedCostExpense.name,
        fixedCostCategory.categoryName,
        fixedCostCategory.id,
        fixedCostCategory.colorCode,
        iconName,
        fixedCostExpense.confirmedCostType == 0 ? '確定' : '未確定',
        fixedCostExpense.confirmedCostType,
        fixedCostExpense.isConfirmed == 1 ? '確定済み' : '未確定',
        fixedCostExpense.isConfirmed,
      ]);
    }

    // ===== CSVを構築 =====
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
      '拠出元ID'
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

    // 固定費セクション
    const fixedCostHeader = [
      'ID',
      '日付',
      '金額',
      '名称',
      'カテゴリー名',
      'カテゴリーID',
      '色コード',
      'アイコン情報',
      '金額タイプ',
      '金額タイプID',
      '確定状態',
      '確定状態ID',
    ];

    // 全体をCSV形式に変換（支出テーブル → 空行 → 収入テーブル → 空行 → 固定費テーブル）
    final allData = [
      ['【支出データ】'],
      expenseHeader,
      ...expenseExportList,
      [], // 空行でセクションを区切る
      ['【収入データ】'],
      incomeHeader,
      ...incomeExportList,
      [], // 空行でセクションを区切る
      ['【固定費データ】'],
      fixedCostHeader,
      ...fixedCostExportList,
    ];

    final csvString = const ListToCsvConverter().convert(allData);

    // CSVファイルを作成
    await makeCsvFile('export.csv', csvString);

    // CSVファイルを共有
    await shareCsvFile('export.csv');
  }
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
