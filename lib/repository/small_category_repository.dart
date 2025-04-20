import 'package:kakeibo/domain/tbl201/small_category_entity.dart';
import 'package:kakeibo/domain/tbl201/small_category_repository.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/providerLogger.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsSmallCategoryRepository implements SmallCategoryRepository {
  
  // カテゴリーNumberを指定して取得する
  @override
  Future<SmallCategoryEntity> fetch({required int id}) async {
    final sql = '''
      SELECT 
        a._id AS id,
        a.small_category_order_key AS smallCategoryOrderKey,
        a.big_category_key AS bigCategoryKey,
        a.displayed_order_in_big AS displayedOrderInBig,
        a.category_name AS smallCategoryName,
        a.default_displayed AS defaultDisplayed
      FROM TBL201 a
      where a._id = $id;
    ''';

    try {
      final jsonList = await db.query(sql);

      final results = SmallCategoryEntity.fromJson(jsonList[0]);

      return results;
    } catch (e) {

      logger.e('[FAIL]: $e');
      return const SmallCategoryEntity(
        id: 0,
        smallCategoryOrderKey: 0,
        bigCategoryKey: 0,
        displayedOrderInBig: 0,
        smallCategoryName: '',
        defaultDisplayed: 0,
      );
    }
  }
}
