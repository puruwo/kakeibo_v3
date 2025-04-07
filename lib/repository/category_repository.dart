import 'package:intl/intl.dart';
import 'package:kakeibo/domain/category_entity/category_repository.dart';
import 'package:kakeibo/domain/category_entity/category_entity.dart';
import 'package:kakeibo/model/database_helper.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsCategoryRepository implements CategoryRepository {

  @override
  Future<List<CategoryEntity>> fetchAll({required DateTime fromDate, required DateTime toDate}) async {
    final sql = '''
                  SELECT  
                    t1._id AS id, 
                    t1.color_code AS categoryColor,
                    t1.big_category_name AS bigCategoryName,
                    t1.resource_path AS categoryIconPath,
                    t3.price AS budget,
                    COALESCE(t2.price_sum, 0) AS totalExpenseByBigCategory
                  FROM TBL202 t1
                  LEFT JOIN (
                    SELECT
                      big_category_key,
                      price_sum
                    FROM (
                      SELECT 
                        y.big_category_key,
                        SUM(z.price) as price_sum 
                      FROM TBL001 z
              	  		INNER JOIN TBL201 y
                      ON z.payment_category_id = y._id
                      WHERE (z.date >= '${DateFormat('yyyyMMdd').format(fromDate)}' AND z.date <= '${DateFormat('yyyyMMdd').format(toDate)}')
                      GROUP BY y.big_category_key
                    )
                  ) t2
                  ON t1._id = t2.big_category_key
                  LEFT JOIN(
                    SELECT 
                      MAX(date) AS max_date,
                      *
                    FROM TBL003
                    GROUP BY big_category_id
                  ) t3 
                  ON t1._id = t3.big_category_id
                  WHERE NOT (t1.is_displayed = 0 AND t2.big_category_key IS NULL)
                  ORDER BY t1.display_order ASC;
                ''';
    
    // 実行
    final mapList = await db.query(sql);

    // 各カテゴリーmapでEntity化
    final List<CategoryEntity> categoryEntityList = mapList.map((json) => CategoryEntity.fromJson(json)).toList();

    return categoryEntityList;
  }
}