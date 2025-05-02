import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/category_usecase.dart';
import 'package:kakeibo/domain/category_entity/category_entity.dart';

// 全カテゴリーを保持するプロバイダー
final categoryProvider = FutureProvider.autoDispose<List<CategoryEntity>>(
    (ref) => ref.watch(categoryUsecaseProvider).fetchAll());
