import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'all_category_card_entity.freezed.dart';

enum AllCategoryCardStatusType {
  hasBudgetAndIncome, // 予算も収入も設定されている
  hasBudget, // 予算が設定されている
  hasIncome, // 収入が設定されている
  hasOnlyExpense, // 支出だけが設定されている
  noData, // 予算も収入も設定されていない
}

@freezed
class AllCategoryCardModel with _$AllCategoryCardModel {
  const factory AllCategoryCardModel({
    required AllCategoryCardStatusType cardStatusType,
    required int allCategoryTotalExpense,
    required int allCategoryTotalBudget,
    required int allCategoryTotalIncome,
    required int allFixedCostExpense,
    required int denominator,
    required int realSavings,
    required List<String> categoryNameList,
    required List<int> categoryExpenseList,
    required List<double> categoryExpenseRatioList,
    required List<String> categoryIconPathList,
    required List<String> categoryColorList,
  }) = _AllCategoryCardModel;
}
