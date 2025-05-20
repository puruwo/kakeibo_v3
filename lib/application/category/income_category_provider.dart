import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/income_category_usecase.dart';
import 'package:kakeibo/domain/core/category_entity/income_category_entity/income_category_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';

// 全大カテゴリーを保持するプロバイダー
final allIncomeBigCategoryProvider = FutureProvider.autoDispose<List<IncomeBigCategoryEntity>>(
    (ref) => ref.watch(incomeCategoryUsecaseProvider).fetchAllBigCategory());


// 全カテゴリーを保持するプロバイダー
final allIncomeCategoryProvider = FutureProvider.autoDispose<List<IncomeCategoryEntity>>(
    (ref) => ref.watch(incomeCategoryUsecaseProvider).fetchAllCategory());

// カテゴリーを保持するプロバイダー
final anIncomeBigCategoryProvider = FutureProvider.family.autoDispose<IncomeBigCategoryEntity,int>(
    (ref,id) => ref.watch(incomeCategoryUsecaseProvider).fetchBigCategoryByBigId(id));

//  特定のカテゴリーを小カテゴリー指定で保持するプロバイダー
final anIncomeCategoryProvider = FutureProvider.family.autoDispose<IncomeCategoryEntity,int>(
    (ref,id) => ref.watch(incomeCategoryUsecaseProvider).fetchCategoryBySmallId(id));
