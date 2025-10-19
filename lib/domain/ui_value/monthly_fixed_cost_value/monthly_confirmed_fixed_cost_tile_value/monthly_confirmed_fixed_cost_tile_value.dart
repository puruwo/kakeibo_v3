import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/i_monthly_fixed_tile_value.dart';

//Freezedで生成されるデータクラス
part 'monthly_confirmed_fixed_cost_tile_value.freezed.dart';

// 支出データのエンティティ
@freezed
class MonthlyConfirmedFixedCostTileValue with _$MonthlyConfirmedFixedCostTileValue implements IMonthlyFixedTileValue {
  const factory MonthlyConfirmedFixedCostTileValue({

    // expense
    required int id,
    required DateTime date,
    @Default(0) int price,

    // fixed cost
    required String name,
    required int variable,
    required int intervalNumber,
    required int intervalUnit,
    String? nextPaymentDate,

    // fixed cost category
    required String categoryName,
    required String colorCode,
    required String resourcePath,

    required String frequencyLabel,


  }) = _MonthlyConfirmedFixedCostTileValue;

}
