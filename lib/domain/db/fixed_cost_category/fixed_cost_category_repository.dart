import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_entity.dart';

final fixedCostCategoryRepositoryProvider =
    Provider<FixedCostCategoryRepository>((ref) => throw UnimplementedError());

abstract class FixedCostCategoryRepository {
  Future<int> insert(FixedCostCategoryEntity entity);
  Future<List<FixedCostCategoryEntity>> fetchAll();
  Future<FixedCostCategoryEntity> fetch({required int id});
  Future<void> update(FixedCostCategoryEntity entity);
  Future<void> delete(int id);
}
