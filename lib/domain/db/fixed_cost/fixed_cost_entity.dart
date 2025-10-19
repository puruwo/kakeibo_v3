import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'fixed_cost_entity.freezed.dart';

//jsonを変換する処理が生成されるクラス
part 'fixed_cost_entity.g.dart';

// 支出データのエンティティ
@freezed
class FixedCostEntity with _$FixedCostEntity {
  const factory FixedCostEntity({
    int? id,
    @Default('') String name,
    required int variable,
    @Default(0) int price,
    @Default(0) int estimatedPrice,
    required int fixedCostCategoryId,
    required int intervalNumber,
    required int intervalUnit,
    required String firstPaymentDate,
    String? recentPaymentDate,
    String? nextPaymentDate,
    @Default(0) int deleteFlag,
  }) = _FixedCostEntity;

  @override
  factory FixedCostEntity.fromJson(Map<String, dynamic> json) =>
      _$FixedCostEntityFromJson(json);
}
