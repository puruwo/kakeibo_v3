import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'month_period_value.freezed.dart';

@freezed
class PeriodValue with _$PeriodValue {
  const factory PeriodValue({
    required DateTime startDatetime,
    required DateTime endDatetime,
  }) = _MonthPeriodValue;

}