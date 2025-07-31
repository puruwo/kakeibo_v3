import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/i_monthly_fixed_tile_value.dart';

//Freezedで生成されるデータクラス
part 'monthly_unconfirmed_fixed_cost_tile_value.freezed.dart';

// 支出データのエンティティ
@freezed
class MonthlyUnconfirmedFixedCostTileValue with _$MonthlyUnconfirmedFixedCostTileValue implements IMonthlyFixedTileValue  {
  const factory MonthlyUnconfirmedFixedCostTileValue({

    // expense
    required int id,
    required DateTime date,

    // fixed cost
    required int fixedCostId,
    required String name,
    required int variable,
    required int intervalNumber,
    required int intervalUnit,
    required int estimatedPrice, 
    String? nextPaymentDate,

    // small category
    required String smallCategoryName,

    // big category
    required String bigCategoryName,
    required String colorCode,
    required String resourcePath,

    required String frequencyLabel,


  }) = _MonthlyUnconfirmedFixedCostTileValue;

}
