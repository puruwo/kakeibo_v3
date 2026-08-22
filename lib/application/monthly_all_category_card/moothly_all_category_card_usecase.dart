import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';

import 'package:kakeibo/domain/ui_value/category_card_value/all_category_card_value/all_category_card_entity.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_repository.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final monthlyAllCategoryCardNotifierProvider =
    AsyncNotifierProvider.family<
      MonthlyAllCategoryTileUsecaseNotifier,
      MonthPlanCardModel,
      DateScopeEntity
    >(MonthlyAllCategoryTileUsecaseNotifier.new);

class MonthlyAllCategoryTileUsecaseNotifier
    extends FamilyAsyncNotifier<MonthPlanCardModel, DateScopeEntity> {
  late ExpenseRepository _expenseRepositoryProvider;
  late BudgetRepository _budgetRepositoryProvider;
  late IncomeRepository _incomeRepositoryProvider;
  late IncomeBigCategoryRepository _incomeBigCategoryRepositoryProvider;
  late IncomeSmallCategoryRepository _incomeSmallCategoryRepositoryProvider;
  late CategoryAccountingRepository _categoryAccountingRepositoryProvider;

  @override
  Future<MonthPlanCardModel> build(DateScopeEntity dateScope) async {
    // 初回生成時
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _expenseRepositoryProvider = ref.read(expenseRepositoryProvider);
    _budgetRepositoryProvider = ref.read(budgetRepositoryProvider);
    _incomeRepositoryProvider = ref.read(incomeRepositoryProvider);
    _incomeBigCategoryRepositoryProvider = ref.read(
      incomeBigCategoryRepositoryProvider,
    );
    _incomeSmallCategoryRepositoryProvider = ref.read(
      incomeSmallCategoryRepositoryProvider,
    );
    _categoryAccountingRepositoryProvider = ref.read(
      categoryAccountingRepositoryProvider,
    );

    return fetch(dateScope: dateScope);
  }

  // 前カテゴリー合計のタイルデータを取得する
  Future<MonthPlanCardModel> fetch({required DateScopeEntity dateScope}) async {
    // 選択した月の集計期間から開始日と終了日を取得する
    DateTime fromDate = dateScope.aggregationMonthPeriod.startDatetime;
    DateTime toDate = dateScope.aggregationMonthPeriod.endDatetime;

    // 全カテゴリーの支出を取得
    // 拠出元=生活収支を指定して、特別枠充当を除くカテゴリーの支出を取得する
    final allCategoryExpense = await _expenseRepositoryProvider
        .fetchTotalExpenseByPeriodWithBigCategory(
          incomeSourceBigCategory: AccountTypeConstants.living,
          fromDate: fromDate,
          toDate: toDate,
        );

    // 全カテゴリーの予算を取得
    final allNormalCategoryBudget = await _budgetRepositoryProvider
        .fetchMonthlyAll(month: dateScope.representativeMonth);

    // 予算合計＝カテゴリー予算の合計のみ（固定費の自動加算は廃止。仕様 §7.3）
    // 移設カテゴリーに予算を設定できるようになったため、加算すると二重計上になる
    final allBudget = allNormalCategoryBudget;

    // ============================================
    // カテゴリータイルのリストを取得する
    final categoryEntityList = await _categoryAccountingRepositoryProvider
        .fetchAll(
          incomeSourceBigCategoryId: AccountTypeConstants.living,
          fromDate: fromDate,
          toDate: toDate,
        );

    // CategoryEntityから要素を取り出してリストにする
    List<String> categoryNameList = categoryEntityList
        .map((e) => e.bigCategoryName)
        .toList();
    List<int> categoryExpenseList = categoryEntityList
        .map((e) => e.totalExpenseByBigCategory)
        .toList();
    List<String> categoryIconPathList = categoryEntityList
        .map((e) => e.categoryIconPath)
        .toList();
    List<String> categoryColorList = categoryEntityList
        .map((e) => e.categoryColor)
        .toList();

    // ============================================

    // 収入を取得
    // 会計種別=生活収支のカテゴリーの収入のみ取得する（特別枠系を除く。ADR-025）
    final allCategoryIncome = await _incomeRepositoryProvider
        .calcurateSumWithAccountTypeAndPeriod(
          period: dateScope.aggregationMonthPeriod,
          accountType: AccountTypeConstants.living,
        );

    // 支出合計は expense の単一テーブル集計で完結する（固定費行も同じテーブル。仕様 §7.1）
    final allCategoryTotalExpense = allCategoryExpense;

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
      } else if (allBudget < allCategoryTotalExpense &&
          allCategoryTotalExpense < allCategoryIncome) {
        // 予算も収入も設定されているが支出がオーバーしている(予算<支出<収入)
        cardStatusType = AllCategoryCardStatusType.hasBudgetExpenseIncomeOver;
        denominator = allCategoryIncome;
      } else if (allCategoryIncome < allBudget &&
          allBudget < allCategoryTotalExpense) {
        // 予算も収入も設定されているが支出がオーバーしている(収入<予算<支出)
        cardStatusType = AllCategoryCardStatusType.hasIncomeBudgetExpenseOver;
        denominator = allCategoryTotalExpense;
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
    // 収入が大きすぎる場合のスケール調整 (KAN-25)
    // ============================================
    const int highIncomeThreshold = 300000;
    if (allCategoryIncome > highIncomeThreshold) {
      // ①予算が設定されていて、支出が予算をオーバーしている場合
      // → 支出を横幅全体スケールの1にする
      if (allBudget > 0 && allCategoryTotalExpense > allBudget) {
        denominator = allCategoryTotalExpense;
      }
      // ②予算が設定されておらず、収入が支出の4倍を超えている場合
      // → 支出を横幅全体スケールの1/2にする
      else if (allBudget == 0 &&
          allCategoryTotalExpense > 0 &&
          allCategoryIncome > allCategoryTotalExpense * 4) {
        denominator = allCategoryTotalExpense * 2;
      }
      // ③予算が設定されていて、収入が予算の5/3を超えている場合
      // → 予算を横幅全体スケールの3/5にする
      else if (allBudget > 0 && allCategoryIncome > allBudget * 5 / 3) {
        denominator = (allBudget * 5 / 3).round();
      }
    }

    // ============================================
    // 収入カテゴリー別の集計
    // ============================================

    // 収入小カテゴリー一覧を取得
    final incomeSmallCategoryList = await _incomeSmallCategoryRepositoryProvider
        .fetchAll();

    // 収入大カテゴリー一覧を取得し、ID→カラーコードのマップを構築
    final incomeBigCategoryList = await _incomeBigCategoryRepositoryProvider
        .fetchAll();
    final Map<int, String> incomeBigCategoryColorMap = {
      for (var bigCategory in incomeBigCategoryList)
        bigCategory.id: bigCategory.colorCode,
    };
    // ID→会計種別のマップ（特別枠系カテゴリーの内訳除外に使う。ADR-025）
    final Map<int, int> incomeBigCategoryAccountTypeMap = {
      for (var bigCategory in incomeBigCategoryList)
        bigCategory.id: bigCategory.accountType,
    };

    // カテゴリー別の収入を集計
    List<String> incomeCategoryNameList = [];
    List<int> incomeCategoryIncomeList = [];
    List<String> incomeCategoryIconPathList = [];
    List<String> incomeCategoryColorList = [];

    for (var category in incomeSmallCategoryList) {
      // 会計種別=生活収支のカテゴリーだけを内訳に含める（上の収入合計と同じ条件。ADR-025）
      // 大カテゴリーが解決できない場合も除外し、合計（SQL側で生活収支に限定）との
      // 不一致を起こさない
      if (incomeBigCategoryAccountTypeMap[category.bigCategoryKey] !=
          AccountTypeConstants.living) {
        continue;
      }

      // カテゴリー別の収入合計をrepository経由で取得
      final int totalIncome = await _incomeRepositoryProvider
          .calcurateSumWithSmallCategoryAndPeriod(
            period: dateScope.aggregationMonthPeriod,
            smallCategoryId: category.id,
          );

      if (totalIncome > 0) {
        incomeCategoryNameList.add(category.smallCategoryName);
        incomeCategoryIncomeList.add(totalIncome);
        // 収入カテゴリーにはアイコンがないので、デフォルトのアイコンパスを設定
        incomeCategoryIconPathList.add(
          'assets/images/category_icon/income.svg',
        );
        // 親大カテゴリーのカラーコードを適用
        incomeCategoryColorList.add(
          incomeBigCategoryColorMap[category.bigCategoryKey] ?? '',
        );
      }
    }

    // ============================================
    // 予算カテゴリー別の集計
    // ============================================
    List<String> budgetCategoryNameList = [];
    List<int> budgetCategoryAmountList = [];
    List<String> budgetCategoryIconPathList = [];
    List<String> budgetCategoryColorList = [];

    // 一般カテゴリーの予算を取得
    for (var category in categoryEntityList) {
      final budgetEntity = await _budgetRepositoryProvider
          .fetchMonthlyByBigCategory(
            month: dateScope.representativeMonth,
            expenseBigCategoryId: category.id,
          );
      if (budgetEntity.price > 0) {
        budgetCategoryNameList.add(category.bigCategoryName);
        budgetCategoryAmountList.add(budgetEntity.price);
        budgetCategoryIconPathList.add(category.categoryIconPath);
        budgetCategoryColorList.add(category.categoryColor);
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
      // 固定費セグメントは廃止したため常に0（フィールド自体の除去はT5）
      allFixedCostExpense: 0,
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
      budgetCategoryNameList: budgetCategoryNameList,
      budgetCategoryList: budgetCategoryAmountList,
      budgetCategoryIconPathList: budgetCategoryIconPathList,
      budgetCategoryColorList: budgetCategoryColorList,
    );
  }
}
