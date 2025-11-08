import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';

import 'package:kakeibo/domain/ui_value/category_card_value/all_category_card_value/all_category_card_entity.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_repository.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
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
  late FixedCostExpenseRepository _fixedCostExpenseRepositoryProvider;
  late FixedCostRepository _fixedCostRepositoryProvider;
  late FixedCostCategoryRepository _fixedCostCategoryRepositoryProvider;
  late BudgetRepository _budgetRepositoryProvider;
  late IncomeRepository _incomeRepositoryProvider;
  late CategoryAccountingRepository _categoryAccountingRepositoryProvider;

  @override
  Future<AllCategoryCardModel> build(DateScopeEntity dateScope) async {
    // 初回生成時
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _expenseRepositoryProvider = ref.read(expenseRepositoryProvider);
    _fixedCostExpenseRepositoryProvider =
        ref.read(fixedCostExpenseRepositoryProvider);
    _fixedCostRepositoryProvider = ref.read(fixedCostRepositoryProvider);
    _fixedCostCategoryRepositoryProvider =
        ref.read(fixedCostCategoryRepositoryProvider);
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

    // 支払いがある固定費の合計を取得
    // 支払額未定の固定費は推定額を使用する
    final confirmedFixedCostExpenseTotal =
        await _fixedCostExpenseRepositoryProvider
            .fetchTotalConfirmedFixedCostExpenseWithPeriod(
                period: dateScope.monthPeriod);
    final unconfirmedFixedCostList = await _fixedCostExpenseRepositoryProvider
        .fetchUnconfirmedFixedCostExpenseWithPeriod(
            period: dateScope.monthPeriod);
    final unconfirmedFixedCostEstimatedTotal = await Future.wait(
        unconfirmedFixedCostList.map((element) async {
      final estimatePrice = await _fixedCostRepositoryProvider
          .fetchEstimatedPriceById(id: element.fixedCostId);
      return estimatePrice;
    })).then((values) => values.fold<int>(
        0, (previousValue, estimatePrice) => previousValue + estimatePrice));

    // 全カテゴリーの支出を取得
    // 大カテゴリーIDを0にすることで、ボーナスを除くカテゴリーの支出を取得する
    final allCategoryExpense = await _expenseRepositoryProvider
        .fetchTotalExpenseByPeriodWithBigCategory(
            incomeSourceBigCategory:
                IncomeBigCategoryConstants.incomeSourceIdSalary,
            fromDate: fromDate,
            toDate: toDate);

    // ============================================
    // カテゴリータイルのリストを取得する
    final categoryEntityList =
        await _categoryAccountingRepositoryProvider.fetchAll(
            incomeSourceBigCategoryId: 0, fromDate: fromDate, toDate: toDate);

    // CategoryEntityから要素を取り出してリストにする
    List<String> categoryNameList =
        categoryEntityList.map((e) => e.bigCategoryName).toList();
    List<int> categoryExpenseList =
        categoryEntityList.map((e) => e.totalExpenseByBigCategory).toList();
    List<String> categoryIconPathList =
        categoryEntityList.map((e) => e.categoryIconPath).toList();
    List<String> categoryColorList =
        categoryEntityList.map((e) => e.categoryColor).toList();

    // 固定費のカテゴリーリストを取得する
    final fixedCostCategoryList =
        await _fixedCostCategoryRepositoryProvider.fetchAll();
    // 各カテゴリーの固定費を取得する
    for (var e in fixedCostCategoryList) {
      // 各カテゴリーの確定分固定費を取得する
      final confirmedFixedCostExpense =
          await _fixedCostExpenseRepositoryProvider
              .fetchTotalConfirmedFixedCostExpenseWithPeriodAndCategory(
                  period: dateScope.monthPeriod, fixedCostCategoryId: e.id);

      // 各カテゴリーの未確定固定費を取得する
      final unconfirmedFixedCostList = await _fixedCostExpenseRepositoryProvider
          .fetchUnconfirmedFixedCostExpenseWithPeriodAndCategory(
              period: dateScope.monthPeriod, fixedCostCategoryId: e.id);
      // 未確定支出に対して推定支出を取得する
      final unconfirmedFixedCostEstimated = await Future.wait(
          unconfirmedFixedCostList.map((element) async {
        final estimatePrice = await _fixedCostRepositoryProvider
            .fetchEstimatedPriceById(id: element.fixedCostId);
        return estimatePrice;
      })).then((values) => values.fold<int>(
          0, (previousValue, estimatePrice) => previousValue + estimatePrice));

      categoryNameList.add(e.categoryName);
      categoryExpenseList
          .add(confirmedFixedCostExpense + unconfirmedFixedCostEstimated);
      categoryIconPathList.add(e.resourcePath);
      categoryColorList.add(e.colorCode);
    }

    // ============================================

    // 収入を取得
    // ボーナス除くカテゴリーの収入のみ取得する
    final allCategoryIncome =
        await _incomeRepositoryProvider.calcurateSumWithBigCategoryAndPeriod(
            period: dateScope.monthPeriod,
            bigCategoryId: IncomeBigCategoryConstants.incomeSourceIdSalary);

    // 固定費も一般支出も全て足した支出
    final allCategoryTotalExpense = allCategoryExpense +
        confirmedFixedCostExpenseTotal +
        unconfirmedFixedCostEstimatedTotal;

    AllCategoryCardStatusType cardStatusType;
    if (allCategoryTotalExpense == 0 &&
        allCategoryIncome == 0 &&
        allCategoryBudget == 0) {
      cardStatusType = AllCategoryCardStatusType.noData;
    } else if (allCategoryIncome == 0 && allCategoryBudget == 0) {
      // 支出だけある
      cardStatusType = AllCategoryCardStatusType.hasOnlyExpense;
    } else if (allCategoryIncome != 0 && allCategoryBudget == 0) {
      // 収入だけある
      cardStatusType = AllCategoryCardStatusType.hasIncome;
    } else if (allCategoryIncome == 0 && allCategoryBudget != 0) {
      // 予算だけある
      cardStatusType = AllCategoryCardStatusType.hasBudget;
    } else {
      // 収入と予算の両方がある
      cardStatusType = AllCategoryCardStatusType.hasBudgetAndIncome;
    }

    final denominator = cardStatusType == AllCategoryCardStatusType.hasBudget
        ? allCategoryBudget
        : allCategoryIncome;

    return AllCategoryCardModel(
      cardStatusType: cardStatusType,
      allCategoryTotalExpense: allCategoryTotalExpense,
      allCategoryTotalBudget: allCategoryBudget,
      allCategoryTotalIncome: allCategoryIncome,
      allFixedCostExpense:
          confirmedFixedCostExpenseTotal + unconfirmedFixedCostEstimatedTotal,
      realSavings: allCategoryIncome - allCategoryTotalExpense,
      denominator: denominator,
      categoryNameList: categoryNameList,
      categoryExpenseList: categoryExpenseList,
      categoryIconPathList: categoryIconPathList,
      categoryColorList: categoryColorList,
    );
  }
}
