import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_service.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';

import 'package:kakeibo/domain/ui_value/category_card_value/all_category_card_value/all_category_card_entity.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_repository.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final monthlyAllCategoryCardNotifierProvider = AsyncNotifierProvider.family<
    MonthlyAllCategoryTileUsecaseNotifier, MonthPlanCardModel, DateScopeEntity>(
  MonthlyAllCategoryTileUsecaseNotifier.new,
);

class MonthlyAllCategoryTileUsecaseNotifier
    extends FamilyAsyncNotifier<MonthPlanCardModel, DateScopeEntity> {
  late ExpenseRepository _expenseRepositoryProvider;
  late FixedCostExpenseRepository _fixedCostExpenseRepositoryProvider;
  late FixedCostRepository _fixedCostRepositoryProvider;
  late FixedCostCategoryRepository _fixedCostCategoryRepositoryProvider;
  late BudgetRepository _budgetRepositoryProvider;
  late IncomeRepository _incomeRepositoryProvider;
  late IncomeSmallCategoryRepository _incomeSmallCategoryRepositoryProvider;
  late CategoryAccountingRepository _categoryAccountingRepositoryProvider;

  @override
  Future<MonthPlanCardModel> build(DateScopeEntity dateScope) async {
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
    _incomeSmallCategoryRepositoryProvider =
        ref.read(incomeSmallCategoryRepositoryProvider);
    _categoryAccountingRepositoryProvider =
        ref.read(categoryAccountingRepositoryProvider);

    return fetch(dateScope: dateScope);
  }

  // 前カテゴリー合計のタイルデータを取得する
  Future<MonthPlanCardModel> fetch({required DateScopeEntity dateScope}) async {
    // 選択した月の集計期間から開始日と終了日を取得する
    DateTime fromDate = dateScope.monthPeriod.startDatetime;
    DateTime toDate = dateScope.monthPeriod.endDatetime;

    // 支払いがある固定費の合計を取得
    // 支払額未定の固定費は推定額を使用する
    final fixedCostTotal =
        await FixedCostService().getFixedCostTotal(ref, dateScope);

    // 全カテゴリーの支出を取得
    // 大カテゴリーIDを0にすることで、ボーナスを除くカテゴリーの支出を取得する
    final allCategoryExpense = await _expenseRepositoryProvider
        .fetchTotalExpenseByPeriodWithBigCategory(
            incomeSourceBigCategory:
                IncomeBigCategoryConstants.incomeSourceIdSalary,
            fromDate: fromDate,
            toDate: toDate);

    // 全カテゴリーの予算を取得
    final allNormalCategoryBudget = await _budgetRepositoryProvider
        .fetchMonthlyAll(month: dateScope.representativeMonth);

    final totalBudgetIncudeFixedCost = allNormalCategoryBudget + fixedCostTotal;

    final allBudget =
        allNormalCategoryBudget != 0 ? totalBudgetIncudeFixedCost : 0;

    // ============================================
    // カテゴリータイルのリストを取得する
    final categoryEntityList =
        await _categoryAccountingRepositoryProvider.fetchAll(
            incomeSourceBigCategoryId:
                IncomeBigCategoryConstants.incomeSourceIdSalary,
            fromDate: fromDate,
            toDate: toDate);

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
    final allCategoryTotalExpense = allCategoryExpense + fixedCostTotal;

    // ============================================
    // 棒グラフのタイプの最大値を決める
    // ============================================
    AllCategoryCardStatusType cardStatusType;
    int denominator;
    if (allCategoryTotalExpense == 0 &&
        allCategoryIncome == 0 &&
        allBudget == 0) {
      cardStatusType = AllCategoryCardStatusType.noData;
      denominator = 0;
    } else if (allCategoryIncome == 0 && allBudget == 0) {
      // 支出だけある
      cardStatusType = AllCategoryCardStatusType.hasOnlyExpense;
      denominator = allCategoryTotalExpense;
    } else if (allCategoryIncome != 0 && allBudget == 0) {
      // 収入だけある
      if (allCategoryIncome > allCategoryTotalExpense) {
        cardStatusType = AllCategoryCardStatusType.hasOnlyIncome;
        denominator = allCategoryIncome;
      } else {
        // 支出が収入をオーバーしている
        cardStatusType = AllCategoryCardStatusType.hasIncomeAndOver;
        denominator = allCategoryTotalExpense;
      }
    } else if (allCategoryIncome == 0 && allBudget != 0) {
      // 予算だけある
      if (allBudget > allCategoryTotalExpense) {
        cardStatusType = AllCategoryCardStatusType.hasOnlyBudget;
        denominator = allBudget;
      } else {
        // 支出が予算をオーバーしている
        cardStatusType = AllCategoryCardStatusType.hasBudgetAndOver;
        denominator = allCategoryTotalExpense;
      }
    } else {
      // 収入と予算の両方がある
      if (allBudget < allCategoryIncome &&
          allCategoryIncome < allCategoryTotalExpense) {
        // 予算も収入も設定されているが支出がオーバーしている(予算<収入<支出)
        cardStatusType = AllCategoryCardStatusType.hasBudgetIncomeExpenseOver;
        denominator = allCategoryTotalExpense;
      }
      if (allBudget < allCategoryTotalExpense &&
          allCategoryTotalExpense < allCategoryIncome) {
        // 予算も収入も設定されているが支出がオーバーしている(予算<支出<収入)
        cardStatusType = AllCategoryCardStatusType.hasBudgetExpenseIncomeOver;
        denominator = allCategoryIncome;
      }
      if (allCategoryIncome < allBudget &&
          allBudget < allCategoryTotalExpense) {
        // 予算も収入も設定されているが支出がオーバーしている(収入<予算<支出)
        cardStatusType = AllCategoryCardStatusType.hasIncomeBudgetExpenseOver;
        denominator = allCategoryTotalExpense;
      }
      if (allBudget < allCategoryTotalExpense &&
          allCategoryTotalExpense < allCategoryIncome) {
        // 予算も収入も設定されているが支出がオーバーしている(予算<支出<収入)
        cardStatusType = AllCategoryCardStatusType.hasIncomeBudgetExpenseOver;
        denominator = allCategoryIncome;
      } else {
        // 予算も収入も設定されており、支出は予算と収入をオーバーしていない
        cardStatusType = AllCategoryCardStatusType.hasBudgetAndIncomeNotOver;
        if (allBudget < allCategoryIncome) {
          denominator = allCategoryIncome;
        } else {
          denominator = allBudget;
        }
      }
    }

    // ============================================
    // 収入カテゴリー別の集計
    // ============================================

    // 収入小カテゴリー一覧を取得
    final incomeSmallCategoryList =
        await _incomeSmallCategoryRepositoryProvider.fetchAll();

    // カテゴリー別の収入を集計
    List<String> incomeCategoryNameList = [];
    List<int> incomeCategoryIncomeList = [];
    List<String> incomeCategoryIconPathList = [];
    List<String> incomeCategoryColorList = [];

    for (var category in incomeSmallCategoryList) {
      // ボーナスカテゴリー（bigCategoryKey = 1）は除外
      if (category.bigCategoryKey ==
          IncomeBigCategoryConstants.incomeSourceIdBonus) {
        continue;
      }

      // カテゴリー別の収入合計をrepository経由で取得
      final int totalIncome = await _incomeRepositoryProvider
          .calcurateSumWithSmallCategoryAndPeriod(
        period: dateScope.monthPeriod,
        smallCategoryId: category.id,
      );

      if (totalIncome > 0) {
        incomeCategoryNameList.add(category.smallCategoryName);
        incomeCategoryIncomeList.add(totalIncome);
        // 収入カテゴリーにはアイコンがないので、デフォルトのアイコンパスを設定
        incomeCategoryIconPathList
            .add('assets/images/category_icon/income.svg');
        // 収入カテゴリーにはカラーがないので、デフォルトカラーを設定
        incomeCategoryColorList.add('36C5F1');
      }
    }

    // ============================================
    // 棒グラフの長さを決める
    // ============================================

    // 支出と収入のグラフの長さを決める
    final totalBadgetRatio = allBudget / denominator;

    // 支出棒グラフのカテゴリーごとの比率を格納するリスト
    final List<double> categoryExpenseRatioList = [];
    for (int expense in categoryExpenseList) {
      final ratio = denominator != 0 ? expense / denominator : 0.0;
      categoryExpenseRatioList.add(ratio);
    }

    // 収入棒グラフのカテゴリーごとの比率を格納するリスト
    final List<double> incomeCategoryIncomeRatioList = [];
    for (int income in incomeCategoryIncomeList) {
      final ratio = denominator != 0 ? income / denominator : 0.0;
      incomeCategoryIncomeRatioList.add(ratio);
    }

    return MonthPlanCardModel(
      cardStatusType: cardStatusType,
      allCategoryTotalExpense: allCategoryTotalExpense,
      allCategoryTotalBudget: allBudget,
      allCategoryTotalIncome: allCategoryIncome,
      allFixedCostExpense: fixedCostTotal,
      realSavings: allCategoryIncome - allCategoryTotalExpense,
      denominator: denominator,
      totalBadgetRatio: totalBadgetRatio,
      expenseCategoryNameList: categoryNameList,
      expenseCategoryList: categoryExpenseList,
      expenseCategoryRatioList: categoryExpenseRatioList,
      expenseCategoryIconPathList: categoryIconPathList,
      expenseCategoryColorList: categoryColorList,
      incomeCategoryNameList: incomeCategoryNameList,
      incomeCategoryList: incomeCategoryIncomeList,
      incomeCategoryRatioList: incomeCategoryIncomeRatioList,
      incomeCategoryIconPathList: incomeCategoryIconPathList,
      incomeCategoryColorList: incomeCategoryColorList,
    );
  }
}
