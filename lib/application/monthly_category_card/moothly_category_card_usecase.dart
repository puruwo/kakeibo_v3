import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';

import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/category_card_entity.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_repository.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_repository.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final monthlyCategoryCardNotifierProvider = AsyncNotifierProvider.family<
    MonthlyCategoryCardUsecaseNotifier,
    List<CategoryCardEntity>,
    DateScopeEntity>(
  MonthlyCategoryCardUsecaseNotifier.new,
);

class MonthlyCategoryCardUsecaseNotifier
    extends FamilyAsyncNotifier<List<CategoryCardEntity>, DateScopeEntity> {
  late CategoryAccountingRepository _categoryAccountingRepositoryProvider;
  late SmallCategoryTileRepository _smallCategoryTileRepository;
  late BudgetRepository _budgetRepository;

  @override
  Future<List<CategoryCardEntity>> build(DateScopeEntity dateScope) async {
    // 初回生成時
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _categoryAccountingRepositoryProvider =
        ref.read(categoryAccountingRepositoryProvider);
    _smallCategoryTileRepository =
        ref.read(smallCategoryTileRepositoryProvider);
    _budgetRepository = ref.read(budgetRepositoryProvider);

    return fetch(dateScope);
  }

  Future<List<CategoryCardEntity>> fetch(DateScopeEntity dateScope) async {
    // 選択した月の集計期間から開始日と終了日を取得する
    DateTime fromDate = dateScope.monthPeriod.startDatetime;
    DateTime toDate = dateScope.monthPeriod.endDatetime;

    // 大カテゴリー(タイル情報つき)のリストを取得する
    final categoryList = await _categoryAccountingRepositoryProvider.fetchAll(
        incomeSourceBigCategoryId: 0, // ボーナスを除く
        fromDate: fromDate,
        toDate: toDate);

    // カテゴリータイルのリストの並び順でList<SmallCategoryTileExpenceEntity>を取得する
    List<CategoryCardEntity> categoryTileList = [];
    for (int i = 0; i < categoryList.length; i++) {
      // そのカテゴリーの予算を取得する
      final budget = await _budgetRepository.fetchMonthly(
          id: categoryList[i].id, month: dateScope.representativeMonth);

      // タイル内の小カテゴリーのリスト情報を取得する
      final smallCategoryList = await _smallCategoryTileRepository.fetchAll(
          incomeSourceBigCategoryId: 0, // ボーナスを除く
          bigCategoryId: categoryList[i].id,
          fromDate: fromDate,
          toDate: toDate);

      // そのカテゴリーの支出を取得する
      final expense = smallCategoryList
          .map((e) => e.totalExpenseBySmallCategory)
          .fold(0, (a, b) => a + b);

      // グラフのタイプを決定する
      final GraphType graphType = budget != 0
          ? expense > budget
              ? GraphType.hasBudgetButOver
              : GraphType.hasBudget
          : expense == 0
              ? GraphType.noExpenseNoBudget
              : GraphType.noBudgetOtherHasBudget;

      // グラフの比率を計算する
      final double graphRatio = graphType == GraphType.hasBudget
          ? graphType == GraphType.hasBudgetButOver
              ? 1
              : (expense / budget)
          : 0.0;

      final double? graphDenomiratorRatio =
          graphType == GraphType.hasBudget ? 1.0 : null;

      // カードのvalueに代入
      categoryTileList.add(CategoryCardEntity(
          graphType: graphType,
          graphRatio: graphRatio,
          graphDenomiratorRatio: graphDenomiratorRatio,
          monthlyBudget: budget,
          monthlyExpense: expense,
          monthlyExpenseByCategoryEntity: categoryList[i],
          smallCategoryList: smallCategoryList));
    }

    // 全てのカードで予算が設定されていなければ、最大の支出を取得し
    // それを基準にグラフの比率を再計算する
    bool isAllNoBudget = true;
    for (int i = 0; i < categoryTileList.length; i++) {
      if (categoryTileList[i].graphType == GraphType.hasBudget ||
          categoryTileList[i].graphType == GraphType.hasBudgetButOver) {
        isAllNoBudget = false;
        break;
      }
    }
    if (isAllNoBudget == true) {
      final maxExpense =
          categoryTileList.map((e) => e).fold(0, (temporaryMax, expense) {
        if (expense.monthlyExpense > temporaryMax) {
          temporaryMax = expense.monthlyExpense;
        }
        return temporaryMax;
      });

      for (int i = 0; i < categoryTileList.length; i++) {
        if (categoryTileList[i].graphType != GraphType.noExpenseNoBudget) {
          categoryTileList[i] = categoryTileList[i].copyWith(
            graphType: GraphType.allNoBudget,
            graphRatio: maxExpense > 0
                ? (categoryTileList[i].monthlyExpense / maxExpense)
                : 0,
          );
        }
      }
    }

    return categoryTileList;
  }
}
