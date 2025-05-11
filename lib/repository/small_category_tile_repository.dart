import 'package:intl/intl.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_entity.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_repository.dart';
import 'package:kakeibo/logger.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsSmallCategoryTileRepository implements SmallCategoryTileRepository {

  @override
  Future<List<SmallCategoryTileEntity>> fetchAll({required int bigCategoryId,required DateTime fromDate,required DateTime toDate}) async {

    //  {
    //  _id:
    //  small_category_payment_sum:
    //  big_category_key:
    //  tdisplayed_order_in_big:
    //  category_name:
    //  default_displaye:
    //  }

    final sql = '''
                SELECT  
                  t1.${SqfExpenseSmallCategory.id} AS id,
                  t1.${SqfExpenseSmallCategory.displayedOrderInBig} AS displayedOrder,
                  t1.${SqfExpenseSmallCategory.name} AS smallCategoryName,
                  coalesce(t2.small_category_payment_sum,0) AS totalExpenseBySmallCategory ,
                  t1.${SqfExpenseSmallCategory.bigCategoryKey} AS bigCategoryKey,
                  t1.${SqfExpenseSmallCategory.defaultDisplayed} AS defaultDisplayed 
                FROM ${SqfExpenseSmallCategory.tableName} t1 
                LEFT JOIN(
                  SELECT *,
                  SUM(x.price) as small_category_payment_sum 
                  FROM ${SqfExpense.tableName} x
                  WHERE (x.${SqfExpense.date} >= ${DateFormat('yyyyMMdd').format(fromDate)}  AND x.${SqfExpense.date} <=${DateFormat('yyyyMMdd').format(toDate)} )
                  GROUP BY x.${SqfExpense.expenseSmallCategoryId}
                ) t2
                ON t2.${SqfExpense.expenseSmallCategoryId} = t1.${SqfExpenseSmallCategory.id}
                INNER JOIN ${SqfExpenseBigCategory.tableName} t3
                ON t1.${SqfExpenseSmallCategory.bigCategoryKey} = t3.${SqfExpenseBigCategory.id}
                WHERE t1.${SqfExpenseSmallCategory.bigCategoryKey} = $bigCategoryId
                AND NOT(t1.${SqfExpenseSmallCategory.defaultDisplayed} = 0 AND t2.small_category_payment_sum IS NULL)
                ORDER BY t1.${SqfExpenseSmallCategory.displayedOrderInBig};
                ''';
    
    // 実行
    final mapList = await db.query(sql);
    
    logger.i('====SQLが実行されました====\n ImplementsSmallCategoryTileRepository\n$sql');

    // 各カテゴリーmapでEntity化
    final List<SmallCategoryTileEntity> categoryEntityList = mapList.map((json) => SmallCategoryTileEntity.fromJson(json)).toList();

    return categoryEntityList;
  }
}