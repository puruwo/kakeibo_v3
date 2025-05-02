import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'expense_entity.freezed.dart';

//jsonを変換する処理が生成されるクラス
part 'expense_entity.g.dart';

// 支出データのエンティティ
@freezed
class ExpenseEntity with _$ExpenseEntity {
  const factory ExpenseEntity({
    required int id,
    required String date,
    required int price,
    required int paymentCategoryId,
    @Default('') String memo,
  }) = _ExpenseEntity;

  @override
  factory ExpenseEntity.fromJson(Map<String, dynamic> json) =>
      _$ExpenseEntityFromJson(json);
}
