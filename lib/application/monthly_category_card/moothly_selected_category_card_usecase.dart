import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/monthly_category_card/request_moothly_category_card.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';

import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/category_card_entity.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_repository.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_repository.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

//  月ごとのカテゴリーカードの情報を取得するプロバイダ
//  このプロバイダは、選択されたカテゴリーに基づいてカテゴリーカードのリストを提供します。

final monthlySelectedCategoryCardNotifierProvider =
    AsyncNotifierProvider.family<MonthlySelectedCategoryCardUsecaseNotifier,
        CategoryCardEntity, RequestMonthlyCateoryCard>(
  MonthlySelectedCategoryCardUsecaseNotifier.new,
);

class MonthlySelectedCategoryCardUsecaseNotifier
    extends FamilyAsyncNotifier<CategoryCardEntity, RequestMonthlyCateoryCard> {
  late CategoryAccountingRepository _categoryAccountingRepositoryProvider;
  late SmallCategoryTileRepository _smallCategoryTileRepository;
  late BudgetRepository _budgetRepository;

  @override
  Future<CategoryCardEntity> build(RequestMonthlyCateoryCard request) async {
    // 初回生成時
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _categoryAccountingRepositoryProvider =
        ref.read(categoryAccountingRepositoryProvider);
    _smallCategoryTileRepository =
        ref.read(smallCategoryTileRepositoryProvider);
    _budgetRepository = ref.read(budgetRepositoryProvider);

    return fetch(request);
  }

  Future<CategoryCardEntity> fetch(RequestMonthlyCateoryCard request) async {
    // 選択した月の集計期間から開始日と終了日を取得する
    DateTime fromDate = request.dateScope.monthPeriod.startDatetime;
    DateTime toDate = request.dateScope.monthPeriod.endDatetime;

    // 大カテゴリー(タイル情報つき)の情報を取得する
    final accountingValue =
        await _categoryAccountingRepositoryProvider.fetchSelectedCategory(
            incomeSourceBigCategoryId: 0, // ボーナスを除く
            expenseBigCategoryId: request.bigId,
            fromDate: fromDate,
            toDate: toDate);

    // カテゴリータイルのリストの並び順でList<SmallCategoryTileExpenceEntity>を取得する

    // そのカテゴリーの予算を取得する
    final budget = await _budgetRepository.fetchMonthly(
        id: accountingValue.id, month: request.dateScope.representativeMonth);

    // タイル内の小カテゴリーのリスト情報を取得する
    final smallCategory = await _smallCategoryTileRepository.fetchAll(
        incomeSourceBigCategoryId: 0, // ボーナスを除く
        bigCategoryId: accountingValue.id,
        fromDate: fromDate,
        toDate: toDate);

    // グラフのタイプを決定する
    final GraphType graphType = budget != 0
        ? accountingValue.totalExpenseByBigCategory > budget
            ? GraphType.hasBudgetButOver
            : GraphType.hasBudget
        : GraphType.noBudget;

    // グラフの比率を計算する
    final double graphRatio = graphType == GraphType.hasBudget
        ? graphType == GraphType.hasBudgetButOver
            ? 1
            : (accountingValue.totalExpenseByBigCategory / budget)
        : 0.0;

    // グラフの分母比率を計算する
    final double graphDenomiratorRatio =
        graphType == GraphType.hasBudget ? 1.0 : 0.0;

    // カードのvalueに代入
    final result = CategoryCardEntity(
        graphType: graphType,
        graphRatio: graphRatio,
        graphDenomiratorRatio: graphDenomiratorRatio,
        monthlyExpense: accountingValue.totalExpenseByBigCategory,
        monthlyBudget: budget,
        monthlyExpenseByCategoryEntity: accountingValue,
        smallCategoryList: smallCategory);

    return result;
  }
}
