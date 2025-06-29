import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/core/month_value/month_value.dart';
import 'package:kakeibo/domain/core/year_value/year_value.dart';

part 'date_scope_entity.freezed.dart';

@freezed
class DateScopeEntity with _$DateScopeEntity {
  const factory DateScopeEntity({
    required DateTime selectedDate,
    required PeriodValue monthPeriod,
    required int monthIndex,
    required MonthValue representativeMonth,
    required PeriodValue yearPeriod,
    required YearValue representativeYear,
  }) = _DateScopeEntity;
}