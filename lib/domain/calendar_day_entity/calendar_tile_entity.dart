import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'calendar_tile_entity.freezed.dart';

@freezed
class CalendarTileEntity with _$CalendarTileEntity {
  const factory CalendarTileEntity({
    required int year,
    required int month,
    required int day,
    required int weekday,
    @Default(0) int totalExpense,
    required bool isWithinAggregationRange,
    required bool shouldDisplayMonth
  }) = _CalendarTileEntity;

}