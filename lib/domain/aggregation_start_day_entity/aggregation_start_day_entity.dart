import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'aggregation_start_day_entity.freezed.dart';

@freezed
class AggregationStartDayEntity with _$AggregationStartDayEntity {
  const factory AggregationStartDayEntity({
    required int day,
  }) = _AggregationStartDayEntity;

}