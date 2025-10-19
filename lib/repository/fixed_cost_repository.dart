import 'package:intl/intl.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/logger.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsFixedCostRepository implements FixedCostRepository {
  // 全ての固定費情報を取得する
  @override
  Future<List<FixedCostEntity>> fetchAll() async {
    const sql = '''
      SELECT 
        a.${SqfFixedCost.id} AS id,
        a.${SqfFixedCost.name} AS name, 
        a.${SqfFixedCost.variable} AS variable,
        a.${SqfFixedCost.price} AS price, 
        a.${SqfFixedCost.estimatedPrice} AS estimatedPrice,
        a.${SqfFixedCost.fixedCostCategoryId} AS fixedCostCategoryId,
        a.${SqfFixedCost.intervalNumber} AS intervalNumber,
        a.${SqfFixedCost.intervalUnit} AS intervalUnit,
        a.${SqfFixedCost.firstPaymentDate} AS firstPaymentDate,
        a.${SqfFixedCost.recentPaymentDate} AS recentPaymentDate,
        a.${SqfFixedCost.nextPaymentDate} AS nextPaymentDate,
        a.${SqfFixedCost.deleteFlag} AS deleteFlag
      FROM ${SqfFixedCost.tableName} a
      ORDER BY a.${SqfFixedCost.id} ASC;
    ''';

    try {
      final jsonList = await db.query(sql);
      final results =
          jsonList.map((json) => FixedCostEntity.fromJson(json)).toList();

      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return [];
    }
  }

  // 固定費情報をID指定で取得する
  @override
  Future<FixedCostEntity> fetch({required int fixedCostId}) async {
    final sql = '''
      SELECT 
        a.${SqfFixedCost.id} AS id,
        a.${SqfFixedCost.name} AS name, 
        a.${SqfFixedCost.variable} AS variable,
        a.${SqfFixedCost.price} AS price, 
        a.${SqfFixedCost.estimatedPrice} AS estimatedPrice,
        a.${SqfFixedCost.fixedCostCategoryId} AS fixedCostCategoryId,
        a.${SqfFixedCost.intervalNumber} AS intervalNumber,
        a.${SqfFixedCost.intervalUnit} AS intervalUnit,
        a.${SqfFixedCost.firstPaymentDate} AS firstPaymentDate,
        a.${SqfFixedCost.recentPaymentDate} AS recentPaymentDate,
        a.${SqfFixedCost.nextPaymentDate} AS nextPaymentDate,
        a.${SqfFixedCost.deleteFlag} AS deleteFlag
      FROM ${SqfFixedCost.tableName} a
      WHERE a.${SqfFixedCost.id} = $fixedCostId
      ORDER BY a.${SqfFixedCost.id} ASC;
    ''';

    try {
      final jsonList = await db.query(sql);
      final result = FixedCostEntity.fromJson(jsonList[0]);
      return result;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return const FixedCostEntity(
        id: 0,
        name: '',
        variable: 0,
        price: 0,
        fixedCostCategoryId: 0,
        intervalNumber: 0,
        intervalUnit: 0,
        firstPaymentDate: '',
        recentPaymentDate: null,
        nextPaymentDate: null,
        deleteFlag: 0,
      );
    }
  }

  // 次の支払い期間に含まれるレコードを取得する
  @override
  Future<List<FixedCostEntity>> fetchNextPeriodPayment(
      {required PeriodValue period}) async {
    final sql = '''
      SELECT 
        a.${SqfFixedCost.id} AS id,
        a.${SqfFixedCost.name} AS name, 
        a.${SqfFixedCost.variable} AS variable,
        a.${SqfFixedCost.price} AS price, 
        a.${SqfFixedCost.estimatedPrice} AS estimatedPrice,
        a.${SqfFixedCost.fixedCostCategoryId} AS fixedCostCategoryId,
        a.${SqfFixedCost.intervalNumber} AS intervalNumber,
        a.${SqfFixedCost.intervalUnit} AS intervalUnit,
        a.${SqfFixedCost.firstPaymentDate} AS firstPaymentDate,
        a.${SqfFixedCost.recentPaymentDate} AS recentPaymentDate,
        a.${SqfFixedCost.nextPaymentDate} AS nextPaymentDate,
        a.${SqfFixedCost.deleteFlag} AS deleteFlag
      FROM ${SqfFixedCost.tableName} a
      WHERE a.${SqfFixedCost.nextPaymentDate} >= ${DateFormat('yyyyMMdd').format(period.startDatetime)} AND a.${SqfFixedCost.nextPaymentDate} <= ${DateFormat('yyyyMMdd').format(period.endDatetime)}
      ORDER BY a.${SqfFixedCost.id} DESC;
    ''';

  

    try {
      final jsonList = await db.query(sql);
      final results =
          jsonList.map((json) => FixedCostEntity.fromJson(json)).toList();

      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return [];
    }
  }

  // idを指定して、変動あり固定費の推定支出合計を取得する
  @override
  Future<int> fetchEstimatedPriceById(
      {required int id}) async {
    final sql = '''
      SELECT SUM(a.${SqfFixedCost.estimatedPrice}) AS estimatedPrice
      FROM ${SqfFixedCost.tableName} a
      WHERE a.${SqfFixedCost.id} = $id;
    ''';
    try {
      final result = await db.queryFirstIntValue(sql);
      return result ?? 0;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return 0;
    }
  }

  @override
  Future<int> insert(FixedCostEntity fixedCostEntity) async {
    final id = db.insert(SqfFixedCost.tableName, {
      SqfFixedCost.name: fixedCostEntity.name,
      SqfFixedCost.variable: fixedCostEntity.variable,
      SqfFixedCost.price: fixedCostEntity.price,
      SqfFixedCost.estimatedPrice: fixedCostEntity.estimatedPrice,
      SqfFixedCost.fixedCostCategoryId:
          fixedCostEntity.fixedCostCategoryId,
      SqfFixedCost.intervalNumber: fixedCostEntity.intervalNumber,
      SqfFixedCost.intervalUnit: fixedCostEntity.intervalUnit,
      SqfFixedCost.firstPaymentDate: fixedCostEntity.firstPaymentDate,
      SqfFixedCost.recentPaymentDate: fixedCostEntity.recentPaymentDate,
      SqfFixedCost.nextPaymentDate: fixedCostEntity.nextPaymentDate,
      SqfFixedCost.deleteFlag: fixedCostEntity.deleteFlag,
    });
    return id;
  }

  @override
  Future<void> update(FixedCostEntity fixedCostEntity) async {
    final result = await db.update(
        SqfFixedCost.tableName,
        {
          SqfFixedCost.name: fixedCostEntity.name,
          SqfFixedCost.variable: fixedCostEntity.variable,
          SqfFixedCost.price: fixedCostEntity.price,
          SqfFixedCost.estimatedPrice: fixedCostEntity.estimatedPrice,
          SqfFixedCost.fixedCostCategoryId:
              fixedCostEntity.fixedCostCategoryId,
          SqfFixedCost.intervalNumber: fixedCostEntity.intervalNumber,
          SqfFixedCost.intervalUnit: fixedCostEntity.intervalUnit,
          SqfFixedCost.firstPaymentDate: fixedCostEntity.firstPaymentDate,
          SqfFixedCost.recentPaymentDate: fixedCostEntity.recentPaymentDate,
          SqfFixedCost.nextPaymentDate: fixedCostEntity.nextPaymentDate,
          SqfFixedCost.deleteFlag: fixedCostEntity.deleteFlag,
        },
        fixedCostEntity.id ?? -1);
    print('Update result: $result');
  }

  @override
  Future<void> delete(int id) async {
    await db.delete(SqfFixedCost.tableName, id);
  }
}
