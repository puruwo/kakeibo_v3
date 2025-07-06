import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_fixed_cost_usecase.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_unconfirmed_fixed_cost_usecase.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_confirmed_fixed_cost_tile_value/monthly_confirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/view_model/state/date_scope/date_scope.dart';

// カレンダーで表示されている選択期間を取得し、決定済み固定費のValuesを取得する中間プロバイダ
final resolvedConfirmedFixedCostValueValueProvider =
    FutureProvider<List<MonthlyConfirmedFixedCostTileValue>>((ref) async {

  // 選択された日付から集計期間を取得する
  final monthPeriod = await ref.watch(dateScopeEntityProvider.selectAsync((data) => data.monthPeriod));

  // 選択された集計期間を元に、Valuesを取得する
  final values = ref.watch(monthlyFixedCostNotifierProvider(monthPeriod).future);
  return values;
});

// カレンダーで表示されている選択期間を取得し、決定済み固定費のValuesを取得する中間プロバイダ
final resolvedUnconfirmedFixedCostValueValueProvider =
    FutureProvider<List<MonthlyUnconfirmedFixedCostTileValue>>((ref) async {

  // 選択された日付から集計期間を取得する
  final monthPeriod = await ref.watch(dateScopeEntityProvider.selectAsync((data) => data.monthPeriod));

  // 選択された集計期間を元に、Valuesを取得する
  final values = ref.watch(monthlyUnconfirmedFixedCostNotifierProvider(monthPeriod).future);
  return values;
});
