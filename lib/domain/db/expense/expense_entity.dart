import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/constant/sqf_constants.dart';

//Freezedで生成されるデータクラス
part 'expense_entity.freezed.dart';

//jsonを変換する処理が生成されるクラス
part 'expense_entity.g.dart';

// 支出データのエンティティ
@freezed
class ExpenseEntity with _$ExpenseEntity {
  const factory ExpenseEntity({
    @Default(1) int id,
    required String date,
    @Default(0) int price,
    @Default(0) int paymentCategoryId,
    @Default('') String memo,
    @Default(IncomeBigCategoryConstants.incomeSourceIdSalary)
    int incomeSourceBigCategory,
  }) = _ExpenseEntity;

  @override
  factory ExpenseEntity.fromJson(Map<String, dynamic> json) =>
      _$ExpenseEntityFromJson(json);
}
