import 'package:intl/intl.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/logger.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsExpenseRepository implements ExpenseRepository {
  // 全ての支出情報を取得する
  @override
  Future<List<ExpenseEntity>> fetchAll() async {
    const sql =
        '''
      SELECT 
        a.${SqfExpense.id} AS id,
        a.${SqfExpense.expenseSmallCategoryId} AS paymentCategoryId, 
        a.${SqfExpense.date} AS date,
        a.${SqfExpense.price} AS price, 
        a.${SqfExpense.memo} AS memo,
        a.${SqfExpense.incomeSourceBigCategory} AS incomeSourceBigCategory,
        a.${SqfExpense.fixedCostId} AS fixedCostId,
        a.${SqfExpense.isConfirmed} AS isConfirmed,
        a.${SqfExpense.estimatedPrice} AS estimatedPrice
      FROM ${SqfExpense.tableName} a
      ORDER BY a.${SqfExpense.id} ASC;
    ''';

    try {
      final jsonList = await db.query(sql);
      // logger.i(
      //     '====SQLが実行されました====\n ImplementsExpenseRepository fetchWithoutCategory(MonthPeriodValue period)\n$sql');

      final results = jsonList
          .map((json) => ExpenseEntity.fromJson(json))
          .toList();

      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return [];
    }
  }

  // カテゴリーを指定しないで取得する
  @override
  Future<List<ExpenseEntity>> fetchWithSourceCategory({
    required int incomeSourceBigId,
    required PeriodValue period,
  }) async {
    final sql =
        '''
      SELECT
        a.${SqfExpense.id} AS id,
        a.${SqfExpense.expenseSmallCategoryId} AS paymentCategoryId,
        a.${SqfExpense.date} AS date,
        a.${SqfExpense.price} AS price,
        a.${SqfExpense.memo} AS memo,
        a.${SqfExpense.incomeSourceBigCategory} AS incomeSourceBigCategory,
        a.${SqfExpense.fixedCostId} AS fixedCostId,
        a.${SqfExpense.isConfirmed} AS isConfirmed,
        a.${SqfExpense.estimatedPrice} AS estimatedPrice
      FROM ${SqfExpense.tableName} a
      WHERE a.${SqfExpense.date} >= ${DateFormat('yyyyMMdd').format(period.startDatetime)} AND a.${SqfExpense.date} <= ${DateFormat('yyyyMMdd').format(period.endDatetime)}
      AND a.${SqfExpense.incomeSourceBigCategory} = $incomeSourceBigId
      ORDER BY a.${SqfExpense.id} DESC;
    ''';

    try {
      final jsonList = await db.query(sql);
      // logger.i(
      //     '====SQLが実行されました====\n ImplementsExpenseRepository fetchWithoutCategory(MonthPeriodValue period)\n$sql');

      final results = jsonList
          .map((json) => ExpenseEntity.fromJson(json))
          .toList();

      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return [];
    }
  }

  // カテゴリーと拠出元を指定して取得する
  @override
  Future<List<ExpenseEntity>> fetchWithSmallCategory({
    required int incomeSourceBigId,
    required PeriodValue period,
    required int smallCategoryId,
  }) async {
    final sql =
        '''
      SELECT
        a.${SqfExpense.id} AS id,
        a.${SqfExpense.expenseSmallCategoryId} AS paymentCategoryId,
        a.${SqfExpense.date} AS date,
        a.${SqfExpense.price} AS price,
        a.${SqfExpense.memo} AS memo,
        a.${SqfExpense.incomeSourceBigCategory} AS incomeSourceBigCategory,
        a.${SqfExpense.fixedCostId} AS fixedCostId,
        a.${SqfExpense.isConfirmed} AS isConfirmed,
        a.${SqfExpense.estimatedPrice} AS estimatedPrice
      FROM ${SqfExpense.tableName} a
      WHERE a.${SqfExpense.date} >= ${DateFormat('yyyyMMdd').format(period.startDatetime)} AND a.${SqfExpense.date} <= ${DateFormat('yyyyMMdd').format(period.endDatetime)}
      AND a.${SqfExpense.incomeSourceBigCategory} = $incomeSourceBigId
      AND a.${SqfExpense.expenseSmallCategoryId} = $smallCategoryId
      ORDER BY a.${SqfExpense.id} DESC;
    ''';
    try {
      final jsonList = await db.query(sql);
      // logger.i(
      //     '====SQLが実行されました====\n ImplementsExpenseRepository fetchWithoutCategory(MonthPeriodValue period)\n$sql');

      final results = jsonList
          .map((json) => ExpenseEntity.fromJson(json))
          .toList();

      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return [];
    }
  }

  // 期間を指定して支出の合計を取得する
  @override
  Future<int> fetchTotalExpenseByPeriod({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final sql =
        '''
      SELECT COALESCE(SUM(${SqfExpense.effectivePriceExpr}),0) as totalExpense FROM ${SqfExpense.tableName} 
      WHERE date >= ${DateFormat('yyyyMMdd').format(fromDate)} AND date <= ${DateFormat('yyyyMMdd').format(toDate)};
      ''';

    try {
      final result = await db.queryFirstIntValue(sql);
      // logger.i(
      //     '====SQLが実行されました====\n ImplementsExpenseRepository fetchWithoutCategory(DateTime $fromDate, DateTime $toDate)\n$sql');

      return result ?? 0; // nullの場合は0を返す
    } catch (e) {
      logger.e('[FAIL]: $e');
      return 0;
    }
  }

  // 期間とカテゴリーを指定して支出の合計を取得する
  @override
  Future<int> fetchTotalExpenseByPeriodWithBigCategory({
    required int incomeSourceBigCategory,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final sql =
        '''
      SELECT COALESCE(SUM(${SqfExpense.effectivePriceExpr}),0) as totalExpense FROM ${SqfExpense.tableName}
      WHERE date >= ${DateFormat('yyyyMMdd').format(fromDate)} AND date <= ${DateFormat('yyyyMMdd').format(toDate)}
      AND ${SqfExpense.incomeSourceBigCategory} = $incomeSourceBigCategory;
      ''';

    try {
      final result = await db.queryFirstIntValue(sql);
      // logger.i(
      //     '====SQLが実行されました====\n ImplementsExpenseRepository fetchTotalExpenseByPeriodWithBigCategory(int $incomeSourceBigCategory, DateTime $fromDate, DateTime $toDate)\n$sql');

      return result ?? 0; // nullの場合は0を返す
    } catch (e) {
      logger.e('[FAIL]: $e');
      return 0;
    }
  }

  // 期間とカテゴリーを指定して支出の合計を取得する
  @override
  Future<int> fetchTotalExpenseByPeriodWithSmallCategoryAndSource({
    required int incomeSourceBigCategory,
    required int smallCategoryId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final sql =
        '''
      SELECT COALESCE(SUM(${SqfExpense.effectivePriceExpr}),0) as totalExpense FROM ${SqfExpense.tableName}
      WHERE date >= ${DateFormat('yyyyMMdd').format(fromDate)} AND date <= ${DateFormat('yyyyMMdd').format(toDate)}
      AND ${SqfExpense.incomeSourceBigCategory} = $incomeSourceBigCategory
      AND ${SqfExpense.expenseSmallCategoryId} = $smallCategoryId;
      ''';

    try {
      final result = await db.queryFirstIntValue(sql);
      // logger.i(
      //     '====SQLが実行されました====\n ImplementsExpenseRepository fetchTotalExpenseByPeriodWithBigCategory(int $incomeSourceBigCategory, DateTime $fromDate, DateTime $toDate)\n$sql');

      return result ?? 0; // nullの場合は0を返す
    } catch (e) {
      logger.e('[FAIL]: $e');
      return 0;
    }
  }

  // 期間を指定して日毎の支出データを取得する（通常支出のみ）
  @override
  Future<int> fetchDailyExpenseByPeriod({required DateTime date}) async {
    final sql =
        '''
      SELECT
        SUM(${SqfExpense.effectivePriceExpr}) AS sum_price_daily
      FROM ${SqfExpense.tableName}
      WHERE ${SqfExpense.date} = ${DateFormat('yyyyMMdd').format(date)}
      AND ${SqfExpense.incomeSourceBigCategory} = ${AccountTypeConstants.living}
      GROUP BY ${SqfExpense.date}
      ORDER BY ${SqfExpense.date} ASC
    ''';

    try {
      final sumPriceDaily = await db.queryFirstIntValue(sql);
      // logger.i(
      //     '====SQLが実行されました====\n ImplementsExpenseRepository fetchDailyExpenseByPeriod(DateTime $date)\n$sql');

      return sumPriceDaily ?? 0;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return 0;
    }
  }

  /// 日付を指定して支出リストを取得する（生活支出のみ）
  @override
  Future<List<ExpenseEntity>> fetchDailyExpenseListByDate({
    required DateTime date,
  }) async {
    final sql =
        '''
      SELECT
        a.${SqfExpense.id} AS id,
        a.${SqfExpense.expenseSmallCategoryId} AS paymentCategoryId,
        a.${SqfExpense.date} AS date,
        a.${SqfExpense.price} AS price,
        a.${SqfExpense.memo} AS memo,
        a.${SqfExpense.incomeSourceBigCategory} AS incomeSourceBigCategory,
        a.${SqfExpense.fixedCostId} AS fixedCostId,
        a.${SqfExpense.isConfirmed} AS isConfirmed,
        a.${SqfExpense.estimatedPrice} AS estimatedPrice
      FROM ${SqfExpense.tableName} a
      WHERE a.${SqfExpense.date} = ${DateFormat('yyyyMMdd').format(date)}
      AND a.${SqfExpense.incomeSourceBigCategory} = ${AccountTypeConstants.living}
      ORDER BY a.${SqfExpense.id} ASC
    ''';

    try {
      final jsonList = await db.query(sql);
      final results = jsonList
          .map((json) => ExpenseEntity.fromJson(json))
          .toList();
      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return [];
    }
  }

  @override
  void insert(ExpenseEntity expenseEntity) {
    db.insert(SqfExpense.tableName, {
      SqfExpense.expenseSmallCategoryId: expenseEntity.paymentCategoryId,
      SqfExpense.date: expenseEntity.date,
      SqfExpense.price: expenseEntity.price,
      SqfExpense.memo: expenseEntity.memo,
      SqfExpense.incomeSourceBigCategory: expenseEntity.incomeSourceBigCategory,
      SqfExpense.fixedCostId: expenseEntity.fixedCostId,
      SqfExpense.isConfirmed: expenseEntity.isConfirmed,
      SqfExpense.estimatedPrice: expenseEntity.estimatedPrice,
    });
    // logger.i(
    //     '====SQLが実行されました====\n ImplementsExpenseRepository insert(ExpenseEntity expenseEntity)\n${SqfExpense.tableName}でinsert\n  expenseEntity: \n$expenseEntity');
  }

  @override
  Future<void> update(ExpenseEntity expenseEntity) async {
    // 呼び出し側で完了を待てるよう Future を返す（固定費化・確定処理が後続で同じ行を読むため）
    await db.update(SqfExpense.tableName, {
      SqfExpense.expenseSmallCategoryId: expenseEntity.paymentCategoryId,
      SqfExpense.date: expenseEntity.date,
      SqfExpense.price: expenseEntity.price,
      SqfExpense.memo: expenseEntity.memo,
      SqfExpense.incomeSourceBigCategory: expenseEntity.incomeSourceBigCategory,
      SqfExpense.fixedCostId: expenseEntity.fixedCostId,
      SqfExpense.isConfirmed: expenseEntity.isConfirmed,
      SqfExpense.estimatedPrice: expenseEntity.estimatedPrice,
    }, expenseEntity.id);
    // logger.i(
    //     '====SQLが実行されました====\n ImplementsExpenseRepository update(ExpenseEntity expenseEntity)\n ${SqfExpense.tableName}でupdate\n expenseEntity: \n$expenseEntity');
  }

  @override
  void delete(int id) async {
    await db.delete(SqfExpense.tableName, id);
    // logger.i('${SqfExpense.tableName}で$idのレコードを削除しました');
  }

  // -------------------------------------------------------------------------
  // 固定費系のクエリ（v10で fixed_cost_expense から移管）
  //
  // 推定額の再計算・マスタ更新・未確定行の同期は同一トランザクションで
  // 実行する必要があるため（仕様 §6.5）、書き込み系は呼び出し元から
  // Transaction を受け取れるように [executor] を任意引数で持つ。
  // 未指定のときは単独のDB接続で実行する（既存の runInTransaction 作法に倣う）。
  // -------------------------------------------------------------------------

  /// 実行先のDBを解決する（[executor] があればそのトランザクション上で実行する）
  Future<DatabaseExecutor> _resolveExecutor(DatabaseExecutor? executor) async {
    if (executor != null) return executor;
    final database = await db.database;
    return database!;
  }

  /// SELECT句（固定費系クエリで共用する）
  static const _selectColumns = '''
        ${SqfExpense.id} AS id,
        ${SqfExpense.expenseSmallCategoryId} AS paymentCategoryId,
        ${SqfExpense.date} AS date,
        ${SqfExpense.price} AS price,
        ${SqfExpense.memo} AS memo,
        ${SqfExpense.incomeSourceBigCategory} AS incomeSourceBigCategory,
        ${SqfExpense.fixedCostId} AS fixedCostId,
        ${SqfExpense.isConfirmed} AS isConfirmed,
        ${SqfExpense.estimatedPrice} AS estimatedPrice''';

  @override
  Future<ExpenseEntity?> fetchById({required int id}) async {
    final sql = '''
      SELECT
$_selectColumns
      FROM ${SqfExpense.tableName}
      WHERE ${SqfExpense.id} = $id;
    ''';

    try {
      final jsonList = await db.query(sql);
      if (jsonList.isEmpty) return null;
      return ExpenseEntity.fromJson(jsonList.first);
    } catch (e) {
      logger.e('[FAIL]: $e');
      return null;
    }
  }

  // 固定費実績の行を1件挿入する
  // 挿入の失敗を呼び出し元（バッチ）が検知できるよう、完了を待てるFutureを返す
  @override
  Future<int> insertFixedCostExpense(ExpenseEntity expenseEntity) async {
    return await db.insert(SqfExpense.tableName, {
      SqfExpense.expenseSmallCategoryId: expenseEntity.paymentCategoryId,
      SqfExpense.date: expenseEntity.date,
      SqfExpense.price: expenseEntity.price,
      SqfExpense.memo: expenseEntity.memo,
      SqfExpense.incomeSourceBigCategory: expenseEntity.incomeSourceBigCategory,
      SqfExpense.fixedCostId: expenseEntity.fixedCostId,
      SqfExpense.isConfirmed: expenseEntity.isConfirmed,
      SqfExpense.estimatedPrice: expenseEntity.estimatedPrice,
    });
  }

  // 固定費IDと支払い日を指定して、実績がすでに存在するか確認する
  // バッチの取り残し回収で、同じ支払い日の実績を二重生成しないために使う
  @override
  Future<bool> existsByFixedCostIdAndDate({
    required int fixedCostId,
    required String date,
  }) async {
    final sql = '''
      SELECT COUNT(*)
      FROM ${SqfExpense.tableName}
      WHERE ${SqfExpense.fixedCostId} = $fixedCostId
      AND ${SqfExpense.date} = '$date'
    ''';
    final count = await db.queryFirstIntValue(sql);
    return (count ?? 0) > 0;
  }

  // 期間内の固定費行をまとめて取得する（確定・未確定を問わない）
  // 月次固定費ビュー・見込み算出・予測グラフが共通で使うデータ源
  @override
  Future<List<ExpenseEntity>> fetchFixedCostExpenseByPeriod({
    required PeriodValue period,
  }) async {
    final sql = '''
      SELECT
$_selectColumns
      FROM ${SqfExpense.tableName}
      WHERE ${SqfExpense.date} >= ${DateFormat('yyyyMMdd').format(period.startDatetime)}
      AND ${SqfExpense.date} <= ${DateFormat('yyyyMMdd').format(period.endDatetime)}
      AND ${SqfExpense.fixedCostId} IS NOT NULL
      ORDER BY ${SqfExpense.date} ASC, ${SqfExpense.id} ASC;
    ''';

    try {
      final jsonList = await db.query(sql);
      return jsonList.map((json) => ExpenseEntity.fromJson(json)).toList();
    } catch (e) {
      logger.e('[FAIL]: $e');
      return [];
    }
  }

  @override
  Future<List<ExpenseEntity>> fetchUnconfirmedFixedCostExpenseByPeriod({
    required PeriodValue period,
  }) async {
    final sql = '''
      SELECT
$_selectColumns
      FROM ${SqfExpense.tableName}
      WHERE ${SqfExpense.date} >= ${DateFormat('yyyyMMdd').format(period.startDatetime)}
      AND ${SqfExpense.date} <= ${DateFormat('yyyyMMdd').format(period.endDatetime)}
      AND ${SqfExpense.fixedCostId} IS NOT NULL
      AND ${SqfExpense.isConfirmed} = 0
      ORDER BY ${SqfExpense.date} DESC;
    ''';

    try {
      final jsonList = await db.query(sql);
      return jsonList.map((json) => ExpenseEntity.fromJson(json)).toList();
    } catch (e) {
      logger.e('[FAIL]: $e');
      return [];
    }
  }

  // 未確定行に実額を設定して確定させる
  // 予想額 estimated_price は上書きしない（予実の乖離を行に残す。仕様 §3）
  @override
  Future<void> confirmFixedCostExpense({
    required int id,
    required int price,
  }) async {
    final database = await db.database;
    await database!.update(
      SqfExpense.tableName,
      {SqfExpense.price: price, SqfExpense.isConfirmed: 1},
      where: '${SqfExpense.id} = ?',
      whereArgs: [id],
    );
  }

  // 確定済み固定費行の実額priceの平均を返す
  // 対象0件のときAVGはNULLを返すので、そのままnullを返して
  // 「推定額を更新しない」判定に使う（仕様 §6.5 のフォールバック）
  @override
  Future<double?> fetchConfirmedFixedCostPriceAverage({
    required int fixedCostId,
    DatabaseExecutor? executor,
  }) async {
    final sql = '''
      SELECT AVG(${SqfExpense.price}) AS avg_price
      FROM ${SqfExpense.tableName}
      WHERE ${SqfExpense.fixedCostId} = $fixedCostId
      AND ${SqfExpense.isConfirmed} = 1
      AND ${SqfExpense.price} IS NOT NULL
    ''';
    final target = await _resolveExecutor(executor);
    final result = await target.rawQuery(sql);
    if (result.isEmpty || result.first['avg_price'] == null) {
      return null;
    }
    return (result.first['avg_price'] as num).toDouble();
  }

  @override
  Future<void> updateEstimatedPriceOfUnconfirmedRows({
    required int fixedCostId,
    required int estimatedPrice,
    DatabaseExecutor? executor,
  }) async {
    final target = await _resolveExecutor(executor);
    await target.update(
      SqfExpense.tableName,
      {SqfExpense.estimatedPrice: estimatedPrice},
      where:
          '${SqfExpense.fixedCostId} = ? AND ${SqfExpense.isConfirmed} = 0',
      whereArgs: [fixedCostId],
    );
  }

  // 未払い実績（未確定 or 支払日が未到来）を削除する
  // 支払日が到来済みの確定行は、実際に払った事実として履歴に残す（→ ADR-007）
  @override
  Future<void> deleteUnpaidFixedCostExpenses({
    required int fixedCostId,
    required String today,
    DatabaseExecutor? executor,
  }) async {
    final target = await _resolveExecutor(executor);
    await target.delete(
      SqfExpense.tableName,
      where:
          '${SqfExpense.fixedCostId} = ? AND (${SqfExpense.isConfirmed} = 0 OR ${SqfExpense.date} > ?)',
      whereArgs: [fixedCostId, today],
    );
  }

  @override
  Future<void> updateSmallCategoryByFixedCostId({
    required int fixedCostId,
    required int expenseSmallCategoryId,
    DatabaseExecutor? executor,
  }) async {
    final target = await _resolveExecutor(executor);
    await target.update(
      SqfExpense.tableName,
      {SqfExpense.expenseSmallCategoryId: expenseSmallCategoryId},
      where: '${SqfExpense.fixedCostId} = ?',
      whereArgs: [fixedCostId],
    );
  }
}
