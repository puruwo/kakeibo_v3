import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_forecast_usecase.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_fixed_cost_category_summary_usecase.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_fixed_cost_summary_usecase.dart';
import 'package:kakeibo/domain/ui_value/fixed_cost_forecast_value/fixed_cost_forecast_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_sammary_value/monthly_fixed_cost_category_summary_value/monthly_fixed_cost_category_summary_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_sammary_value/monthly_fixed_cost_sammary_value.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/analyze_page_date_scope.dart';

// 選択期間を取得し、固定費のサマリーValuesを取得する中間プロバイダ
final resolvedFixedCostSammaryValueProvider =
    FutureProvider<MonthlyFixedCostSummaryValue>((ref) async {

  // 選択された日付から集計期間を取得する
  final monthPeriod = await ref.watch(analyzePageDateScopeEntityProvider.selectAsync((data) => data.aggregationMonthPeriod));

  // 選択された集計期間を元に、Valuesを取得する
  final values = ref.watch(monthlyFixedCostSummaryNotifierProvider(monthPeriod).future);
  return values;
});

// 選択期間を取得し、固定費のカテゴリー別サマリーValuesを取得する中間プロバイダ
final resolvedFixedCostCategorySummaryValueProvider =
    FutureProvider<List<MonthlyFixedCostCategorySummaryValue>>((ref) async {

  // 選択された日付から集計期間を取得する
  final monthPeriod = await ref.watch(analyzePageDateScopeEntityProvider.selectAsync((data) => data.aggregationMonthPeriod));

  // 選択された集計期間を元に、Valuesを取得する
  final values = ref.watch(monthlyFixedCostCategorySummaryNotifierProvider(monthPeriod).future);
  return values;
});

// 選択期間を取得し、固定費見込み（大カテゴリー別）を取得する中間プロバイダ
// 予算設定画面の「固定費 ¥」参考表示に使う（仕様 §7.3）
final resolvedFixedCostForecastValueProvider =
    FutureProvider<FixedCostForecastValue>((ref) async {

  // 選択された日付から集計期間を取得する
  final monthPeriod = await ref.watch(analyzePageDateScopeEntityProvider.selectAsync((data) => data.aggregationMonthPeriod));

  // 選択された集計期間を元に、Valuesを取得する
  final values = ref.watch(fixedCostForecastNotifierProvider(monthPeriod).future);
  return values;
});
