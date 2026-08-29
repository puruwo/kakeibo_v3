import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/aggregation_start_day_entity/aggregation_start_day_entity.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain_service/aggregation_period_rule/aggregation_period_rule.dart';
import 'package:kakeibo/domain_service/month_period_service/aggregation_start_day_provider.dart';

final monthPeriodServiceProvider = Provider<MonthPeriodService>(
  (ref) => MonthPeriodService(ref),
);

class MonthPeriodService {
  MonthPeriodService(this._ref);

  final Ref _ref;

  AggregationStartDayService get _aggregationStartDateEntity =>
      _ref.read(aggregationStartDayProvider);

  // 指定した日付を含む集計期間を取得する
  Future<PeriodValue> fetchMonthPeriod(DateTime includedDate) async {
    // ユーザ設定の集計開始日を取得する
    AggregationStartDayEntity aggregationStartDateEntity =
        await _aggregationStartDateEntity.fetchAggregationStartDay();
    final int aggregationStartDay = aggregationStartDateEntity.day;

    // 区切り規則は AggregationPeriodRule に一本化している（集計期間設定ページのプレビューと共有）
    return AggregationPeriodRule.monthPeriod(
      today: includedDate,
      startDay: aggregationStartDay,
    );
  }

  // shift分移動した月の集計期間を取得する
  PeriodValue fetchShiftedMonthPeriod(PeriodValue monthPeriodValue, int shift) {
    if (shift == 0) {
      // シフトしない場合はそのまま返す
      return monthPeriodValue;
    }

    // 開始基準日（1〜28日。29日以降はaggregation_settingsで設定不可）を保ったまま
    // 月だけ移動し、fetchMonthPeriodと同じ規則で期間を組み立てる
    final startDay = monthPeriodValue.startDatetime.day;

    // 開始日: シフト先の月の開始基準日
    final shiftedMonthPeriodStartDate = DateTime(
      monthPeriodValue.startDatetime.year,
      monthPeriodValue.startDatetime.month + shift,
      startDay,
    );

    // 終了日: シフト先の翌月の開始基準日の前日
    // （開始基準日が1日の場合はシフト先の月の末日になる）
    final shiftedMonthPeriodEndDate = DateTime(
      monthPeriodValue.startDatetime.year,
      monthPeriodValue.startDatetime.month + shift + 1,
      startDay - 1,
    );

    return PeriodValue(
      startDatetime: shiftedMonthPeriodStartDate,
      endDatetime: shiftedMonthPeriodEndDate,
    );
  }
}
