import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
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
  late ExpenseRepository _expenseRepo;
  late FixedCostRepository _fixedCostRepo;

  @override
  Future<MonthlyFixedCostSummaryValue> build(
      PeriodValue selectedMonthPeriod) async {
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _expenseRepo = ref.read(expenseRepositoryProvider);
    _fixedCostRepo = ref.read(fixedCostRepositoryProvider);

    // expenseから確定文の固定費の支出合計を取得する
    final fixedCostSum = await _expenseRepo.fetchTotalFixedCostByPeriod(
      period: selectedMonthPeriod,
    );

    // 未確定分の固定費の推定支出合計を取得する
    final unFixedIds =
        await _expenseRepo.fetchUnFixedIdsByPeriod(period: selectedMonthPeriod);

    // 未確定分の固定費の推定支出合計を取得する
    int unconfirmedFixedCostSum = 0;
    for (int i = 0; i < unFixedIds.length; i++) {
      final unconfirmedFixedCost =
          await _fixedCostRepo.fetchEstimatedPriceById(id: unFixedIds[i]);
      unconfirmedFixedCostSum += unconfirmedFixedCost;
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
