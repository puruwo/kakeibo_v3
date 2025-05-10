import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'month_value.freezed.dart';

@freezed
class MonthValue with _$MonthValue {
  const factory MonthValue({
    // ex)202504
    required String month,
  }) = _MonthValue;

}