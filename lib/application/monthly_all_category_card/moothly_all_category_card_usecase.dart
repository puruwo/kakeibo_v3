import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';

import 'package:kakeibo/domain/ui_value/category_card_value/all_category_card_value/all_category_card_entity.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_repository.dart';
import 'package:kakeibo/view_model/state/date_scope/entity/date_scope_entity.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final monthlyAllCategoryCardNotifierProvider = AsyncNotifierProvider.family<
    MonthlyAllCategoryTileUsecaseNotifier,
    AllCategoryCardModel,
    DateScopeEntity>(
  MonthlyAllCategoryTileUsecaseNotifier.new,
);

class MonthlyAllCategoryTileUsecaseNotifier
    extends FamilyAsyncNotifier<AllCategoryCardModel, DateScopeEntity> {
  late ExpenseRepository _expenseRepositoryProvider;
  late BudgetRepository _budgetRepositoryProvider;
  late IncomeRepository _incomeRepositoryProvider;
  late CategoryAccountingRepository _categoryAccountingRepositoryProvider;

  @override
  Future<AllCategoryCardModel> build(DateScopeEntity dateScope) async {
    // 初回生成時
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _expenseRepositoryProvider = ref.read(expenseRepositoryProvider);
    _budgetRepositoryProvider = ref.read(budgetRepositoryProvider);
    _incomeRepositoryProvider = ref.read(incomeRepositoryProvider);
    _categoryAccountingRepositoryProvider =
        ref.read(categoryAccountingRepositoryProvider);

    return fetch(dateScope: dateScope);
  }

  // 前カテゴリー合計のタイルデータを取得する
  Future<AllCategoryCardModel> fetch(
      {required DateScopeEntity dateScope}) async {
    // 選択した月の集計期間から開始日と終了日を取得する
    DateTime fromDate = dateScope.monthPeriod.startDatetime;
    DateTime toDate = dateScope.monthPeriod.endDatetime;

    // 全カテゴリーの予算を取得
    final allCategoryBudget = await _budgetRepositoryProvider.fetchMonthlyAll(
        month: dateScope.representativeMonth);

    // 全カテゴリーの支出を取得
    // 大カテゴリーIDを0にすることで、ボーナスを除くカテゴリーの支出を取得する
    final allCategoryExpense = await _expenseRepositoryProvider
        .fetchTotalExpenseByPeriodWithBigCategory(incomeSourceBigCategory: 0, fromDate: fromDate, toDate: toDate);

    // カテゴリータイルのリストを取得する
    final categoryEntityList = await _categoryAccountingRepositoryProvider
        .fetchAll(incomeSourceBigCategoryId: 0, fromDate: fromDate, toDate: toDate);

    // 大カテゴリーが何個あるか
    final categoryCount = categoryEntityList.length;
    // CategoryEntityから要素を取り出してリストにする
    final categoryIdList = categoryEntityList.map((e) => e.id).toList();
    final categoryNameList =
        categoryEntityList.map((e) => e.bigCategoryName).toList();
    final categoryExpenseList =
        categoryEntityList.map((e) => e.totalExpenseByBigCategory).toList();
    final categoryIconPathList =
        categoryEntityList.map((e) => e.categoryIconPath).toList();
    final categoryColorList =
        categoryEntityList.map((e) => e.categoryColor).toList();

    // 収入を取得
    final allCategoryIncome = await _incomeRepositoryProvider.calcurateSumWithPeriod(period: dateScope.monthPeriod);

    final AllCategoryCardStatusType cardStatusType =
        allCategoryBudget > 0
            ? AllCategoryCardStatusType.hasBudget
            : allCategoryIncome > 0
                ? AllCategoryCardStatusType.hasIncome
                : AllCategoryCardStatusType.noData;

    final denominator = cardStatusType == AllCategoryCardStatusType.hasBudget
        ? allCategoryBudget
        : allCategoryIncome;

    return AllCategoryCardModel(
      cardStatusType: cardStatusType,
      allCategoryTotalExpense: allCategoryExpense,
      allCategoryTotalBudget: allCategoryBudget,
      allCategoryTotalIncome: allCategoryIncome,
      realSavings: allCategoryIncome - allCategoryExpense,
      denominator: denominator,
      categoryCount: categoryCount,
      categoryIdList: categoryIdList,
      categoryNameList: categoryNameList,
      categoryExpenseList: categoryExpenseList,
      categoryIconPathList: categoryIconPathList,
      categoryColorList: categoryColorList,
    );
  }
}
