import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'all_category_card_entity.freezed.dart';

@freezed
class AllCategoryCardEntity with _$AllCategoryCardEntity {
  const factory AllCategoryCardEntity({
    required int allCategoryTotalExpense,
    required int allCategoryTotalBudget,
    required int categoryCount,
    required List<int> categoryIdList,
    required List<String> categoryNameList,
    required List<int> categoryExpenseList,
    required List<String> categoryIconPathList,
    required List<String> categoryColorList,

  }) = _AllCategoryCardEntity;
}