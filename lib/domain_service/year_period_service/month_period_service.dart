import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/aggregation_start_day_entity/aggregation_start_day_entity.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/aggregation_start_month_entity/aggregation_start_month_entity.dart';
import 'package:kakeibo/domain_service/aggregation_period_rule/aggregation_period_rule.dart';
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

    // 区切り規則は AggregationPeriodRule に一本化している（集計期間設定ページのプレビューと共有）
    return AggregationPeriodRule.yearPeriod(
      today: includedDate,
      startDay: aggregationStartDayEntity.day,
      startMonth: aggregationStartMonthEntity.month,
    );
  }
  
}

