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

extension MonthValueExtension on MonthValue {
  int get year {
    // 先頭4文字をintへ
    return int.parse(month.substring(0, 4));
  }

  int get monthNumber {
    // 5,6文字目をintへ
    return int.parse(month.substring(4, 6));
  }
}