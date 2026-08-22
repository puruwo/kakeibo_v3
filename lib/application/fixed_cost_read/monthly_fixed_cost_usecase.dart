import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_fixed_cost_tile_service.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_confirmed_fixed_cost_tile_value/monthly_confirmed_fixed_cost_tile_value.dart';

import 'package:kakeibo/view_model/state/update_DB_count.dart';

// 月の確定分固定費を取得するユースケース
// データ源は expense の固定費行（fixed_cost_id IS NOT NULL）。仕様 §8.3

final monthlyFixedCostNotifierProvider = AsyncNotifierProvider.family<
    MonthlyFixedCostUsecaseNotifier,
    List<MonthlyConfirmedFixedCostTileValue>,
    PeriodValue>(
  MonthlyFixedCostUsecaseNotifier.new,
);

class MonthlyFixedCostUsecaseNotifier extends FamilyAsyncNotifier<
    List<MonthlyConfirmedFixedCostTileValue>, PeriodValue> {
  @override
  Future<List<MonthlyConfirmedFixedCostTileValue>> build(
      PeriodValue selectedMonthPeriod) async {
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    final entries = await ref
        .read(monthlyFixedCostTileServiceProvider)
        .fetchEntries(period: selectedMonthPeriod);

    // 確定済みのもののみ返す
    return entries
        .where((e) => e.isConfirmed)
        .map((e) => e.tile as MonthlyConfirmedFixedCostTileValue)
        .toList();
  }
}
