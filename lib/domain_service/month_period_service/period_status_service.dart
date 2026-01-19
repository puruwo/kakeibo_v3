import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/core/month_value/month_value.dart';
import 'package:kakeibo/domain_service/month_period_service/aggregation_representative_month_service.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';

/// 期間の状態を表すenum
enum PeriodStatus {
  past, // 過去
  current, // 現在
  future, // 未来
}

final periodStatusServiceProvider = Provider<PeriodStatusService>(
  (ref) => PeriodStatusService(ref),
);

class PeriodStatusService {
  PeriodStatusService(this._ref);

  final Ref _ref;

  AggregationRepresentativeMonthService
      get _aggregationRepresentativeMonthService =>
          _ref.read(aggregationRepresentativeMonthServiceProvider);

  /// 指定された日付の代表月と、システム日時の代表月を比較して、期間の状態を返す
  Future<PeriodStatus> fetchPeriodStatus(DateTime selectedDate) async {
    // システム日時を取得
    final systemDate = _ref.read(systemDatetimeNotifierProvider);

    // 選択日とシステム日時の代表月を取得
    final selectedRepresentativeMonth =
        await _aggregationRepresentativeMonthService.fetchMonth(selectedDate);
    final systemRepresentativeMonth =
        await _aggregationRepresentativeMonthService.fetchMonth(systemDate);

    // 代表月を比較
    final comparison = selectedRepresentativeMonth.month
        .compareTo(systemRepresentativeMonth.month);

    if (comparison < 0) {
      return PeriodStatus.past;
    } else if (comparison > 0) {
      return PeriodStatus.future;
    } else {
      return PeriodStatus.current;
    }
  }

  /// MonthValueを直接比較して期間の状態を返す
  PeriodStatus comparePeriodStatus(
      MonthValue selectedMonth, MonthValue systemMonth) {
    final comparison = selectedMonth.month.compareTo(systemMonth.month);

    if (comparison < 0) {
      return PeriodStatus.past;
    } else if (comparison > 0) {
      return PeriodStatus.future;
    } else {
      return PeriodStatus.current;
    }
  }
}
