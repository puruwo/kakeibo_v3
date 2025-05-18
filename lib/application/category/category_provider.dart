import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/category_usecase.dart';
import 'package:kakeibo/domain/core/category_entity/expense_category_entity/expense_category_entity.dart';

// 全カテゴリーを保持するプロバイダー
final categoryProvider = FutureProvider.autoDispose<List<ExpenseCategoryEntity>>(
    (ref) => ref.watch(categoryUsecaseProvider).fetchAll());
