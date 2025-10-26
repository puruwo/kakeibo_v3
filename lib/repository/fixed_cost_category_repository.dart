import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';

class ImplementsFixedCostCategoryRepository
    implements FixedCostCategoryRepository {
  @override
  Future<int> insert(FixedCostCategoryEntity entity) async {
    final id = await DatabaseHelper.instance.insert(
      SqfFixedCostCategory.tableName,
      {
        SqfFixedCostCategory.categoryName: entity.categoryName,
        SqfFixedCostCategory.colorCode: entity.colorCode,
        SqfFixedCostCategory.resourcePath: entity.resourcePath,
        SqfFixedCostCategory.displayOrder: entity.displayOrder,
        SqfFixedCostCategory.isDisplayed: entity.isDisplayed,
      },
    );
    return id;
  }

  @override
  Future<List<FixedCostCategoryEntity>> fetchAll() async {
    const sql = '''
      SELECT
        ${SqfFixedCostCategory.id} as id,
        ${SqfFixedCostCategory.categoryName} as categoryName,
        ${SqfFixedCostCategory.colorCode} as colorCode,
        ${SqfFixedCostCategory.resourcePath} as resourcePath,
        ${SqfFixedCostCategory.displayOrder} as displayOrder,
        ${SqfFixedCostCategory.isDisplayed} as isDisplayed
      FROM ${SqfFixedCostCategory.tableName}
    ''';
    final result = await DatabaseHelper.instance.query(sql);
    return result.map((e) => FixedCostCategoryEntity.fromJson(e)).toList();
  }

  @override
  Future<FixedCostCategoryEntity> fetch({required int id}) async {
    final sql = '''
      SELECT
        ${SqfFixedCostCategory.id} as id,
        ${SqfFixedCostCategory.categoryName} as categoryName,
        ${SqfFixedCostCategory.colorCode} as colorCode,
        ${SqfFixedCostCategory.resourcePath} as resourcePath,
        ${SqfFixedCostCategory.displayOrder} as displayOrder,
        ${SqfFixedCostCategory.isDisplayed} as isDisplayed
      FROM ${SqfFixedCostCategory.tableName}
      WHERE ${SqfFixedCostCategory.id} = $id
    ''';
    final result = await DatabaseHelper.instance.query(sql);
    if (result.isEmpty) {
      throw Exception('FixedCostCategory not found with id: $id');
    }
    return FixedCostCategoryEntity.fromJson(result.first);
  }

  @override
  Future<void> update(FixedCostCategoryEntity entity) async {
    await DatabaseHelper.instance.update(
      SqfFixedCostCategory.tableName,
      {
        SqfFixedCostCategory.categoryName: entity.categoryName,
        SqfFixedCostCategory.colorCode: entity.colorCode,
        SqfFixedCostCategory.resourcePath: entity.resourcePath,
        SqfFixedCostCategory.displayOrder: entity.displayOrder,
        SqfFixedCostCategory.isDisplayed: entity.isDisplayed,
      },
      entity.id,
    );
  }

  @override
  Future<void> delete(int id) async {
    await DatabaseHelper.instance.delete(
      SqfFixedCostCategory.tableName,
      id,
    );
  }
}
