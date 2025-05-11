import 'package:intl/intl.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_repository.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_entity.dart';
import 'package:kakeibo/logger.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsCategoryAccountingRepository implements CategoryAccountingRepository {

  @override
  Future<List<CategoryAccountingEntity>> fetchAll({required DateTime fromDate, required DateTime toDate}) async {
    final sql = '''
                  SELECT  
                    t1.${SqfExpenseBigCategory.id} AS id, 
                    t1.${SqfExpenseBigCategory.colorCode} AS categoryColor,
                    t1.${SqfExpenseBigCategory.name} AS bigCategoryName,
                    t1.${SqfExpenseBigCategory.resourcePath} AS categoryIconPath,
                    t3.${SqfBudget.price} AS budget,
                    COALESCE(t2.price_sum, 0) AS totalExpenseByBigCategory
                  FROM ${SqfExpenseBigCategory.tableName} t1
                  LEFT JOIN (
                    SELECT
                      ${SqfExpenseSmallCategory.bigCategoryKey},
                      price_sum
                    FROM (
                      SELECT 
                        y.${SqfExpenseSmallCategory.bigCategoryKey},
                        COALESCE(SUM(z.${SqfExpense.price}),0) as price_sum 
                      FROM ${SqfExpense.tableName} z
              	  		INNER JOIN ${SqfExpenseSmallCategory.tableName} y
                      ON z.${SqfExpense.expenseSmallCategoryId} = y.${SqfExpenseSmallCategory.id}
                      WHERE (z.${SqfExpense.date} >= '${DateFormat('yyyyMMdd').format(fromDate)}' AND z.${SqfExpense.date} <= '${DateFormat('yyyyMMdd').format(toDate)}')
                      GROUP BY y.${SqfExpenseSmallCategory.bigCategoryKey}
                    )
                  ) t2
                  ON t1.${SqfExpenseBigCategory.id} = t2.${SqfExpenseSmallCategory.bigCategoryKey}
                  LEFT JOIN(
                    SELECT 
                      MAX(${SqfBudget.month}) AS max_date,
                      *
                    FROM ${SqfBudget.tableName}
                    GROUP BY ${SqfBudget.expenseBigCategoryId}
                  ) t3 
                  ON t1.${SqfExpenseBigCategory.id} = t3.${SqfBudget.expenseBigCategoryId}
                  WHERE NOT (t1.${SqfExpenseBigCategory.isDisplayed} = 0 AND t2.${SqfExpenseSmallCategory.bigCategoryKey} IS NULL)
                  ORDER BY t1.${SqfExpenseBigCategory.displayOrder} ASC;
                ''';
    
    // 実行
    final mapList = await db.query(sql);

    logger.i('====SQLが実行されました====\n ImplementsCategoryAccountingRepository\n$sql');

    // 各カテゴリーmapでEntity化
    final List<CategoryAccountingEntity> categoryEntityList = mapList.map((json) => CategoryAccountingEntity.fromJson(json)).toList();

    return categoryEntityList;
  }
}