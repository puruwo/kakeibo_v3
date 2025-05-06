import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';

import 'package:kakeibo/domain/core/export/export_value.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/providerLogger.dart';


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

  /// [fetchAll] メソッドは、全てのエクスポートの情報を取得する
  Future<void> exportAll() async {
    // SqfExpenseからデータを取得する
    final expenseList = await _expenseRepositoryProvider.fetchAll();

    // 取得した支出データから、それぞれカテゴリーなどの情報を取得し、タイルのデータを作成する
    List<List> exportList = [];

    // 各valueの情報を取得する
    for (var expense in expenseList) {
      // 支出のレコードからカテゴリーidを取得し、小カテゴリーの情報を取得する
      final expenseSmallCategory = await _smallCategoryRepository.fetchBySmallCategory(
          smallCategoryId: expense.paymentCategoryId);

      // 小カテゴリーのレコードから大カテゴリーidを取得し、大カテゴリーの情報を取得する
      final expenseBigCategory = await _bigCategoryRepository.fetchByBigCategory(
          bigCategoryId: expenseSmallCategory.bigCategoryKey);

      final incomeBigCategory = await _bigCategoryRepository.fetchByBigCategory(bigCategoryId: expense.incomeSourceBigCategory);

      // iconPathを加工
      // assets/images/icon_〇〇.svg → 〇〇
      final iconName = expenseBigCategory.resourcePath.split('/').last.split('.').first.split('_').last;

      final expenseHistoryTileValue = ExportValue(
        id: expense.id,
        date: expense.date,
        price: expense.price,
        memo: expense.memo,
        bigCategoryName: expenseBigCategory.bigCategoryName,
        smallCategoryName: expenseSmallCategory.smallCategoryName,
        colorCode: expenseBigCategory.colorCode,
        iconName: iconName,
        incomeSourceBigCategoryName: incomeBigCategory.bigCategoryName,
      );

      final list = toList(expenseHistoryTileValue);

      exportList.add(list);
    }

    // csv用のヘッダーを作成
    const header = ['ID', '日付', '購入金額', 'メモ', '大カテゴリー名', 'カテゴリー名', '色コード', 'アイコン情報', '拠出元'];
    // 全体をCSV形式に変換
    final csvString = const ListToCsvConverter().convert([header, ...exportList]);

    // CSVファイルを作成
    await makeCsvFile('export.csv', csvString);

    // CSVファイルを共有
    await shareCsvFile('export.csv');
  }
}

Future<void>  makeCsvFile(String fileName,String csvString) async {
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
