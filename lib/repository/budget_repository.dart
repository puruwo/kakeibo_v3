import 'package:kakeibo/domain/core/month_value/month_value.dart';
import 'package:kakeibo/domain/db/budget/budget_entity.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/logger.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsBudgetRepository implements BudgetRepository {
  
  // その月の各カテゴリーの予算をListで返す
  @override
  Future<BudgetEntity> fetchMonthlyByBigCategory(
      {required MonthValue month, required int expenseBigCategoryId}) async {
    final sql = '''
      SELECT 
        a.${SqfBudget.id} AS id,
        a.${SqfBudget.expenseBigCategoryId} AS expenseBigCategoryId,  
        a.${SqfBudget.month} AS month,
        a.${SqfBudget.price} AS price
      FROM ${SqfBudget.tableName} a
      INNER JOIN (
        SELECT ${SqfBudget.expenseBigCategoryId}, MAX(${SqfBudget.id}) AS max_id
        FROM ${SqfBudget.tableName}
        WHERE month = ${month.month}
        AND ${SqfBudget.expenseBigCategoryId}  = $expenseBigCategoryId
        GROUP BY ${SqfBudget.expenseBigCategoryId}
      ) b
      ON a.${SqfBudget.id} = b.max_id
      ORDER BY a.${SqfBudget.id} ASC;
    ''';

    try {
      final jsonList = await db.query(sql);
      logger.i(
          '====SQLが実行されました====\n ImplementsBudgetRepository fetchMonthlyByBigCategory()\n$sql');

      final result = BudgetEntity.fromJson(jsonList[0]);

      return result;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return BudgetEntity(
          id: -1,
          expenseBigCategoryId: expenseBigCategoryId,
          month: month.month,
          price: 0);
    }
  }

  // 月の合計予算を算出する
  @override
  Future<int> fetchMonthlyAll({required MonthValue month}) async {
    final sql = '''
      SELECT 
        SUM(${SqfBudget.price}) AS totalPrice
      FROM ${SqfBudget.tableName} a
      WHERE a.${SqfBudget.month} = ${month.month}
      ORDER BY a.${SqfBudget.id} ASC;
    ''';

    try {
      final result = await db.queryFirstIntValue(sql);
      logger.i(
          '====SQLが実行されました====\n ImplementsBudgetRepository fetchAll()\n$sql');

      return result ?? 0; // nullの場合は0を返す
    } catch (e) {
      logger.e('[FAIL]: $e');
      return 0;
    }
  }
  // 月の一つのカテゴリーの予算を算出する
  @override
  Future<int> fetchMonthly({required int id, required MonthValue month}) async {
    final sql = '''
      SELECT 
        ${SqfBudget.price} AS price
      FROM ${SqfBudget.tableName} a
      WHERE a.${SqfBudget.month} = ${month.month}
      AND a.${SqfBudget.expenseBigCategoryId} = $id
      ORDER BY a.${SqfBudget.id} ASC;
    ''';

    try {
      final result = await db.queryFirstIntValue(sql);
      logger.i(
          '====SQLが実行されました====\n ImplementsBudgetRepository fetchAll()\n$sql');

      return result ?? 0; // nullの場合は0を返す
    } catch (e) {
      logger.e('[FAIL]: $e');
      return 0;
    }
  }

  @override
  void insert(BudgetEntity budgetEntity) async{
    try {
      final id = await db.insert(SqfBudget.tableName, {
      SqfBudget.expenseBigCategoryId: budgetEntity.expenseBigCategoryId,
      SqfBudget.month: budgetEntity.month,
      SqfBudget.price: budgetEntity.price
    });
    logger.i(
        '====SQLが実行されました====\n ImplementsBudgetRepository insert(BudgetEntity budgetEntity)\n${SqfBudget.tableName}でinsert\n  budgetEntity: \n$budgetEntity \nid: $id');
    } catch (e) {
      logger.e('[FAIL]: $e');
    }
    
  }

  @override
  void update(BudgetEntity budgetEntity) {
    db.update(
        SqfBudget.tableName,
        {
          SqfBudget.expenseBigCategoryId: budgetEntity.expenseBigCategoryId,
          SqfBudget.month: budgetEntity.month,
          SqfBudget.price: budgetEntity.price
        },
        budgetEntity.id);
    logger.i(
        '====SQLが実行されました====\n ImplementsBudgetRepository update(BudgetEntity budgetEntity)\n ${SqfBudget.tableName}でupdate\n budgetEntity: \n$budgetEntity');
  }

  @override
  void delete(int id) async {
    await db.delete(SqfBudget.tableName, id);
    logger.i('${SqfBudget.tableName}で$idのレコードを削除しました');
  }

  @override
  Future<bool> hasData(BudgetEntity entity) async {
    final sql =
        'SELECT EXISTS(SELECT 1 FROM ${SqfBudget.tableName} WHERE ${SqfBudget.id}=${entity.id})';

    final result = await db.hasData(sql);

    return result;
  }
}
