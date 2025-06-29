import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'monthly_plan_value.freezed.dart';

// 月次計画のエンティティ
@freezed
class MonthlyPlanValue with _$MonthlyPlanValue {
  const factory MonthlyPlanValue({
    required int monthlyExpense,
    required int monthlyIncome,
    required int monthlyBudget,
    required int realSavings,
  }) = _MonthlyPlanValue;

}
