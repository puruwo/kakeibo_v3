import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/logger.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';

class ImplementsFixedCostExpenseRepository
    implements FixedCostExpenseRepository {
  @override
  Future<int> insert(FixedCostExpenseEntity entity) async {
    final id = await DatabaseHelper.instance.insert(
      SqfFixedCostExpense.tableName,
      {
        SqfFixedCostExpense.fixedCostId: entity.fixedCostId,
        SqfFixedCostExpense.fixedCostCategoryId: entity.fixedCostCategoryId,
        SqfFixedCostExpense.date: entity.date,
        SqfFixedCostExpense.price: entity.price,
        SqfFixedCostExpense.name: entity.name,
        SqfFixedCostExpense.confirmedCostType: entity.confirmedCostType,
        SqfFixedCostExpense.isConfirmed: entity.isConfirmed,
      },
    );
    return id;
  }

  @override
  Future<List<FixedCostExpenseEntity>> fetchAll() async {
    const sql = '''
      SELECT
        ${SqfFixedCostExpense.id} as id,
        ${SqfFixedCostExpense.fixedCostId} as fixedCostId,
        ${SqfFixedCostExpense.fixedCostCategoryId} as fixedCostCategoryId,
        ${SqfFixedCostExpense.date} as date,
        ${SqfFixedCostExpense.price} as price,
        ${SqfFixedCostExpense.name} as name,
        ${SqfFixedCostExpense.confirmedCostType} as confirmedCostType,
        ${SqfFixedCostExpense.isConfirmed} as isConfirmed
      FROM ${SqfFixedCostExpense.tableName}
    ''';
    final result = await DatabaseHelper.instance.query(sql);
    return result.map((e) => FixedCostExpenseEntity.fromJson(e)).toList();
  }

  @override
  Future<List<FixedCostExpenseEntity>> fetchByPeriod(
      {required PeriodValue period}) async {
    final sql = '''
      SELECT
        ${SqfFixedCostExpense.id} as id,
        ${SqfFixedCostExpense.fixedCostId} as fixedCostId,
        ${SqfFixedCostExpense.fixedCostCategoryId} as fixedCostCategoryId,
        ${SqfFixedCostExpense.date} as date,
        ${SqfFixedCostExpense.price} as price,
        ${SqfFixedCostExpense.name} as name,
        ${SqfFixedCostExpense.confirmedCostType} as confirmedCostType,
        ${SqfFixedCostExpense.isConfirmed} as isConfirmed
      FROM ${SqfFixedCostExpense.tableName}
      WHERE ${SqfFixedCostExpense.date} >= '${period.startDatetime.toIso8601String().substring(0, 10).replaceAll('-', '')}'
      AND ${SqfFixedCostExpense.date} <= '${period.endDatetime.toIso8601String().substring(0, 10).replaceAll('-', '')}'
      ORDER BY ${SqfFixedCostExpense.date} DESC
    ''';
    final result = await DatabaseHelper.instance.query(sql);
    return result.map((e) => FixedCostExpenseEntity.fromJson(e)).toList();
  }

  @override
  Future<List<FixedCostExpenseEntity>> fetchByFixedCostId(
      {required int fixedCostId}) async {
    final sql = '''
      SELECT
        ${SqfFixedCostExpense.id} as id,
        ${SqfFixedCostExpense.fixedCostId} as fixedCostId,
        ${SqfFixedCostExpense.fixedCostCategoryId} as fixedCostCategoryId,
        ${SqfFixedCostExpense.date} as date,
        ${SqfFixedCostExpense.price} as price,
        ${SqfFixedCostExpense.name} as name,
        ${SqfFixedCostExpense.confirmedCostType} as confirmedCostType,
        ${SqfFixedCostExpense.isConfirmed} as isConfirmed
      FROM ${SqfFixedCostExpense.tableName}
      WHERE ${SqfFixedCostExpense.fixedCostCategoryId} = $fixedCostId
    ''';
    final result = await DatabaseHelper.instance.query(sql);
    return result.map((e) => FixedCostExpenseEntity.fromJson(e)).toList();
  }

  @override
  Future<void> update(FixedCostExpenseEntity entity) async {
    await DatabaseHelper.instance.update(
      SqfFixedCostExpense.tableName,
      {
        SqfFixedCostExpense.fixedCostId: entity.fixedCostId,
        SqfFixedCostExpense.fixedCostCategoryId: entity.fixedCostCategoryId,
        SqfFixedCostExpense.date: entity.date,
        SqfFixedCostExpense.price: entity.price,
        SqfFixedCostExpense.name: entity.name,
        SqfFixedCostExpense.confirmedCostType: entity.confirmedCostType,
        SqfFixedCostExpense.isConfirmed: entity.isConfirmed,
      },
      entity.id,
    );
  }

  @override
  Future<void> delete(int id) async {
    await DatabaseHelper.instance.delete(
      SqfFixedCostExpense.tableName,
      id,
    );
  }

  @override
  Future<int> fetchTotalConfirmedFixedCostExpenseWithPeriod(
      {required PeriodValue period}) async {
    final sql = '''
      SELECT COALESCE(SUM(${SqfFixedCostExpense.price}), 0) as total
      FROM ${SqfFixedCostExpense.tableName}
      WHERE ${SqfFixedCostExpense.date} >= '${period.startDatetime.toIso8601String().substring(0, 10).replaceAll('-', '')}'
      AND ${SqfFixedCostExpense.date} <= '${period.endDatetime.toIso8601String().substring(0, 10).replaceAll('-', '')}'
      AND ${SqfFixedCostExpense.isConfirmed} = 1
    ''';
    final result = await DatabaseHelper.instance.query(sql);
    if (result.isEmpty) {
      return 0;
    }
    return (result.first['total'] as num).toInt();
  }

  @override
  Future<List<FixedCostExpenseEntity>> fetchUnconfirmedFixedCostExpenseWithPeriod(
      {required PeriodValue period}) async {
    final sql = '''
      SELECT
        ${SqfFixedCostExpense.id} as id,
        ${SqfFixedCostExpense.fixedCostId} as fixedCostId,
        ${SqfFixedCostExpense.fixedCostCategoryId} as fixedCostCategoryId,
        ${SqfFixedCostExpense.date} as date,
        ${SqfFixedCostExpense.price} as price,
        ${SqfFixedCostExpense.name} as name,
        ${SqfFixedCostExpense.confirmedCostType} as confirmedCostType,
        ${SqfFixedCostExpense.isConfirmed} as isConfirmed
      FROM ${SqfFixedCostExpense.tableName}
      WHERE ${SqfFixedCostExpense.date} >= '${period.startDatetime.toIso8601String().substring(0, 10).replaceAll('-', '')}'
      AND ${SqfFixedCostExpense.date} <= '${period.endDatetime.toIso8601String().substring(0, 10).replaceAll('-', '')}'
      AND ${SqfFixedCostExpense.isConfirmed} = 0
      ORDER BY ${SqfFixedCostExpense.date} DESC
    ''';
    final result = await DatabaseHelper.instance.query(sql);
    return result.map((e) => FixedCostExpenseEntity.fromJson(e)).toList();
  }

  @override
  Future<void> confirmExpense({required int id, required int price}) async {
    final entity = await _fetchById(id);
    final updatedEntity = entity.copyWith(
      price: price,
      isConfirmed: 1,
    );
    await update(updatedEntity);
  }

  Future<FixedCostExpenseEntity> _fetchById(int id) async {
    final sql = '''
      SELECT
        ${SqfFixedCostExpense.id} as id,
        ${SqfFixedCostExpense.fixedCostId} as fixedCostId,
        ${SqfFixedCostExpense.fixedCostCategoryId} as fixedCostCategoryId,
        ${SqfFixedCostExpense.date} as date,
        ${SqfFixedCostExpense.price} as price,
        ${SqfFixedCostExpense.name} as name,
        ${SqfFixedCostExpense.confirmedCostType} as confirmedCostType,
        ${SqfFixedCostExpense.isConfirmed} as isConfirmed
      FROM ${SqfFixedCostExpense.tableName}
      WHERE ${SqfFixedCostExpense.id} = $id
    ''';
    final result = await DatabaseHelper.instance.query(sql);
    if (result.isEmpty) {
      throw Exception('FixedCostExpense not found with id: $id');
    }
    return FixedCostExpenseEntity.fromJson(result.first);
  }

  @override
  Future<double> fetchFixedCostEstimatedPriceById(
      {required int fixedCostId}) async {
    final sql = '''
      SELECT AVG(${SqfFixedCostExpense.price}) as avg_price
      FROM ${SqfFixedCostExpense.tableName}
      WHERE ${SqfFixedCostExpense.fixedCostId} = $fixedCostId
      AND ${SqfFixedCostExpense.isConfirmed} = 1
    ''';
    final result = await DatabaseHelper.instance.query(sql);
    if (result.isEmpty || result.first['avg_price'] == null) {
      return 0.0;
    }
    return (result.first['avg_price'] as num).toDouble();
  }

  @override
  Future<int> fetchDailyFixedCostExpenseByPeriod(
      {required DateTime date}) async {
    final sql = '''
      SELECT
        SUM(${SqfFixedCostExpense.price}) AS sum_price_daily
      FROM ${SqfFixedCostExpense.tableName}
      WHERE ${SqfFixedCostExpense.date} = '${date.toIso8601String().substring(0, 10).replaceAll('-', '')}'
      GROUP BY ${SqfFixedCostExpense.date}
      ORDER BY ${SqfFixedCostExpense.date} ASC
    ''';
    try {
      final sum = await DatabaseHelper.instance.queryFirstIntValue(sql);
      return sum ?? 0;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return 0;
    }
  }
}
