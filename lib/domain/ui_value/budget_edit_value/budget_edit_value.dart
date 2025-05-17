import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'budget_edit_value.freezed.dart';

// 月次計画のエンティティ
@freezed
class BudgetEditValue with _$BudgetEditValue {
  const factory BudgetEditValue({
    required int id,
    required int expenseBigCategoryId,
    required String month,
    required int price,
    required String expenseBigCategoryName,
    required String colorCode,
    required String resourcePath,
    required int displayOrder,
  }) = _BudgetEditValue;

}
