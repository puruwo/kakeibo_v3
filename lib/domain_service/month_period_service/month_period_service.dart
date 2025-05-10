import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/aggregation_start_day_entity/aggregation_start_day_entity.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain_service/month_period_service/aggregation_start_day_provider.dart';

final monthPeriodServiceProvider = Provider<MonthPeriodService>(
  (ref) => MonthPeriodService(ref),
);

class MonthPeriodService{

  MonthPeriodService(this._ref);

  final Ref _ref;

  AggregationStartDayService get _aggregationStartDateEntity => _ref.read(aggregationStartDayProvider);

  // 指定した日付を含む集計期間を取得する
  Future<MonthPeriodValue> fetchMonthPeriod(DateTime includedDate) async{

    // ユーザ設定の集計開始日を取得する
    AggregationStartDayEntity aggregationStartDateEntity = await _aggregationStartDateEntity.fetchAggregationStartDay();
    final int aggregationStartDay = aggregationStartDateEntity.day;
    
    // 入力した日がユーザ設定の期間開始日より前の場合
    if(includedDate.day < aggregationStartDay){
      // 今月の開始日
      final startDatetime = DateTime(includedDate.year, includedDate.month - 1, aggregationStartDay);
      // 先月の終了日
      final endDatetime = DateTime(includedDate.year, includedDate.month, aggregationStartDay - 1);

      return MonthPeriodValue(startDatetime: startDatetime, endDatetime: endDatetime);

    }
    // 入力した日がユーザ設定の期間開始日以降の場合
    else if(includedDate.day >= aggregationStartDay){
      // 今月の開始日
      final startDatetime = DateTime(includedDate.year, includedDate.month, aggregationStartDay);
      // 今月の終了日
      final endDatetime = DateTime(includedDate.year, includedDate.month + 1, aggregationStartDay - 1);

      return MonthPeriodValue(startDatetime: startDatetime, endDatetime: endDatetime);

    }else{
      throw Exception('期間の取得に失敗しました');
    }
  }

  // 前の集計期間を取得する
  MonthPeriodValue fetchPreviousMonthPeriod(MonthPeriodValue monthPeriodValue) {
    final previousMonthStartDateBuff = DateTime(monthPeriodValue.startDatetime.year, monthPeriodValue.startDatetime.month - 1, monthPeriodValue.startDatetime.day);

    // 開始日
    DateTime previousMonthPeriodStartDate;

    // 前月の最終日の日付よりも、開始基準日が大きい場合 
    if (previousMonthStartDateBuff.day < monthPeriodValue.startDatetime.day) {
      // 開始日: 前月の最終日を開始日として扱い
      previousMonthPeriodStartDate = previousMonthStartDateBuff;
    } 
    // 開始基準日が前月に存在する場合 
    else if (previousMonthStartDateBuff.day >= monthPeriodValue.startDatetime.day) {
      // 開始日: 前月の年と月の値と、開始基準日を代入して返却
      previousMonthPeriodStartDate = DateTime(previousMonthStartDateBuff.year, previousMonthStartDateBuff.month, monthPeriodValue.startDatetime.day); 
    }else{
      throw Exception('開始基準日の処理に失敗しました');
    }

    // 終了日: 前月の開始基準日を終了日として扱う
    final previousMonthPeriodEndDate = monthPeriodValue.startDatetime.add(const Duration(days: -1));

    return MonthPeriodValue(startDatetime:previousMonthPeriodStartDate,endDatetime: previousMonthPeriodEndDate);
  }
   
  
}

