import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/income_history/income_history_usecase.dart';
import 'package:kakeibo/application/income_history/request_income_history_usecase.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/domain/ui_value/income_history_tile_value/income_history_tile_value.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/analyze_page_date_scope.dart';

final resolvedIncomeHistoryValueProvider =
    FutureProvider<List<IncomeHistoryTileValue>>((ref) async {
  // 選択された日付から集計期間を取得する
  final monthPeriodValue = await ref.watch(analyzePageDateScopeEntityProvider
      .selectAsync((data) => data.aggregationMonthPeriod));

  // リクエスト用のEntityを作成する
  // idは1を指定して、月次収入の履歴を取得する
  final request = RequestIncomeHistoryUsecase(
      bigId: IncomeBigCategoryConstants.incomeSourceIdSalary,
      selectedMonthPeriod: monthPeriodValue);

  // 選択された集計期間を元に、Entityを取得する
  final result = ref.watch(incomeHistoryNotifierProvider(request).future);
  return result;
});
