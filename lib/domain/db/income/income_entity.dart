import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'income_entity.freezed.dart';

//jsonを変換する処理が生成されるクラス
part 'income_entity.g.dart';

// 支出データのエンティティ
@freezed
class IncomeEntity with _$IncomeEntity {
  const factory IncomeEntity({
    @Default(0) int id,
    @Default(0) int categoryId,
    required String date,
    @Default(0) int price,
    @Default('') String memo,
  }) = _IncomeEntity;

  @override
  factory IncomeEntity.fromJson(Map<String, dynamic> json) =>
      _$IncomeEntityFromJson(json);
}
