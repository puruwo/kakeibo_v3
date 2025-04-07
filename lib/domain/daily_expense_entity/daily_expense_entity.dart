import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'daily_expense_entity.freezed.dart';
//jsonを変換する処理が生成されるクラス
part 'daily_expense_entity.g.dart';

@freezed
class DailyExpenseEntity with _$DailyExpenseEntity {
  const factory DailyExpenseEntity({
    required DateTime date,
    @Default(0) int totalExpense,
  }) = _DailyExpenseEntity;

  @override
  factory DailyExpenseEntity.fromJson(Map<String, dynamic> json) =>
      _$DailyExpenseEntityFromJson(json);
}