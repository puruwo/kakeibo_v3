import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';

import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/category_card_entity.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_repository.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_repository.dart';
import 'package:kakeibo/view_model/state/date_scope/entity/date_scope_entity.dart';
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

      // カードのvalueに代入
      categoryTileList.add(CategoryCardEntity(
          monthlyBudget: budget,
          monthlyExpenseByCategoryEntity: categoryList[i],
          smallCategoryList: smallCategoryList));
    }

    return categoryTileList;
  }
}
