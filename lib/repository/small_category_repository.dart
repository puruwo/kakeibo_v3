import 'package:intl/intl.dart';
import 'package:kakeibo/domain/small_category_entity/small_category_repository.dart';
import 'package:kakeibo/domain/small_category_entity/small_category_entity.dart';
import 'package:kakeibo/model/database_helper.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsSmallCategoryRepository implements SmallCategoryRepository {

  @override
  Future<List<SmallCategoryEntity>> fetchAll({required int bigCategoryId,required DateTime fromDate,required DateTime toDate}) async {

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
                  t1._id AS id,
                  t1.displayed_order_in_big AS displayedOrder,
                  t1.category_name AS smallCategoryName,
                  coalesce(t2.small_category_payment_sum,0) AS totalExpenseBySmallCategory ,
                  t1.big_category_key AS bigCategoryKey,
                  t1.default_displayed AS defaultDisplayed 
                FROM TBL201 t1 
                LEFT JOIN(
                  SELECT *,
                  SUM(x.price) as small_category_payment_sum 
                  FROM TBL001 x
                  WHERE (x.date >= ${DateFormat('yyyyMMdd').format(fromDate)}  AND x.date <=${DateFormat('yyyyMMdd').format(toDate)} )
                  GROUP BY x.payment_category_id
                ) t2
                ON t2.payment_category_id = t1._id
                INNER JOIN TBL202 t3
                ON t1.big_category_key = t3._id
                WHERE t1.big_category_key = $bigCategoryId
                AND NOT(t1.default_displayed = 0 AND t2.small_category_payment_sum IS NULL)
                ORDER BY t1.displayed_order_in_big;
                ''';
    
    // 実行
    final mapList = await db.query(sql);

    // 各カテゴリーmapでEntity化
    final List<SmallCategoryEntity> categoryEntityList = mapList.map((json) => SmallCategoryEntity.fromJson(json)).toList();

    return categoryEntityList;
  }
}