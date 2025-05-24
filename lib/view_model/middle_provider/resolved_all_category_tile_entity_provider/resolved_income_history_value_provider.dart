import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/income_history/income_history_usecase.dart';
import 'package:kakeibo/domain/ui_value/income_history_tile_value/income_history_tile_value.dart';
import 'package:kakeibo/view_model/state/date_scope/date_scope.dart';

final resolvedIncomeHistoryValueProvider =
    FutureProvider<List<IncomeHistoryTileValue>>((ref) async {
  
  // 選択された日付から集計期間を取得する
  final monthPeriodValue = await ref.watch(dateScopeEntityProvider.selectAsync((data) => data.monthPeriod));
  
  // 選択された集計期間を元に、Entityを取得する
  final result = ref.watch(incomeHistoryNotifierProvider(monthPeriodValue).future);
  return result;
});
