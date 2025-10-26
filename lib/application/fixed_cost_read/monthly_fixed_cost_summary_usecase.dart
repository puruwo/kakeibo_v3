import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_sammary_value/monthly_fixed_cost_sammary_value.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

// 月の固定費のサマリー情報を取得する

final monthlyFixedCostSummaryNotifierProvider = AsyncNotifierProvider.family<
    MonthlyFixedCostSummaryNotifier, MonthlyFixedCostSummaryValue, PeriodValue>(
  MonthlyFixedCostSummaryNotifier.new,
);

class MonthlyFixedCostSummaryNotifier
    extends FamilyAsyncNotifier<MonthlyFixedCostSummaryValue, PeriodValue> {
  late FixedCostExpenseRepository _fixedCostExpenseRepo;
  late FixedCostRepository _fixedCostRepo;

  @override
  Future<MonthlyFixedCostSummaryValue> build(
      PeriodValue selectedMonthPeriod) async {
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _fixedCostExpenseRepo = ref.read(fixedCostExpenseRepositoryProvider);
    _fixedCostRepo = ref.read(fixedCostRepositoryProvider);

    // fixed_cost_expenseから固定費の支出を取得する
    final fixedCostExpenseList = await _fixedCostExpenseRepo.fetchByPeriod(
      period: selectedMonthPeriod,
    );

    // 確定分と未確定分を集計
    int fixedCostSum = 0;
    int unconfirmedFixedCostSum = 0;

    for (var fixedCostExpense in fixedCostExpenseList) {
      if (fixedCostExpense.isConfirmed == 1) {
        // 確定済み
        fixedCostSum += fixedCostExpense.price;
      } else {
        // 未確定
        unconfirmedFixedCostSum += await _fixedCostRepo.fetchEstimatedPriceById(
            id: fixedCostExpense.fixedCostId);
      }
    }

    // 今月の支払い予定
    final scheduledPaymentAmount = fixedCostSum + unconfirmedFixedCostSum;

    // 月次固定費のサマリー情報を返す
    return MonthlyFixedCostSummaryValue(
      fixedCostSum: fixedCostSum,
      unconfirmedFixedCostSum: unconfirmedFixedCostSum,
      scheduledPaymentAmount: scheduledPaymentAmount,
    );
  }
}
