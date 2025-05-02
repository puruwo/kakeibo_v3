import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/providerLogger.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsSmallCategoryRepository implements ExpenseSmallCategoryRepository {
  // カテゴリーNumberを指定して取得する
  @override
  Future<ExpenseSmallCategoryEntity> fetchBySmallCategory(
      {required int smallCategoryId}) async {
    final sql = '''
      SELECT 
        a._id AS id,
        a.small_category_order_key AS smallCategoryOrderKey,
        a.big_category_key AS bigCategoryKey,
        a.displayed_order_in_big AS displayedOrderInBig,
        a.category_name AS smallCategoryName,
        a.default_displayed AS defaultDisplayed
      FROM TBL201 a
      where a._id = $smallCategoryId;
    ''';

    try {
      final jsonList = await db.query(sql);

      final results = ExpenseSmallCategoryEntity.fromJson(jsonList[0]);

      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return const ExpenseSmallCategoryEntity(
        id: 0,
        smallCategoryOrderKey: 0,
        bigCategoryKey: 0,
        displayedOrderInBig: 0,
        smallCategoryName: '',
        defaultDisplayed: 0,
      );
    }
  }

  @override
  Future<List<ExpenseSmallCategoryEntity>> fetchAll() async {
    const sql = '''
      SELECT 
        a._id AS id,
        a.small_category_order_key AS smallCategoryOrderKey,
        a.big_category_key AS bigCategoryKey,
        a.displayed_order_in_big AS displayedOrderInBig,
        a.category_name AS smallCategoryName,
        a.default_displayed AS defaultDisplayed
      FROM TBL201 a;
    ''';

    // SQLを実行して結果を取得
    final jsonList = await db.query(sql);

    // 取得したjsonListをSmallCategoryEntityのリストに変換
    final result = jsonList.map((e) {
      return ExpenseSmallCategoryEntity.fromJson(e);
    }).toList();

    return result;
  }

  @override
  Future<List<ExpenseSmallCategoryEntity>> fetchByBigCategory(
      {required int bigCategoryId}) {
    // TODO: implement fetchByBigCategory
    throw UnimplementedError();
  }
}
