import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_fixed_cost_summary_usecase.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_fixed_cost_usecase.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_unconfirmed_fixed_cost_usecase.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_sammary_value/monthly_fixed_cost_sammary_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_confirmed_fixed_cost_tile_value/monthly_confirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/analyze_page_date_scope.dart';

// 選択期間を取得し、決定済み固定費のValuesを取得する中間プロバイダ
final resolvedConfirmedFixedCostValueValueProvider =
    FutureProvider<List<MonthlyConfirmedFixedCostTileValue>>((ref) async {

  // 選択された日付から集計期間を取得する
  final monthPeriod = await ref.watch(analyzePageDateScopeEntityProvider.selectAsync((data) => data.monthPeriod));

  // 選択された集計期間を元に、Valuesを取得する
  final values = ref.watch(monthlyFixedCostNotifierProvider(monthPeriod).future);
  return values;
});

// 選択期間を取得し、未確定固定費のValuesを取得する中間プロバイダ
final resolvedUnconfirmedFixedCostValueValueProvider =
    FutureProvider<List<MonthlyUnconfirmedFixedCostTileValue>>((ref) async {

  // 選択された日付から集計期間を取得する
  final monthPeriod = await ref.watch(analyzePageDateScopeEntityProvider.selectAsync((data) => data.monthPeriod));

  // 選択された集計期間を元に、Valuesを取得する
  final values = ref.watch(monthlyUnconfirmedFixedCostNotifierProvider(monthPeriod).future);
  return values;
});

// 選択期間を取得し、固定費のサマリーValuesを取得する中間プロバイダ
final resolvedFixedCostSammaryValueProvider =
    FutureProvider<MonthlyFixedCostSummaryValue>((ref) async {

  // 選択された日付から集計期間を取得する
  final monthPeriod = await ref.watch(analyzePageDateScopeEntityProvider.selectAsync((data) => data.monthPeriod));

  // 選択された集計期間を元に、Valuesを取得する
  final values = ref.watch(monthlyFixedCostSummaryNotifierProvider(monthPeriod).future);
  return values;
});
