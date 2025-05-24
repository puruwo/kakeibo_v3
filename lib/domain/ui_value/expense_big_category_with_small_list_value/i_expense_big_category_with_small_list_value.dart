import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';

// SmallCategoryのListを加えた大カテゴリーの抽象型
abstract class IExpenseBigCategoryValueWithSmallList {
  int get id;
  String get colorCode;
  String get bigCategoryName;
  String get resourcePath;
  int get displayOrder;
  int get isDisplayed;
  List<ExpenseSmallCategoryEntity> get expenseSmallCategoryList;
}
