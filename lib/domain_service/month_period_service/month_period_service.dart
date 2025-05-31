import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/aggregation_start_day_entity/aggregation_start_day_entity.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
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

    // 入力した日がユーザ設定の期間開始日より前の場合
    if (includedDate.day < aggregationStartDay) {
      // 今月の開始日
      final startDatetime = DateTime(
          includedDate.year, includedDate.month - 1, aggregationStartDay);
      // 先月の終了日
      final endDatetime = DateTime(
          includedDate.year, includedDate.month, aggregationStartDay - 1);

      return PeriodValue(
          startDatetime: startDatetime, endDatetime: endDatetime);
    }
    // 入力した日がユーザ設定の期間開始日以降の場合
    else if (includedDate.day >= aggregationStartDay) {
      // 今月の開始日
      final startDatetime =
          DateTime(includedDate.year, includedDate.month, aggregationStartDay);
      // 今月の終了日
      final endDatetime = DateTime(
          includedDate.year, includedDate.month + 1, aggregationStartDay - 1);

      return PeriodValue(
          startDatetime: startDatetime, endDatetime: endDatetime);
    } else {
      throw Exception('期間の取得に失敗しました');
    }
  }

  // 前の集計期間を取得する
  PeriodValue fetchShiftedMonthPeriod(PeriodValue monthPeriodValue, int shift) {
    
    // ====開始日====
    DateTime shiftedMonthPeriodStartDate;

    // シフト分月移動して、その日付を取得する
    // 日付が存在しなければ
    final shiftedMonthStartDay = DateTime(
            monthPeriodValue.startDatetime.year,
            monthPeriodValue.startDatetime.month + shift,
            monthPeriodValue.startDatetime.day)
        .day;

    // 移動後月の日付よりも、開始基準日の日付が大きい場合
    // 例: 開始基準日が月末(31日)で、前月の最終日が30日の場合
    // previousMonthStartDateBuffは次の月の1日になる
    if (shiftedMonthStartDay < monthPeriodValue.startDatetime.day) {
      // 開始日: 前月の最終日を開始日として扱い
      shiftedMonthPeriodStartDate = DateTime(
          monthPeriodValue.startDatetime.year,
          monthPeriodValue.startDatetime.month + shift,
          0);
    }
    // 開始基準日が前月に存在する場合
    else if (shiftedMonthStartDay >= monthPeriodValue.startDatetime.day) {
      // 月をシフトしただけで大丈夫
      shiftedMonthPeriodStartDate = DateTime(
          monthPeriodValue.startDatetime.year,
          monthPeriodValue.startDatetime.month + shift,
          monthPeriodValue.startDatetime.day);
    } else {
      throw Exception('開始基準日の処理に失敗しました');
    }

    // ====終了日===
    DateTime shiftedMonthPeriodEndDate;

    // シフト分月移動して、その日付を取得する
    // 日付が存在しなければ
    final shiftedMonthEndDay = DateTime(
            monthPeriodValue.endDatetime.year,
            monthPeriodValue.endDatetime.month + shift,
            monthPeriodValue.endDatetime.day)
        .day;

    if (shiftedMonthEndDay < monthPeriodValue.endDatetime.day) {
      // 開始日: 前月の最終日を開始日として扱い
      shiftedMonthPeriodEndDate = DateTime(
          monthPeriodValue.endDatetime.year,
          monthPeriodValue.endDatetime.month + shift,
          0);
    }
    // 開始基準日が前月に存在する場合
    else if (shiftedMonthEndDay >= monthPeriodValue.endDatetime.day) {
      // 月をシフトしただけで大丈夫
      shiftedMonthPeriodEndDate = DateTime(
          monthPeriodValue.endDatetime.year,
          monthPeriodValue.endDatetime.month + shift,
          monthPeriodValue.endDatetime.day);
    } else {
      throw Exception('開始基準日の処理に失敗しました');
    }

    return PeriodValue(
        startDatetime: shiftedMonthPeriodStartDate,
        endDatetime: shiftedMonthPeriodEndDate);
  }
}
