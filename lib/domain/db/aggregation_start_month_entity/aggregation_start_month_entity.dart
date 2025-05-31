import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'aggregation_start_month_entity.freezed.dart';

@freezed
class AggregationStartMonthEntity with _$AggregationStartMonthEntity {
  const factory AggregationStartMonthEntity({
    required int month,
  }) = _AggregationStartMonthEntity;

}