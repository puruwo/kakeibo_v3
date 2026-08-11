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

  // 削除されていない固定費のみを取得する
  @override
  Future<List<FixedCostEntity>> fetchAllActive() async {
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
      WHERE a.${SqfFixedCost.deleteFlag} = 0
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

  // 支払い日が期間終了日までに到来しているレコードを取得する
  // 期間開始日という下限は設けない。過去のバッチで取りこぼして next_payment_date が
  // 過去日のまま固定されたマスタも拾い、追いつかせるため
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
      WHERE a.${SqfFixedCost.nextPaymentDate} <= ${DateFormat('yyyyMMdd').format(period.endDatetime)}
      AND a.${SqfFixedCost.deleteFlag} = 0
      ORDER BY a.${SqfFixedCost.id} DESC;
    ''';

    // ここでは例外を握りつぶさない
    // 空リストを返すと、呼び出し元（バッチ）が「取得失敗」と「対象0件」を区別できず、
    // SQLエラーでも「対象0件で成功」と記録され、その月の固定費が二度と生成されなくなるため
    final jsonList = await db.query(sql);
    final results =
        jsonList.map((json) => FixedCostEntity.fromJson(json)).toList();

    return results;
  }

  // 変動あり固定費の推定支出を取得する
  @override
  Future<int> fetchEstimatedPriceById({required int id}) async {
    final sql = '''
      SELECT a.${SqfFixedCost.estimatedPrice} AS estimatedPrice
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
      SqfFixedCost.fixedCostCategoryId: fixedCostEntity.fixedCostCategoryId,
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
          SqfFixedCost.fixedCostCategoryId: fixedCostEntity.fixedCostCategoryId,
          SqfFixedCost.intervalNumber: fixedCostEntity.intervalNumber,
          SqfFixedCost.intervalUnit: fixedCostEntity.intervalUnit,
          SqfFixedCost.firstPaymentDate: fixedCostEntity.firstPaymentDate,
          SqfFixedCost.recentPaymentDate:
              fixedCostEntity.recentPaymentDate ?? '',
          SqfFixedCost.nextPaymentDate: fixedCostEntity.nextPaymentDate ?? '',
          SqfFixedCost.deleteFlag: fixedCostEntity.deleteFlag,
        },
        fixedCostEntity.id ?? -1);
    print('Update result: $result');
  }

  // レコードは削除せず、deleteFlagを1にする
  @override
  Future<void> delete(int id) async {
    final result = await db.update(
        SqfFixedCost.tableName,
        {
          SqfFixedCost.deleteFlag: 1,
        },
        id);
    print('chage status to delete result: $result');
  }

  // マスタの論理削除と未払い実績の削除を1トランザクションで行う
  // 片方だけ成功して「マスタは生きているのに支払い予定だけ消えている」状態にならないようにする
  @override
  Future<void> deleteWithUnpaidExpenses(
      {required int id, required String today}) async {
    await db.runInTransaction((txn) async {
      // マスタを論理削除する
      await txn.update(
        SqfFixedCost.tableName,
        {SqfFixedCost.deleteFlag: 1},
        where: '${SqfFixedCost.id} = ?',
        whereArgs: [id],
      );

      // 未払い実績（未確定 or 支払日が未到来）を削除する
      // 支払日が到来済みの記録は、実際に払った事実として履歴に残す
      await txn.delete(
        SqfFixedCostExpense.tableName,
        where:
            '${SqfFixedCostExpense.fixedCostId} = ? AND (${SqfFixedCostExpense.isConfirmed} = 0 OR ${SqfFixedCostExpense.date} > ?)',
        whereArgs: [id, today],
      );
    });
  }
}
