import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'month_period_value.freezed.dart';

@freezed
class MonthPeriodValue with _$MonthPeriodValue {
  const factory MonthPeriodValue({
    required DateTime startDatetime,
    required DateTime endDatetime,
  }) = _MonthPeriodValue;

}