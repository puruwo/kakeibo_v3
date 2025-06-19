import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';

// 支出履歴を取得するサービス
// usecaseに渡す前に1次データを取得するための処理
class ExpenseHistoryService {
  final ExpenseRepository expenseRepo;
  final ExpenseSmallCategoryRepository smallCategoryRepo;
  final ExpenseBigCategoryRepository bigCategoryRepo;

  ExpenseHistoryService({
    required this.expenseRepo,
    required this.smallCategoryRepo,
    required this.bigCategoryRepo,
  });

  Future<List<ExpenseHistoryTileValue>> fetchTileList(
      int incomeSourceBigId, PeriodValue period,
      {int? smallId}) async {
    List<ExpenseEntity> expenseList;
    // bigCategoryが入力されていない場合は期間と拠出元を指定して支出情報を取得する
    if (smallId == null) {
      expenseList = await expenseRepo.fetchWithSourceCategory(
          incomeSourceBigId: incomeSourceBigId, period: period);
    } // カテゴリーも指定して支出情報を取得する
    else {
      expenseList = await expenseRepo.fetchWithCategory(
          incomeSourceBigId: incomeSourceBigId,
          period: period,
          smallCategoryId: smallId);
    }
    List<ExpenseHistoryTileValue> tileList = [];

    for (var expense in expenseList) {
      final small = await smallCategoryRepo.fetchBySmallCategory(
          smallCategoryId: expense.paymentCategoryId);
      final big = await bigCategoryRepo.fetchByBigCategory(
          bigCategoryId: small.bigCategoryKey);

      tileList.add(
        ExpenseHistoryTileValue(
          id: expense.id,
          date: DateTime.parse(
              '${expense.date.substring(0, 4)}-${expense.date.substring(4, 6)}-${expense.date.substring(6, 8)}'),
          price: expense.price,
          paymentCategoryId: expense.paymentCategoryId,
          memo: expense.memo,
          smallCategoryName: small.smallCategoryName,
          bigCategoryName: big.bigCategoryName,
          colorCode: big.colorCode,
          iconPath: big.resourcePath,
          incomeSourceBigCategory: expense.incomeSourceBigCategory,
        ),
      );
    }
    return tileList;
  }
}
