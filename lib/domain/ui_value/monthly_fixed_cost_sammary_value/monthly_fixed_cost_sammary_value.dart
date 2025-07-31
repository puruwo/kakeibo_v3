import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'monthly_fixed_cost_sammary_value.freezed.dart';

// 月次計画のエンティティ
@freezed
class MonthlyFixedCostSummaryValue with _$MonthlyFixedCostSummaryValue {
  const factory MonthlyFixedCostSummaryValue({
    required int fixedCostSum,
    required int unconfirmedFixedCostSum,
    required int scheduledPaymentAmount,
  }) = _MonthlyFixedCostSummaryValue;

}
