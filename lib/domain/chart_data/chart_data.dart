import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'all_category_entity.freezed.dart';
//jsonを変換する処理が生成されるクラス
part 'all_category_entity.g.dart';

@freezed
class AllCategoryEntity with _$AllCategoryEntity {
  const factory AllCategoryEntity({
    required int totalExpense,
    required int totalBudget,
  }) = _AllCategoryEntity;

@override
factory AllCategoryEntity.fromJson(Map<String, dynamic> json) =>
  _$AllCategoryEntityFromJson(json);
}
