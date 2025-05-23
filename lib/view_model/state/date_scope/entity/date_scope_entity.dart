import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/core/month_value/month_value.dart';

part 'date_scope_entity.freezed.dart';

@freezed
class DateScopeEntity with _$DateScopeEntity {
  const factory DateScopeEntity({
    required DateTime selectedDate,
    required MonthPeriodValue monthPeriod,
    required MonthValue representativeMonth,
  }) = _DateScopeEntity;
}