import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/category_usecase.dart';
import 'package:kakeibo/domain/core/category_entity/expense_category_entity/expense_category_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/ui_value/edit_expense_small_category_list_value/edit_expense_small_category_value.dart';
import 'package:kakeibo/domain/ui_value/expense_big_category_with_small_list_value/edit_expense_big_category_value.dart';

// 大カテゴリーと小カテゴリーの両方を保持するプロバイダー
final allCategoriesProvider = FutureProvider.autoDispose<List<ExpenseCategoryEntity>>(
    (ref) => ref.watch(categoryUsecaseProvider).fetchAll());

// 大カテゴリーの一覧を保持するプロバイダー
final allBigCategoriesWithSmallListProvider = FutureProvider.autoDispose<List<EditExpenseBigCategoryValue>>(
    (ref) => ref.watch(categoryUsecaseProvider).fetchAllBigCategoriesWithSmallList());

// 全カテゴリーの一覧を保持するプロバイダー
final allSmallCategoriesListProvider = FutureProvider.family.autoDispose<List<EditExpenseSmallCategoryValue>,int>(
    (ref,bigId) => ref.watch(categoryUsecaseProvider).fetchSmallCategoriesByBig(bigId));

// 大カテゴリーを保持するプロバイダー
final bigCategoriesProvider = FutureProvider.family.autoDispose<ExpenseBigCategoryEntity,int>(
    (ref,bigId) => ref.watch(categoryUsecaseProvider).fetchBigCategory(bigId));
