import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';

// 支出履歴を取得するサービス
// usecaseに渡す前に1次データを取得するための処理
class ExpenseHistoryService {
  final ExpenseRepository expenseRepo;
  final ExpenseSmallCategoryRepository smallCategoryRepo;
  final ExpenseBigCategoryRepository bigCategoryRepo;
  final IncomeRepository? incomeRepo;
  final IncomeSmallCategoryRepository? incomeSmallCategoryRepo;
  final IncomeBigCategoryRepository? incomeBigCategoryRepo;
  final FixedCostExpenseRepository? fixedCostExpenseRepo;
  final FixedCostCategoryRepository? fixedCostCategoryRepo;

  ExpenseHistoryService({
    required this.expenseRepo,
    required this.smallCategoryRepo,
    required this.bigCategoryRepo,
    this.incomeRepo,
    this.incomeSmallCategoryRepo,
    this.incomeBigCategoryRepo,
    this.fixedCostExpenseRepo,
    this.fixedCostCategoryRepo,
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
          transactionType: incomeSourceBigId == 0
              ? TransactionHistoryType.expense
              : TransactionHistoryType.bonusExpense,
        ),
      );
    }
    return tileList;
  }

  /// 複数のタイプの取引（支出、収入、固定費）を取得
  Future<List<ExpenseHistoryTileValue>> fetchAllTransactionTileList(
    PeriodValue period,
  ) async {
    final List<ExpenseHistoryTileValue> allTransactions = [];

    try {
      // 1. 支出(月次)を取得
      allTransactions.addAll(
        await fetchTileList(0, period)
      );
    } catch (e) {
      print('Error fetching monthly expenses: $e');
    }

    try {
      // 2. 支出(ボーナス)を取得
      allTransactions.addAll(
        await fetchTileList(1, period)
      );
    } catch (e) {
      print('Error fetching bonus expenses: $e');
    }

    // 3. 収入を取得
    if (incomeRepo != null && incomeSmallCategoryRepo != null && incomeBigCategoryRepo != null) {
      try {
        final incomeList = await incomeRepo!.fetchWithoutCategory(period: period);

        for (var income in incomeList) {
          final small = await incomeSmallCategoryRepo!.fetchBySmallCategory(
            smallCategoryId: income.categoryId,
          );
          final big = await incomeBigCategoryRepo!.fetchByBigCategory(
            bigCategoryId: small.bigCategoryKey,
          );

          allTransactions.add(
            ExpenseHistoryTileValue(
              id: income.id,
              date: DateTime.parse(
                '${income.date.substring(0, 4)}-${income.date.substring(4, 6)}-${income.date.substring(6, 8)}'
              ),
              price: income.price,
              paymentCategoryId: income.categoryId,
              memo: income.memo ?? '',
              smallCategoryName: small.smallCategoryName,
              bigCategoryName: big.name,
              colorCode: big.colorCode,
              iconPath: big.iconPath,
              incomeSourceBigCategory: 0,
              transactionType: TransactionHistoryType.income,
            ),
          );
        }
      } catch (e) {
        print('Error fetching income: $e');
      }
    }

    // 4. 固定費を取得
    if (fixedCostExpenseRepo != null && fixedCostCategoryRepo != null) {
      try {
        final fixedCostList = await fixedCostExpenseRepo!.fetchByPeriod(
          period: period,
        );

        for (var fixedCost in fixedCostList) {
          final category = await fixedCostCategoryRepo!.fetch(
            id: fixedCost.fixedCostCategoryId,
          );

          allTransactions.add(
            ExpenseHistoryTileValue(
              id: fixedCost.id,
              date: DateTime.parse(
                '${fixedCost.date.substring(0, 4)}-${fixedCost.date.substring(4, 6)}-${fixedCost.date.substring(6, 8)}'
              ),
              price: fixedCost.price,
              paymentCategoryId: fixedCost.fixedCostCategoryId,
              memo: fixedCost.name ?? '',
              smallCategoryName: category.name,
              bigCategoryName: category.name,
              colorCode: category.colorCode,
              iconPath: category.resourcePath,
              incomeSourceBigCategory: 0,
              transactionType: TransactionHistoryType.fixedCostExpense,
            ),
          );
        }
      } catch (e) {
        print('Error fetching fixed cost expenses: $e');
      }
    }

    return allTransactions;
  }
}
