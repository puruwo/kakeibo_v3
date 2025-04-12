import 'package:intl/intl.dart';
import 'package:kakeibo/domain/all_category_entity/all_category_entity.dart';
import 'package:kakeibo/domain/all_category_entity/all_category_repository.dart';
import 'package:kakeibo/model/database_helper.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsAllCategoryRepository implements AllCategoryRepository {

  @override
  Future<AllCategoryEntity> fetch({required DateTime fromDate, required DateTime toDate}) async {
    final sqlForExpence = '''
            SELECT COALESCE(SUM(price),0) as totalExpense FROM TBL001 
            WHERE date >= ${DateFormat('yyyyMMdd').format(fromDate)} AND date <= ${DateFormat('yyyyMMdd').format(toDate)} 
            ;
            ''';
    
    // 実行
    final expenceMapList = await db.query(sqlForExpence);

    const sqlForBudget = '''
            SELECT COALESCE(SUM(a.price),0)  as totalBudget
            FROM TBL003 a
              INNER JOIN TBL202 b
              ON a.big_category_id = b._id
            WHERE date = (
              SELECT MAX(date)
              FROM TBL003 a2
              WHERE a.big_category_id = a2.big_category_id
            )
            ORDER BY b.display_order 
            ;
            ''';

    // 実行
    final budgetMapList = await db.query(sqlForBudget);

    // Listから要素を取り出しEntity化
    // 今回は1行しかないので0番目を取り出す
    final mergedMap = {
      ...expenceMapList[0].isEmpty ? {'totalExpense': 0} : expenceMapList[0],
      ...budgetMapList[0].isEmpty ? {'totalBudget': 0} : budgetMapList[0],
    };

    return AllCategoryEntity.fromJson(mergedMap);
  }
}