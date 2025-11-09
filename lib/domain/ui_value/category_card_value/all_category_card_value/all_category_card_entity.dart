import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'all_category_card_entity.freezed.dart';

enum AllCategoryCardStatusType {
  hasBudgetAndIncomeNotOver(true,true,true), // 予算も収入も設定されており、支出は予算をオーバーしていない
  hasBudgetIncomeExpenseOver(true,true,true), // 予算も収入も設定されているが支出がオーバーしている(予算<収入<支出)
  hasBudgetExpenseIncomeOver(true,true,true), // 予算も収入も設定されているが支出がオーバーしている(予算<支出<収入)
  hasIncomeBudgetExpenseOver(true,true,true), // 予算も収入も設定されているが支出がオーバーしている(収入<予算<支出)
  //hasBudgetAndIncome // 予算も収入も設定されているが支出がオーバーしている(収入<支出<予算)
  hasOnlyBudget(false,true,true), // 予算だけが設定されている
  hasBudgetAndOver(false,true,true), // 予算が設定されているが支出がオーバーしている
  hasOnlyIncome(true,false,true), // 収入だけが設定されている
  hasIncomeAndOver(true,false,true), // 収入が設定されているが支出がオーバーしている
  hasOnlyExpense(false,false,true), // 予算も収入もないが支出が記録されている
  noData(false,false,false); // 予算も収入も設定されていないし支出もない

  final bool hasIncome;
  final bool hasBudget;
  final bool hasExpense;

  const AllCategoryCardStatusType(this.hasIncome,this.hasBudget,this.hasExpense);
}

@freezed
class MonthPlanCardModel with _$MonthPlanCardModel {
  const factory MonthPlanCardModel({
    required AllCategoryCardStatusType cardStatusType,
    required int allCategoryTotalExpense,
    required int allCategoryTotalBudget,
    required int allCategoryTotalIncome,
    required int allFixedCostExpense,
    required int denominator,
    required int realSavings,
    required double totalBadgetRatio,

    // 支出カテゴリー別のデータ
    required List<String> expenseCategoryNameList,
    required List<int> expenseCategoryList,
    required List<double> expenseCategoryRatioList,
    required List<String> expenseCategoryIconPathList,
    required List<String> expenseCategoryColorList,
    // 収入カテゴリー別のデータ
    required List<String> incomeCategoryNameList,
    required List<int> incomeCategoryList,
    required List<double> incomeCategoryRatioList,
    required List<String> incomeCategoryIconPathList,
    required List<String> incomeCategoryColorList,
  }) = _AllCategoryCardModel;
}
