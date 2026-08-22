import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_fixed_cost_tile_service.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_sammary_value/monthly_fixed_cost_sammary_value.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

// 月の固定費のサマリー情報を取得する
// データ源は expense の固定費行。確定分はprice、未確定分はestimated_price（仕様 §7.1）

final monthlyFixedCostSummaryNotifierProvider = AsyncNotifierProvider.family<
    MonthlyFixedCostSummaryNotifier, MonthlyFixedCostSummaryValue, PeriodValue>(
  MonthlyFixedCostSummaryNotifier.new,
);

class MonthlyFixedCostSummaryNotifier
    extends FamilyAsyncNotifier<MonthlyFixedCostSummaryValue, PeriodValue> {
  @override
  Future<MonthlyFixedCostSummaryValue> build(
      PeriodValue selectedMonthPeriod) async {
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    final entries = await ref
        .read(monthlyFixedCostTileServiceProvider)
        .fetchEntries(period: selectedMonthPeriod);

    // 確定分と未確定分を集計
    int fixedCostSum = 0;
    int unconfirmedFixedCostSum = 0;

    for (var entry in entries) {
      if (entry.isConfirmed) {
        fixedCostSum += entry.amount;
      } else {
        unconfirmedFixedCostSum += entry.amount;
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
