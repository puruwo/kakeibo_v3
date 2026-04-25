import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/income_category_usecase.dart';
import 'package:kakeibo/domain/core/category_entity/income_category_entity/income_category_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/ui_value/edit_income_small_category_list_value/edit_income_small_category_value.dart';
import 'package:kakeibo/domain/ui_value/income_big_category_value/edit_income_big_category_value.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

// 全大カテゴリーを保持するプロバイダー
final allIncomeBigCategoriesProvider =
    FutureProvider.autoDispose<List<IncomeBigCategoryEntity>>((ref) {
  ref.watch(updateDBCountNotifierProvider);
  return ref.watch(incomeCategoryUsecaseProvider).fetchAllBigCategory();
});

// 全大カテゴリー＋小カテゴリーリストのプロバイダー
final allIncomeBigCategoriesWithSmallListProvider =
    FutureProvider.autoDispose<List<EditIncomeBigCategoryValue>>((ref) {
  ref.watch(updateDBCountNotifierProvider);
  return ref
      .watch(incomeCategoryUsecaseProvider)
      .fetchAllBigCategoriesWithSmallList();
});

// 全カテゴリーを保持するプロバイダー
final allIncomeCategoriesProvider =
    FutureProvider.autoDispose<List<IncomeCategoryEntity>>((ref) {
  ref.watch(updateDBCountNotifierProvider);
  return ref.watch(incomeCategoryUsecaseProvider).fetchAllCategory();
});

// カテゴリーを保持するプロバイダー
final anIncomeBigCategoryProvider =
    FutureProvider.family.autoDispose<IncomeBigCategoryEntity, int>((ref, id) {
  ref.watch(updateDBCountNotifierProvider);
  return ref.watch(incomeCategoryUsecaseProvider).fetchBigCategoryByBigId(id);
});

//  特定のカテゴリーを小カテゴリー指定で保持するプロバイダー
final anIncomeCategoryProvider =
    FutureProvider.family.autoDispose<IncomeCategoryEntity, int>((ref, id) {
  ref.watch(updateDBCountNotifierProvider);
  return ref.watch(incomeCategoryUsecaseProvider).fetchCategoryBySmallId(id);
});

// 大カテゴリー指定で小カテゴリーリストを取得するプロバイダー
final allIncomeSmallCategoriesListProvider = FutureProvider.family
    .autoDispose<List<EditIncomeSmallCategoryValue>, int>((ref, bigId) {
  ref.watch(updateDBCountNotifierProvider);
  return ref
      .watch(incomeCategoryUsecaseProvider)
      .fetchSmallCategoriesByBig(bigId);
});
