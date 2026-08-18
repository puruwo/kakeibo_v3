import 'package:kakeibo/application/category/category_provider.dart';
import 'package:kakeibo/application/category/category_usecase.dart';
import 'package:kakeibo/application/category/income_category_provider.dart';
import 'package:kakeibo/application/category/income_category_usecase.dart';
import 'package:kakeibo/application/fixed_cost_category/fixed_cost_category_provider.dart';
import 'package:kakeibo/application/fixed_cost_category/fixed_cost_category_usecase.dart';
import 'package:kakeibo/domain/core/category_entity/expense_category_entity/expense_category_entity.dart';
import 'package:kakeibo/domain/core/category_entity/i_category_entity.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_selection_provider.g.dart';

/// TransactionModeに応じたカテゴリーを取得するProvider
///
/// [mode] トランザクションの種類（支出、固定費、収入）
/// [categoryId] カテゴリーID
@riverpod
Future<ICategoryEntity> categoryByMode(
  CategoryByModeRef ref, {
  required TransactionMode mode,
  required int categoryId,
}) async {
  // categoryIdが0以下（未選択）の場合は最初のカテゴリーを返す
  if (categoryId <= 0) {
    final categories = await ref.watch(categoriesByModeProvider(mode).future);
    if (categories.isNotEmpty) {
      return categories.first;
    }
    // カテゴリーが1件も無いときは「未選択」のまま返す。
    // ID 0のままマスタ検索へ進むと該当レコードが無く例外になり、
    // 呼び出し元（CategoryArea）はその例外を表示する経路を持たないため。
    return _unselectedCategory;
  }

  return switch (mode) {
    TransactionMode.expense =>
      await ref.watch(categoryUsecaseProvider).fetchBySmallId(categoryId),
    TransactionMode.fixedCost => await ref
        .watch(fixedCostCategoryUsecaseProvider)
        .fetchCategoryById(categoryId),
    TransactionMode.income => await ref
        .watch(incomeCategoryUsecaseProvider)
        .fetchCategoryBySmallId(categoryId),
  };
}

/// カテゴリーが1件も無いときに返す「未選択」カテゴリー
///
/// 選択状態の初期値（SelectCategoryControllerNotifier.build）と同じ空エンティティ。
/// id が 0 なので、この状態のまま保存しようとすると各Usecaseの入口で弾かれる。
const ICategoryEntity _unselectedCategory = ExpenseCategoryEntity(
  smallCategoryOrderKey: -1,
  bigCategoryKey: -1,
  displaydOrderInBig: -1,
  categoryName: '',
  defaultDisplayed: -1,
  bigCategoryName: '',
  colorCode: '',
  resourcePath: '',
  displayOrder: -1,
  isDisplayed: -1,
);

/// TransactionModeに応じたカテゴリーリストを取得するProvider
///
/// [mode] トランザクションの種類（支出、固定費、収入）
@riverpod
Future<List<ICategoryEntity>> categoriesByMode(
  CategoriesByModeRef ref,
  TransactionMode mode,
) async {
  return switch (mode) {
    TransactionMode.expense => await ref.watch(allCategoriesProvider.future),
    TransactionMode.fixedCost =>
      await ref.watch(allFixedCostCategoriesProvider.future),
    TransactionMode.income =>
      await ref.watch(allIncomeCategoriesProvider.future),
  };
}

/// ページネーション情報を計算するProvider
///
/// [categoryCount] カテゴリーの総数
@riverpod
CategoryPagination categoryPagination(
  CategoryPaginationRef ref,
  int categoryCount,
) {
  const itemsPerPage = 15;
  return CategoryPagination(
    pageCount: (categoryCount / itemsPerPage).ceil(),
    itemsPerPage: itemsPerPage,
  );
}

/// ボタンの状態を判定するユーティリティ関数
///
/// Provider内で使用することも、直接呼び出すことも可能
ButtonStatus getButtonStatus({
  required int buttonNumber,
  required int categoryCount,
  required int selectedCategoryId,
  required List<ICategoryEntity> categories,
}) {
  // カテゴリー数の範囲外ならnone
  if (buttonNumber >= categoryCount) {
    return ButtonStatus.none;
  }
  // 選択中のカテゴリーと一致する場合はselected
  if (categories[buttonNumber].id == selectedCategoryId) {
    return ButtonStatus.selected;
  }
  // その他はnormal
  return ButtonStatus.normal;
}
