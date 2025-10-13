import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/annual_balance_chart_usecase/annual_balance_chart_usecase.dart';
import 'package:kakeibo/domain/ui_value/annual_balance_chart_value/annual_balance_chart_value.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/date_scope.dart';

// カレンダーで表示されている選択期間を取得し、Valueを取得する中間プロバイダ
final resolvedAnnualBalanceChartValueProvider =
    FutureProvider<AnnualBalanceChartValue>((ref) async {

  // 選択された日付から集計期間を取得する
  final dateScope = await ref.watch(dateScopeEntityProvider.selectAsync((data) => data));

  // 選択された集計期間を元に、Entityを取得する
  final value = ref.watch(annualBalanceChartNotifierProvider(dateScope).future);
  return value;
});
