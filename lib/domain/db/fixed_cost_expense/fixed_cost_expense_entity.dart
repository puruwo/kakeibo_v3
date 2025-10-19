import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'fixed_cost_expense_entity.freezed.dart';

//jsonを変換する処理が生成されるクラス
part 'fixed_cost_expense_entity.g.dart';

// 固定費支出データのエンティティ
@freezed
class FixedCostExpenseEntity with _$FixedCostExpenseEntity {
  const factory FixedCostExpenseEntity({
    @Default(0) int id,
    @Default(0) int fixedCostId,
    required int fixedCostCategoryId,
    required String date,
    @Default(0) int price,
    @Default('') String name,
    @Default(0) int confirmedCostType, // 0: 金額確定固定費, 1: 金額未確定固定費
    @Default(1) int isConfirmed, // 0: 未確定, 1: 確定
  }) = _FixedCostExpenseEntity;

  factory FixedCostExpenseEntity.fromJson(Map<String, dynamic> json) =>
      _$FixedCostExpenseEntityFromJson(json);
}
