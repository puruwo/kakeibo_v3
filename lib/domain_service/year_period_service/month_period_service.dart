import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/aggregation_start_day_entity/aggregation_start_day_entity.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/aggregation_start_month_entity/aggregation_start_month_entity.dart';
import 'package:kakeibo/domain_service/month_period_service/aggregation_start_day_provider.dart';
import 'package:kakeibo/domain_service/year_period_service/aggregation_start_month_provider.dart';

final yearPeriodServiceProvider = Provider<YearPeriodService>(
  (ref) => YearPeriodService(ref),
);

class YearPeriodService{

  YearPeriodService(this._ref);

  final Ref _ref;

  AggregationStartMonthService get _aggregationStartMonthService => _ref.read(aggregationStartMonthProvider);

  // 指定した日付を含む集計期間を取得する
  Future<PeriodValue> fetchYearPeriod(DateTime includedDate) async{

    // ユーザ設定の集計開始日を取得する
    AggregationStartDayEntity aggregationStartDayEntity = await _ref.read(aggregationStartDayProvider).fetchAggregationStartDay();

    // ユーザ設定の集計開始月を取得する
    AggregationStartMonthEntity aggregationStartMonthEntity = await _aggregationStartMonthService.fetchAggregationStartMonth();

    // includedDate(選択中の日付)と同じ年の基準日
    DateTime aggregationStartDay = DateTime(includedDate.year, aggregationStartMonthEntity.month,aggregationStartDayEntity.day);
    
    // 入力した日がその年のユーザ設定の期間開始日より前の場合
    if(includedDate.compareTo(aggregationStartDay) < 0){
      // 今月の開始日
      final startDatetime = DateTime(includedDate.year - 1, aggregationStartDay.month, aggregationStartDay.day);
      // 先月の終了日
      final endDatetime = DateTime(includedDate.year, aggregationStartDay.month, aggregationStartDay.day - 1);

      return PeriodValue(startDatetime: startDatetime, endDatetime: endDatetime);

    }
    // 入力した日がその年のユーザ設定の期間開始日以降の場合
    else if(includedDate.compareTo(aggregationStartDay) >= 0){
      // 今月の開始日
      final startDatetime = aggregationStartDay;
      // 先月の終了日
      final endDatetime = DateTime(includedDate.year + 1, aggregationStartDay.month, aggregationStartDay.day - 1);

      return PeriodValue(startDatetime: startDatetime, endDatetime: endDatetime);

    }else{
      throw Exception('期間の取得に失敗しました');
    }
  }
  
}

