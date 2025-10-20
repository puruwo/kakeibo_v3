import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

/// 固定費カテゴリー一覧を取得するProvider
final allFixedCostCategoriesProvider =
    FutureProvider.autoDispose<List<FixedCostCategoryEntity>>((ref) async {
  // DBが更新された場合に再取得
  ref.watch(updateDBCountNotifierProvider);

  final repository = ref.read(fixedCostCategoryRepositoryProvider);
  final categories = await repository.fetchAll();

  // displayOrder順にソート
  categories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

  return categories;
});
