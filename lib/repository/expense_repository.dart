import 'package:intl/intl.dart';
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
    const sql = '''
      SELECT 
        a.${SqfExpense.id} AS id,
        a.${SqfExpense.expenseSmallCategoryId} AS paymentCategoryId, 
        a.${SqfExpense.date} AS date,
        a.${SqfExpense.price} AS price, 
        a.${SqfExpense.memo} AS memo,
        a.${SqfExpense.incomeSourceBigCategory} AS incomeSourceBigCategory
      FROM ${SqfExpense.tableName} a
      ORDER BY a.${SqfExpense.id} ASC;
    ''';

    try {
      final jsonList = await db.query(sql);
      // logger.i(
      //     '====SQLが実行されました====\n ImplementsExpenseRepository fetchWithoutCategory(MonthPeriodValue period)\n$sql');

      final results =
          jsonList.map((json) => ExpenseEntity.fromJson(json)).toList();

      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return [];
    }
  }

  // カテゴリーを指定しないで取得する
  @override
  Future<List<ExpenseEntity>> fetchWithSourceCategory(
      {required int incomeSourceBigId, required PeriodValue period}) async {
    final sql = '''
      SELECT 
        a.${SqfExpense.id} AS id,
        a.${SqfExpense.expenseSmallCategoryId} AS paymentCategoryId, 
        a.${SqfExpense.date} AS date,
        a.${SqfExpense.price} AS price, 
        a.${SqfExpense.memo} AS memo,
        a.${SqfExpense.incomeSourceBigCategory} AS incomeSourceBigCategory,
        a.${SqfExpense.fixedCostId} AS fixedCostId,
        a.${SqfExpense.isConfirmed} AS isConfirmed
      FROM ${SqfExpense.tableName} a
      WHERE a.${SqfExpense.date} >= ${DateFormat('yyyyMMdd').format(period.startDatetime)} AND a.${SqfExpense.date} <= ${DateFormat('yyyyMMdd').format(period.endDatetime)}
      AND a.${SqfExpense.incomeSourceBigCategory} = $incomeSourceBigId
      ORDER BY a.${SqfExpense.id} DESC;
    ''';

    try {
      final jsonList = await db.query(sql);
      // logger.i(
      //     '====SQLが実行されました====\n ImplementsExpenseRepository fetchWithoutCategory(MonthPeriodValue period)\n$sql');

      final results =
          jsonList.map((json) => ExpenseEntity.fromJson(json)).toList();

      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return [];
    }
  }

  // カテゴリーと拠出元を指定して取得する
  @override
  Future<List<ExpenseEntity>> fetchWithCategory(
      {required int incomeSourceBigId,
      required PeriodValue period,
      required int smallCategoryId}) async {
    final sql = '''
      SELECT 
        a.${SqfExpense.id} AS id,
        a.${SqfExpense.expenseSmallCategoryId} AS paymentCategoryId,
        a.${SqfExpense.date} AS date,
        a.${SqfExpense.price} AS price,
        a.${SqfExpense.memo} AS memo,
        a.${SqfExpense.incomeSourceBigCategory} AS incomeSourceBigCategory,
        a.${SqfExpense.fixedCostId} AS fixedCostId,
        a.${SqfExpense.isConfirmed} AS isConfirmed
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

      final results =
          jsonList.map((json) => ExpenseEntity.fromJson(json)).toList();

      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return [];
    }
  }

  // 期間を指定して支出の合計を取得する
  @override
  Future<int> fetchTotalExpenseByPeriod(
      {required DateTime fromDate, required DateTime toDate}) async {
    final sql = '''
      SELECT COALESCE(SUM(price),0) as totalExpense FROM ${SqfExpense.tableName} 
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
  Future<int> fetchTotalExpenseByPeriodWithBigCategory(
      {required int incomeSourceBigCategory,
      required DateTime fromDate,
      required DateTime toDate}) async {
    final sql = '''
      SELECT COALESCE(SUM(price),0) as totalExpense FROM ${SqfExpense.tableName} 
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

  // 確定している固定費の支出を取得する
  @override
  Future<List<ExpenseEntity>> fetchFixedCostByPeriod(
      {required PeriodValue period}) async {
    final sql = '''
      SELECT 
        a.${SqfExpense.id} AS id,
        a.${SqfExpense.expenseSmallCategoryId} AS paymentCategoryId,
        a.${SqfExpense.date} AS date,
        a.${SqfExpense.price} AS price,
        a.${SqfExpense.memo} AS memo,
        a.${SqfExpense.incomeSourceBigCategory} AS incomeSourceBigCategory,
        a.${SqfExpense.fixedCostId} AS fixedCostId,
        a.${SqfExpense.isConfirmed} AS isConfirmed
      FROM ${SqfExpense.tableName} a
      WHERE a.${SqfExpense.date} >= ${DateFormat('yyyyMMdd').format(period.startDatetime)} AND a.${SqfExpense.date} <= ${DateFormat('yyyyMMdd').format(period.endDatetime)}
      AND a.${SqfExpense.fixedCostId} IS NOT NULL
      AND a.${SqfExpense.isConfirmed} = 1
      ORDER BY a.${SqfExpense.id} DESC;
    ''';
    try {
      final jsonList = await db.query(sql);
      // logger.i(
      //     '====SQLが実行されました====\n ImplementsExpenseRepository fetchFixedCostByPeriod(MonthPeriodValue period)\n$sql');

      final results =
          jsonList.map((json) => ExpenseEntity.fromJson(json)).toList();

      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return [];
    }
  }

  // 確定している固定費の合計額を取得する
  @override
  Future<int> fetchTotalFixedCostByPeriod(
      {required PeriodValue period}) async {
    final sql = '''
      SELECT COALESCE(SUM(price),0) as totalFixedCost FROM ${SqfExpense.tableName} a
      WHERE a.${SqfExpense.date} >= ${DateFormat('yyyyMMdd').format(period.startDatetime)} AND a.${SqfExpense.date} <= ${DateFormat('yyyyMMdd').format(period.endDatetime)}
      AND a.${SqfExpense.fixedCostId} IS NOT NULL
      AND a.${SqfExpense.isConfirmed} = 1;
      ''';
    try {
      final result = await db.queryFirstIntValue(sql);
      // logger.i(
      //     '====SQLが実行されました====\n ImplementsExpenseRepository fetchTotalFixedCostByPeriod(MonthPeriodValue period)\n$sql');

      return result ?? 0; // nullの場合は0を返す
    } catch (e) {
      logger.e('[FAIL]: $e');
      return 0;
    }
  }

  // 確定していない固定費の支出を取得する
  @override
  Future<List<ExpenseEntity>> fetchUnconfirmedFixedCostByPeriod(
      {required PeriodValue period}) async {
    final sql = '''
      SELECT 
        a.${SqfExpense.id} AS id,
        a.${SqfExpense.expenseSmallCategoryId} AS paymentCategoryId,
        a.${SqfExpense.date} AS date,
        a.${SqfExpense.price} AS price,
        a.${SqfExpense.memo} AS memo,
        a.${SqfExpense.incomeSourceBigCategory} AS incomeSourceBigCategory,
        a.${SqfExpense.fixedCostId} AS fixedCostId,
        a.${SqfExpense.isConfirmed} AS isConfirmed
      FROM ${SqfExpense.tableName} a
      WHERE a.${SqfExpense.date} >= ${DateFormat('yyyyMMdd').format(period.startDatetime)} AND a.${SqfExpense.date} <= ${DateFormat('yyyyMMdd').format(period.endDatetime)}
      AND a.${SqfExpense.fixedCostId} IS NOT NULL
      AND a.${SqfExpense.isConfirmed} = 0
      ORDER BY a.${SqfExpense.id} DESC;
    ''';
    try {
      final jsonList = await db.query(sql);
      // logger.i(
      //     '====SQLが実行されました====\n ImplementsExpenseRepository fetchUnconfirmedFixedCostByPeriod(MonthPeriodValue period)\n$sql');

      final results =
          jsonList.map((json) => ExpenseEntity.fromJson(json)).toList();

      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return [];
    }
  }

  // ID指定の変動固定費の推定支出を支出レコードから取得する
  @override
  Future<double> fetchFixedCostEstimatedPriceById({required int fixedCostId}) async {
    final sql = '''
      SELECT 
        AVG(a.${SqfExpense.price}) AS price
      FROM ${SqfExpense.tableName} a
      WHERE a.${SqfExpense.fixedCostId} = $fixedCostId
      AND a.${SqfExpense.isConfirmed} = 1;
    ''';
    try {
      // queryFirstIntValueを使うとdoubleで帰ってきた時にnullが返ってくることがあるので、queryを使う
      final json = await db.query(sql);
      // logger.i(
      //     '====SQLが実行されました====\n ImplementsExpenseRepository fetchFixedCostEstimatedPriceById(int fixedCostId)\n$sql');
      return json[0]['price'] ?? 0; // nullの場合は0を返す
    } catch (e) {
      logger.e('[FAIL]: $e');
      return 0;
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
      SqfExpense.isConfirmed: expenseEntity.isConfirmed
    });
    // logger.i(
    //     '====SQLが実行されました====\n ImplementsExpenseRepository insert(ExpenseEntity expenseEntity)\n${SqfExpense.tableName}でinsert\n  expenseEntity: \n$expenseEntity');
  }

  @override
  void update(ExpenseEntity expenseEntity) {
    db.update(
        SqfExpense.tableName,
        {
          SqfExpense.expenseSmallCategoryId: expenseEntity.paymentCategoryId,
          SqfExpense.date: expenseEntity.date,
          SqfExpense.price: expenseEntity.price,
          SqfExpense.memo: expenseEntity.memo,
          SqfExpense.incomeSourceBigCategory:
              expenseEntity.incomeSourceBigCategory,
          SqfExpense.fixedCostId: expenseEntity.fixedCostId,
          SqfExpense.isConfirmed: expenseEntity.isConfirmed
        },
        expenseEntity.id);
    // logger.i(
    //     '====SQLが実行されました====\n ImplementsExpenseRepository update(ExpenseEntity expenseEntity)\n ${SqfExpense.tableName}でupdate\n expenseEntity: \n$expenseEntity');
  }

  /// 確定していない固定費の支出を確定させる
  @override
  Future<void> updateUnconfirmedCost({required int id,required int confirmedPrice})async{
    await db.update(
      SqfExpense.tableName,
      {
        SqfExpense.price: confirmedPrice,
        SqfExpense.isConfirmed: 1 // 確定済みに更新
      },
      id,
    );
    // logger.i(
    //     '====SQLが実行されました====\n ImplementsExpenseRepository updateUnconfirmedCost(int id, int confirmedPrice)\n ${SqfExpense.tableName}でupdate\n id: $id, confirmedPrice: $confirmedPrice');
  }

  @override
  void delete(int id) async {
    await db.delete(SqfExpense.tableName, id);
    // logger.i('${SqfExpense.tableName}で$idのレコードを削除しました');
  }
}
