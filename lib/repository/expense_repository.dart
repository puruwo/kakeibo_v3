import 'package:intl/intl.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/providerLogger.dart';

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
      logger.i(
          '====SQLが実行されました====\n ImplementsExpenseRepository fetchWithoutCategory(MonthPeriodValue period)\n$sql');

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
  Future<List<ExpenseEntity>> fetchWithoutCategory(
      {required MonthPeriodValue period}) async {
    final sql = '''
      SELECT 
        a.${SqfExpense.id} AS id,
        a.${SqfExpense.expenseSmallCategoryId} AS paymentCategoryId, 
        a.${SqfExpense.date} AS date,
        a.${SqfExpense.price} AS price, 
        a.${SqfExpense.memo} AS memo,
        a.${SqfExpense.incomeSourceBigCategory} AS incomeSourceBigCategory
      FROM ${SqfExpense.tableName} a
      WHERE a.${SqfExpense.date} >= ${DateFormat('yyyyMMdd').format(period.startDatetime)} AND a.${SqfExpense.date} <= ${DateFormat('yyyyMMdd').format(period.endDatetime)};
    ''';

    try {
      final jsonList = await db.query(sql);
      logger.i(
          '====SQLが実行されました====\n ImplementsExpenseRepository fetchWithoutCategory(MonthPeriodValue period)\n$sql');

      final results =
          jsonList.map((json) => ExpenseEntity.fromJson(json)).toList();

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
      SqfExpense.incomeSourceBigCategory: expenseEntity.incomeSourceBigCategory
    });
    logger.i(
        '====SQLが実行されました====\n ImplementsExpenseRepository insert(ExpenseEntity expenseEntity)\n${SqfExpense.tableName}でinsert\n  expenseEntity: \n$expenseEntity');
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
          SqfExpense.incomeSourceBigCategory: expenseEntity.incomeSourceBigCategory
        },
        expenseEntity.id);
    logger.i(
        '====SQLが実行されました====\n ImplementsExpenseRepository update(ExpenseEntity expenseEntity)\n ${SqfExpense.tableName}でupdate\n expenseEntity: \n$expenseEntity');
  }

  @override
  void delete(int id) async {
    await db.delete(SqfExpense.tableName, id);
    logger.i('${SqfExpense.tableName}で$idのレコードを削除しました');
  }
}
