import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'bonus_plan_value.freezed.dart';

// 月次計画のエンティティ
@freezed
class BonusPlanValue with _$BonusPlanValue {
  const factory BonusPlanValue({
    required int yearlyBonusExpense,
    required int yearlyBonusIncome,
    required int lastBonusPrice,
  }) = _BonusPlanValue;

}
