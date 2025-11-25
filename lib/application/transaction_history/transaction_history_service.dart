import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
import 'package:kakeibo/domain/ui_value/transaction_history_tile_value/transaction_history_tile_value.dart';

/// 複数のタイプの取引（支出、収入、固定費）を統一フォーマットで扱うサービス
class TransactionHistoryService {
  final ExpenseRepository expenseRepo;
  final ExpenseSmallCategoryRepository expenseSmallCategoryRepo;
  final ExpenseBigCategoryRepository expenseBigCategoryRepo;
  final IncomeRepository incomeRepo;
  final IncomeSmallCategoryRepository incomeSmallCategoryRepo;
  final IncomeBigCategoryRepository incomeBigCategoryRepo;
  final FixedCostExpenseRepository fixedCostExpenseRepo;
  final FixedCostCategoryRepository fixedCostCategoryRepo;

  TransactionHistoryService({
    required this.expenseRepo,
    required this.expenseSmallCategoryRepo,
    required this.expenseBigCategoryRepo,
    required this.incomeRepo,
    required this.incomeSmallCategoryRepo,
    required this.incomeBigCategoryRepo,
    required this.fixedCostExpenseRepo,
    required this.fixedCostCategoryRepo,
  });

  /// 指定された期間の全取引データ（支出+収入+固定費）を取得する
  Future<List<TransactionHistoryTileValue>> fetchAllTransactionTileList(
    PeriodValue period,
  ) async {
    final List<TransactionHistoryTileValue> allTransactions = [];

    try {
      // 1. 支出(月次)を取得
      allTransactions.addAll(
        await _fetchExpenseTransactions(period, incomeSourceBigId: 0)
      );
    } catch (e) {
      // エラーログを出力するが、続行する
      print('Error fetching monthly expenses: $e');
    }

    try {
      // 2. 支出(ボーナス)を取得
      allTransactions.addAll(
        await _fetchExpenseTransactions(period, incomeSourceBigId: 1)
      );
    } catch (e) {
      print('Error fetching bonus expenses: $e');
    }

    try {
      // 3. 収入を取得
      allTransactions.addAll(
        await _fetchIncomeTransactions(period)
      );
    } catch (e) {
      print('Error fetching income: $e');
    }

    try {
      // 4. 固定費を取得
      allTransactions.addAll(
        await _fetchFixedCostTransactions(period)
      );
    } catch (e) {
      print('Error fetching fixed cost expenses: $e');
    }

    return allTransactions;
  }

  /// 支出取引を取得して TransactionHistoryTileValue に変換
  Future<List<TransactionHistoryTileValue>> _fetchExpenseTransactions(
    PeriodValue period, {
    required int incomeSourceBigId,
  }) async {
    final expenseList = await expenseRepo.fetchWithSourceCategory(
      incomeSourceBigId: incomeSourceBigId,
      period: period,
    );

    final List<TransactionHistoryTileValue> tileList = [];

    for (var expense in expenseList) {
      final small = await expenseSmallCategoryRepo.fetchBySmallCategory(
        smallCategoryId: expense.paymentCategoryId,
      );
      final big = await expenseBigCategoryRepo.fetchByBigCategory(
        bigCategoryId: small.bigCategoryKey,
      );

      final transactionType = incomeSourceBigId == 0
          ? TransactionType.expense
          : TransactionType.bonusExpense;

      tileList.add(
        TransactionHistoryTileValue(
          id: expense.id,
          date: DateTime.parse(
            '${expense.date.substring(0, 4)}-${expense.date.substring(4, 6)}-${expense.date.substring(6, 8)}'
          ),
          price: expense.price,
          type: transactionType,
          categoryId: expense.paymentCategoryId,
          memo: expense.memo ?? '',
          smallCategoryName: small.smallCategoryName,
          bigCategoryName: big.bigCategoryName,
          colorCode: big.colorCode,
          iconPath: big.resourcePath,
        ),
      );
    }

    return tileList;
  }

  /// 収入取引を取得して TransactionHistoryTileValue に変換
  Future<List<TransactionHistoryTileValue>> _fetchIncomeTransactions(
    PeriodValue period,
  ) async {
    final incomeList = await incomeRepo.fetchWithoutCategory(period: period);

    final List<TransactionHistoryTileValue> tileList = [];

    for (var income in incomeList) {
      final small = await incomeSmallCategoryRepo.fetchBySmallCategory(
        smallCategoryId: income.incomeCategoryId,
      );
      final big = await incomeBigCategoryRepo.fetchByBigCategory(
        bigCategoryId: small.bigCategoryKey,
      );

      tileList.add(
        TransactionHistoryTileValue(
          id: income.id,
          date: DateTime.parse(
            '${income.date.substring(0, 4)}-${income.date.substring(4, 6)}-${income.date.substring(6, 8)}'
          ),
          price: income.price,
          type: TransactionType.income,
          categoryId: income.incomeCategoryId,
          memo: income.memo ?? '',
          smallCategoryName: small.incomeCategoryName,
          bigCategoryName: big.incomeCategoryName,
          colorCode: big.colorCode,
          iconPath: big.resourcePath,
        ),
      );
    }

    return tileList;
  }

  /// 固定費取引を取得して TransactionHistoryTileValue に変換
  Future<List<TransactionHistoryTileValue>> _fetchFixedCostTransactions(
    PeriodValue period,
  ) async {
    final fixedCostList = await fixedCostExpenseRepo.fetchByPeriod(
      period: period,
    );

    final List<TransactionHistoryTileValue> tileList = [];

    for (var fixedCost in fixedCostList) {
      final category = await fixedCostCategoryRepo.fetchByFixedCostCategoryId(
        fixedCostCategoryId: fixedCost.fixedCostCategoryId,
      );

      tileList.add(
        TransactionHistoryTileValue(
          id: fixedCost.id,
          date: DateTime.parse(
            '${fixedCost.date.substring(0, 4)}-${fixedCost.date.substring(4, 6)}-${fixedCost.date.substring(6, 8)}'
          ),
          price: fixedCost.price,
          type: TransactionType.fixedCostExpense,
          categoryId: fixedCost.fixedCostCategoryId,
          memo: fixedCost.name ?? '',
          smallCategoryName: category.categoryName,
          bigCategoryName: category.categoryName, // 固定費は単一レベル
          colorCode: category.colorCode,
          iconPath: category.resourcePath,
        ),
      );
    }

    return tileList;
  }
}
