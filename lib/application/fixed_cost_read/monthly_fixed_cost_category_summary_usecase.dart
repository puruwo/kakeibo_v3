import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_sammary_value/monthly_fixed_cost_category_summary_value/monthly_fixed_cost_category_summary_value.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

// カテゴリー別の固定費サマリー情報を取得するユースケース

final monthlyFixedCostCategorySummaryNotifierProvider = AsyncNotifierProvider
    .family<MonthlyFixedCostCategorySummaryNotifier,
        List<MonthlyFixedCostCategorySummaryValue>, PeriodValue>(
  MonthlyFixedCostCategorySummaryNotifier.new,
);

class MonthlyFixedCostCategorySummaryNotifier extends FamilyAsyncNotifier<
    List<MonthlyFixedCostCategorySummaryValue>, PeriodValue> {
  late FixedCostExpenseRepository _fixedCostExpenseRepo;
  late FixedCostCategoryRepository _fixedCostCategoryRepo;
  late FixedCostRepository _fixedCostRepo;

  @override
  Future<List<MonthlyFixedCostCategorySummaryValue>> build(
      PeriodValue selectedMonthPeriod) async {
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _fixedCostExpenseRepo = ref.read(fixedCostExpenseRepositoryProvider);
    _fixedCostCategoryRepo = ref.read(fixedCostCategoryRepositoryProvider);
    _fixedCostRepo = ref.read(fixedCostRepositoryProvider);

    // fixed_cost_expenseから固定費の支出を取得する
    final fixedCostExpenseList = await _fixedCostExpenseRepo.fetchByPeriod(
      period: selectedMonthPeriod,
    );

    // カテゴリーIDごとにグループ化
    final Map<int, List<dynamic>> categoryMap = {};

    for (var fixedCostExpense in fixedCostExpenseList) {
      final categoryId = fixedCostExpense.fixedCostCategoryId;

      if (!categoryMap.containsKey(categoryId)) {
        categoryMap[categoryId] = [];
      }

      categoryMap[categoryId]!.add(fixedCostExpense);
    }

    // カテゴリーごとにサマリーを作成
    final List<MonthlyFixedCostCategorySummaryValue> result = [];

    for (var entry in categoryMap.entries) {
      final categoryId = entry.key;
      final expenses = entry.value;

      // カテゴリー情報を取得
      final category = await _fixedCostCategoryRepo.fetch(id: categoryId);

      // 確定済みかどうかと合計金額を計算
      bool isAllConfirmed = true;
      int totalAmount = 0;

      for (var expense in expenses) {
        if (expense.isConfirmed == 1) {
          // 確定済み
          totalAmount += (expense.price as int);
        } else {
          // 未確定がある
          isAllConfirmed = false;
          // 推定価格を加算
          final estimatedPrice = await _fixedCostRepo.fetchEstimatedPriceById(
              id: expense.fixedCostId);
          totalAmount += estimatedPrice;
        }
      }

      result.add(
        MonthlyFixedCostCategorySummaryValue(
          fixedCostCategoryId: categoryId,
          categoryName: category.categoryName,
          colorCode: category.colorCode,
          resourcePath: category.resourcePath,
          isAllConfirmed: isAllConfirmed,
          totalAmount: totalAmount,
        ),
      );
    }

    return result;
  }
}
