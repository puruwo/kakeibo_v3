import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/constant/sqf_constants.dart';

//Freezedで生成されるデータクラス
part 'income_entity.freezed.dart';

//jsonを変換する処理が生成されるクラス
part 'income_entity.g.dart';

// 支出データのエンティティ
@freezed
class IncomeEntity with _$IncomeEntity {
  const factory IncomeEntity({
    @Default(0) int id,
    // 収入小カテゴリーID（既定は小カテゴリー「給与」）
    @Default(IncomeSmallCategoryConstants.salary) int categoryId,
    required String date,
    @Default(0) int price,
    @Default('') String memo,
  }) = _IncomeEntity;

  @override
  factory IncomeEntity.fromJson(Map<String, dynamic> json) =>
      _$IncomeEntityFromJson(json);
}
