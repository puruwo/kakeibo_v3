import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'budget_entity.freezed.dart';

//jsonを変換する処理が生成されるクラス
part 'budget_entity.g.dart';

// 予算データのエンティティ
@freezed
class BudgetEntity with _$BudgetEntity {
  const factory BudgetEntity({
    @Default(0) int id,
    @Default(0) int expenseBigCategoryId,
    required String month,
    @Default(0) int price,
  }) = _BudgetEntity;

  @override
  factory BudgetEntity.fromJson(Map<String, dynamic> json) =>
      _$BudgetEntityFromJson(json);
}
