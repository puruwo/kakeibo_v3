import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/income_category_usecase.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';

// 全カテゴリーを保持するプロバイダー
final incomeCategoryProvider = FutureProvider.autoDispose<List<IncomeBigCategoryEntity>>(
    (ref) => ref.watch(incomeCategoryUsecaseProvider).fetchAllBigCategory());

// カテゴリーを保持するプロバイダー
final anIncomeCategoryProvider = FutureProvider.family.autoDispose<IncomeBigCategoryEntity,int>(
    (ref,id) => ref.watch(incomeCategoryUsecaseProvider).fetchByBigCategory(id));
