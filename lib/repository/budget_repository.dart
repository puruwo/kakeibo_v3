import 'package:kakeibo/domain/core/month_value/month_value.dart';
import 'package:kakeibo/domain/db/budget/budget_entity.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/providerLogger.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsBudgetRepository implements BudgetRepository {
  // 全ての支出情報を取得する
  @override
  Future<List<BudgetEntity>> fetchMonthly({required MonthValue month}) async {
    final sql = '''
      SELECT 
        a.${SqfBudget.id} AS id,
        a.${SqfBudget.expenseBigCategoryId} AS expenseBigCategoryId,  
        a.${SqfBudget.month} AS month,
        a.${SqfBudget.price} AS price
      FROM ${SqfBudget.tableName} a
      WHERE a.${SqfBudget.month} = ${month.month}
      ORDER BY a.${SqfBudget.id} ASC;
    ''';

    try {
      final jsonList = await db.query(sql);
      logger.i(
          '====SQLが実行されました====\n ImplementsBudgetRepository fetchAll()\n$sql');

      final results =
          jsonList.map((json) => BudgetEntity.fromJson(json)).toList();

      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return [];
    }
  }

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
      final jsonList = await db.query(sql);
      logger.i(
          '====SQLが実行されました====\n ImplementsBudgetRepository fetchAll()\n$sql');

      final results = jsonList[0]['totalPrice'] as int;

      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return 0;
    }
  }

  @override
  void insert(BudgetEntity budgetEntity) {
    db.insert(SqfBudget.tableName, {
      SqfBudget.expenseBigCategoryId: budgetEntity.expenseBigCategoryId,
      SqfBudget.month: budgetEntity.month,
      SqfBudget.price: budgetEntity.price
    });
    logger.i(
        '====SQLが実行されました====\n ImplementsBudgetRepository insert(BudgetEntity budgetEntity)\n${SqfBudget.tableName}でinsert\n  budgetEntity: \n$budgetEntity');
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
}
