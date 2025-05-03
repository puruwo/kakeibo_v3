import 'package:intl/intl.dart';
import 'package:kakeibo/domain/core/all_category_accounting_entity/all_category_accounting_entity.dart';
import 'package:kakeibo/domain/core/all_category_accounting_entity/all_category_accounting_repository.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/sql_sentence.dart';
import 'package:kakeibo/model/table_calmn_name.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsAllCategoryAccountingRepository implements AllCategoryAccountingRepository {

  @override
  Future<AllCategoryAccountingEntity> fetch({required DateTime fromDate, required DateTime toDate}) async {
    final sqlForExpence = '''
            SELECT COALESCE(SUM(price),0) as totalExpense FROM ${SqfExpense.tableName} 
            WHERE date >= ${DateFormat('yyyyMMdd').format(fromDate)} AND date <= ${DateFormat('yyyyMMdd').format(toDate)} 
            ;
            ''';
    
    // 実行
    final expenceMapList = await db.query(sqlForExpence);

    logger.i('====SQLが実行されました====\n ImplementsAllCategoryAccountingRepository\n$sqlForExpence');

    const sqlForBudget = '''
            SELECT COALESCE(SUM(a.${SqfBudget.price}),0)  as totalBudget
            FROM ${SqfBudget.tableName} a
              INNER JOIN ${SqfExpenseBigCategory.tableName} b
              ON a.${SqfBudget.expenseBigCategoryId} = b._id
            WHERE date = (
              SELECT MAX(date)
              FROM ${SqfBudget.tableName} a2
              WHERE a.${SqfBudget.expenseBigCategoryId} = a2.${SqfBudget.expenseBigCategoryId}
            )
            ORDER BY b.${SqfExpenseBigCategory.displayOrder} 
            ;
            ''';

    // 実行
    final budgetMapList = await db.query(sqlForBudget);
    logger.i('====SQLが実行されました====\n ImplementsAllCategoryAccountingRepository$sqlForBudget');

    // Listから要素を取り出しEntity化
    // 今回は1行しかないので0番目を取り出す
    final mergedMap = {
      ...expenceMapList[0].isEmpty ? {'totalExpense': 0} : expenceMapList[0],
      ...budgetMapList[0].isEmpty ? {'totalBudget': 0} : budgetMapList[0],
    };

    return AllCategoryAccountingEntity.fromJson(mergedMap);
  }
}