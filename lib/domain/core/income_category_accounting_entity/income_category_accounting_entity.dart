import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'income_category_accounting_entity.freezed.dart';

@freezed
class IncomeCategoryAccountingEntity with _$IncomeCategoryAccountingEntity {
  const factory IncomeCategoryAccountingEntity({
    required int id,
    required String smallCategoryName,
    required int totalIncomeBySmallCategory,
    required String categoryIconPath,
    required String categoryColor,
  }) = _IncomeCategoryAccountingEntity;
}
