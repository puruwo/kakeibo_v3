import 'package:intl/intl.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/providerLogger.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsIncomeRepository implements IncomeRepository {
  // 全ての支出情報を取得する
  @override
  Future<List<IncomeEntity>> fetchAll() async {
    const sql = '''
      SELECT 
        a.${SqfIncome.id} AS id,
        a.${SqfIncome.incomeSmallCategoryId} AS categoryId,  
        a.${SqfIncome.date} AS date,
        a.${SqfIncome.price} AS price, 
        a.${SqfIncome.memo} AS memo
      FROM ${SqfIncome.tableName} a
      ORDER BY a.${SqfIncome.id} ASC;
    ''';

    try {
      final jsonList = await db.query(sql);
      logger.i(
          '====SQLが実行されました====\n ImplementsIncomeRepository fetchAll()\n$sql');

      final results =
          jsonList.map((json) => IncomeEntity.fromJson(json)).toList();

      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return [];
    }
  }

  // 大カテゴリーと期間を指定して取得する
  @override
  Future<List<IncomeEntity>> fetchWithCategoryAndPeriod({
    required MonthPeriodValue period,
    required int categoryId,
  }) async {
    /*
    SELECT income.*
    FROM income
    INNER JOIN income_small_category 
      ON income.income_small_category_id = income_small_category._id
    INNER JOIN income_big_category 
      ON income_small_category.big_category_key = income_big_category._id
    WHERE income_big_category._id = 1
    	AND '20250425' <= income.date  AND income.date <= '20250524';
    */

    final sql = '''
      SELECT 
        a.${SqfIncome.id} AS id,
        a.${SqfIncome.incomeSmallCategoryId} AS categoryId,  
        a.${SqfIncome.date} AS date,
        a.${SqfIncome.price} AS price, 
        a.${SqfIncome.memo} AS memo
      FROM ${SqfIncome.tableName} a
      INNER JOIN ${SqfIncomeSmallCategory.tableName} b
      ON a.${SqfIncome.incomeSmallCategoryId} = b.${SqfIncomeSmallCategory.id}
      INNER JOIN ${SqfIncomeBigCategory.tableName} c
      ON b.${SqfIncomeSmallCategory.bigCategoryKey} = c.${SqfIncomeBigCategory.id}
      WHERE c.${SqfIncomeBigCategory.id} = $categoryId 
      AND a.${SqfIncome.date} >= ${DateFormat('yyyyMMdd').format(period.startDatetime)} AND a.${SqfIncome.date} <= ${DateFormat('yyyyMMdd').format(period.endDatetime)} 
      ;
    ''';

    try {
      final jsonList = await db.query(sql);
      logger.i(
          '====SQLが実行されました====\n ImplementsIncomeRepository fetchWithCategoryAndPeriod(MonthPeriodValue period,int categoryId)\n$sql');

      final results =
          jsonList.map((json) => IncomeEntity.fromJson(json)).toList();

      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return [];
    }
  }

  @override
  void insert(IncomeEntity incomeEntity) {
    db.insert(SqfIncome.tableName, {
      SqfIncome.incomeSmallCategoryId: incomeEntity.categoryId,
      SqfIncome.date: incomeEntity.date,
      SqfIncome.price: incomeEntity.price,
      SqfIncome.memo: incomeEntity.memo
    });
    logger.i(
        '====SQLが実行されました====\n ImplementsIncomeRepository insert(IncomeEntity incomeEntity)\n${SqfIncome.tableName}でinsert\n  incomeEntity: \n$incomeEntity');
  }

  @override
  void update(IncomeEntity incomeEntity) {
    db.update(
        SqfIncome.tableName,
        {
          SqfIncome.incomeSmallCategoryId: incomeEntity.categoryId,
          SqfIncome.date: incomeEntity.date,
          SqfIncome.price: incomeEntity.price,
          SqfIncome.memo: incomeEntity.memo
        },
        incomeEntity.id);
    logger.i(
        '====SQLが実行されました====\n ImplementsIncomeRepository update(IncomeEntity incomeEntity)\n ${SqfIncome.tableName}でupdate\n incomeEntity: \n$incomeEntity');
  }

  @override
  void delete(int id) async {
    await db.delete(SqfIncome.tableName, id);
    logger.i('${SqfIncome.tableName}で$idのレコードを削除しました');
  }
}
