import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'year_value.freezed.dart';

@freezed
class YearValue with _$YearValue {
  const factory YearValue({
    // ex)2025
    required String year,
  }) = _YearValue;

}