import 'package:intl/intl.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/logger.dart';
import 'package:kakeibo/repository/expense_repository.dart';
import 'package:sqflite/sqflite.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsFixedCostRepository implements FixedCostRepository {
  /// 固定費実績（expense の固定費行）側のSQLを担当する
  ///
  /// マスタ更新と実績更新を同一トランザクションで行う必要があるため
  /// （仕様 §6.5・§6.4）、実績側のSQLを二重に書かずに委譲する。
  /// 同じ repository 層の実装同士の連携で、Transaction を引き渡して使う。
  final ImplementsExpenseRepository _expenseRepository =
      ImplementsExpenseRepository();

  /// マスタ更新用の列マップ（update と同期付きupdateで共用する）
  Map<String, dynamic> _toRow(FixedCostEntity fixedCostEntity) => {
        SqfFixedCost.name: fixedCostEntity.name,
        SqfFixedCost.variable: fixedCostEntity.variable,
        SqfFixedCost.price: fixedCostEntity.price,
        SqfFixedCost.estimatedPrice: fixedCostEntity.estimatedPrice,
        SqfFixedCost.estimatedPriceIsManual:
            fixedCostEntity.estimatedPriceIsManual,
        SqfFixedCost.expenseSmallCategoryId:
            fixedCostEntity.expenseSmallCategoryId,
        SqfFixedCost.intervalNumber: fixedCostEntity.intervalNumber,
        SqfFixedCost.intervalUnit: fixedCostEntity.intervalUnit,
        SqfFixedCost.firstPaymentDate: fixedCostEntity.firstPaymentDate,
        SqfFixedCost.recentPaymentDate: fixedCostEntity.recentPaymentDate ?? '',
        SqfFixedCost.nextPaymentDate: fixedCostEntity.nextPaymentDate ?? '',
        SqfFixedCost.deleteFlag: fixedCostEntity.deleteFlag,
      };

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
        a.${SqfFixedCost.estimatedPriceIsManual} AS estimatedPriceIsManual,
        a.${SqfFixedCost.expenseSmallCategoryId} AS expenseSmallCategoryId,
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
        a.${SqfFixedCost.estimatedPriceIsManual} AS estimatedPriceIsManual,
        a.${SqfFixedCost.expenseSmallCategoryId} AS expenseSmallCategoryId,
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
        a.${SqfFixedCost.estimatedPriceIsManual} AS estimatedPriceIsManual,
        a.${SqfFixedCost.expenseSmallCategoryId} AS expenseSmallCategoryId,
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
        expenseSmallCategoryId: 0,
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
        a.${SqfFixedCost.estimatedPriceIsManual} AS estimatedPriceIsManual,
        a.${SqfFixedCost.expenseSmallCategoryId} AS expenseSmallCategoryId,
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
      SqfFixedCost.estimatedPriceIsManual:
          fixedCostEntity.estimatedPriceIsManual,
      SqfFixedCost.expenseSmallCategoryId:
          fixedCostEntity.expenseSmallCategoryId,
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
    await db.update(
        SqfFixedCost.tableName, _toRow(fixedCostEntity), fixedCostEntity.id ?? -1);
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
      // 残った確定行の fixed_cost_id は保持する（通常支出化しない。仕様 §6.4）
      await _expenseRepository.deleteUnpaidFixedCostRecords(
        fixedCostId: id,
        today: today,
        executor: txn,
      );
    });
  }

  // 推定額の再計算・マスタ更新・未確定行の同期を1トランザクションで実行する
  // 同期だけ失敗して行側が古い値で固定される状態を作らない（仕様 §6.5）
  @override
  Future<void> recalculateEstimatedPriceWithSync({
    required int fixedCostId,
  }) async {
    await db.runInTransaction((txn) async {
      // 予想額が手動設定のマスタは再計算の対象外（仕様 §6.9）
      // ユーザーが決めた額を支払いの確定で上書きしない
      final isManual = Sqflite.firstIntValue(
        await txn.rawQuery(
          'SELECT ${SqfFixedCost.estimatedPriceIsManual} '
          'FROM ${SqfFixedCost.tableName} WHERE ${SqfFixedCost.id} = ?',
          [fixedCostId],
        ),
      );
      if (isManual == 1) return;

      // いま当該マスタに紐づく確定行のpriceの平均（現在状態主義）
      final average = await _expenseRepository
          .fetchConfirmedFixedCostPriceAverage(
        fixedCostId: fixedCostId,
        executor: txn,
      );

      // 確定行が0件のときは更新しない（最後の値を保持する）
      if (average == null) return;

      final estimatedPrice = average.toInt();

      await txn.update(
        SqfFixedCost.tableName,
        {SqfFixedCost.estimatedPrice: estimatedPrice},
        where: '${SqfFixedCost.id} = ?',
        whereArgs: [fixedCostId],
      );

      await _expenseRepository.updateEstimatedPriceOfUnconfirmedRows(
        fixedCostId: fixedCostId,
        estimatedPrice: estimatedPrice,
        executor: txn,
      );
    });
  }

  // 予想額を自動算出に戻すときのマスタ更新（仕様 §6.9）
  //
  // 「フラグ0への更新」「確定行の平均での再計算」「未確定行への同期」を
  // 1トランザクションで実行する。確定行が0件のときは平均を求められないため、
  // 渡されたエンティティの予想額（＝現在値）をそのまま保持する。
  @override
  Future<void> updateWithAutoEstimatedPriceSync(
      FixedCostEntity fixedCostEntity) async {
    final fixedCostId = fixedCostEntity.id ?? -1;

    await db.runInTransaction((txn) async {
      await txn.update(
        SqfFixedCost.tableName,
        _toRow(fixedCostEntity),
        where: '${SqfFixedCost.id} = ?',
        whereArgs: [fixedCostId],
      );

      // いま当該マスタに紐づく確定行のpriceの平均（現在状態主義）
      final average = await _expenseRepository
          .fetchConfirmedFixedCostPriceAverage(
        fixedCostId: fixedCostId,
        executor: txn,
      );

      // 確定行が0件のときは現在値を保持する
      final estimatedPrice =
          average?.toInt() ?? fixedCostEntity.estimatedPrice;

      if (average != null) {
        await txn.update(
          SqfFixedCost.tableName,
          {SqfFixedCost.estimatedPrice: estimatedPrice},
          where: '${SqfFixedCost.id} = ?',
          whereArgs: [fixedCostId],
        );
      }

      await _expenseRepository.updateEstimatedPriceOfUnconfirmedRows(
        fixedCostId: fixedCostId,
        estimatedPrice: estimatedPrice,
        executor: txn,
      );
    });
  }

  // マスタの更新と未確定行の予想額の同期を1トランザクションで実行する
  @override
  Future<void> updateWithUnconfirmedRowsSync(
      FixedCostEntity fixedCostEntity) async {
    await db.runInTransaction((txn) async {
      await txn.update(
        SqfFixedCost.tableName,
        _toRow(fixedCostEntity),
        where: '${SqfFixedCost.id} = ?',
        whereArgs: [fixedCostEntity.id ?? -1],
      );

      await _expenseRepository.updateEstimatedPriceOfUnconfirmedRows(
        fixedCostId: fixedCostEntity.id ?? -1,
        estimatedPrice: fixedCostEntity.estimatedPrice,
        executor: txn,
      );
    });
  }
}
