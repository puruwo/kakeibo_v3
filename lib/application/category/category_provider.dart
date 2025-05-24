import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/category_usecase.dart';
import 'package:kakeibo/domain/core/category_entity/expense_category_entity/expense_category_entity.dart';
import 'package:kakeibo/domain/ui_value/expense_big_category_with_small_list_value/edit_expense_big_category_value.dart';

// 全カテゴリーを保持するプロバイダー
final allCategoriesProvider = FutureProvider.autoDispose<List<ExpenseCategoryEntity>>(
    (ref) => ref.watch(categoryUsecaseProvider).fetchAll());

// 全カテゴリーを保持するプロバイダー
final allBigCategoriesWithSmallListProvider = FutureProvider.autoDispose<List<EditExpenseBigCategoryValue>>(
    (ref) => ref.watch(categoryUsecaseProvider).fetchAllBigCategoriesWithSmallList());
