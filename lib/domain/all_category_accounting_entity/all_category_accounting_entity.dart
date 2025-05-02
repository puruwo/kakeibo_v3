import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'all_category_accounting_entity.freezed.dart';
//jsonを変換する処理が生成されるクラス
part 'all_category_accounting_entity.g.dart';


// 前カテゴリーの月毎の支出と予算のentity
@freezed
class AllCategoryAccountingEntity with _$AllCategoryAccountingEntity {
  const factory AllCategoryAccountingEntity({
    required int totalExpense,
    required int totalBudget,
  }) = _AllCategoryAccountingEntity;

@override
factory AllCategoryAccountingEntity.fromJson(Map<String, dynamic> json) =>
  _$AllCategoryAccountingEntityFromJson(json);
}
