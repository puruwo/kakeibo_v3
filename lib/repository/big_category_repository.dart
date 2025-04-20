import 'package:kakeibo/domain/tbl202/big_category_entity.dart';
import 'package:kakeibo/domain/tbl202/big_category_repository.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/providerLogger.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsBigCategoryRepository implements BigCategoryRepository {

  // カテゴリーを指定しないで取得する
  @override
  Future<BigCategoryEntity> fetch({required int id}) async {

    final sql = '''
      SELECT 
        a._id AS id,
        a.color_code AS colorCode,
        a.big_category_name AS bigCategoryName, 
        a.resource_path AS resourcePath, 
        a.display_order AS displayOrder, 
        a.is_displayed AS isDisplayed
      FROM TBL202 a
      where a._id = $id;
    ''';

    try {
      final jsonList = await db.query(sql);

      final results = BigCategoryEntity.fromJson(jsonList[0]);

      return results;
    } catch (e) {

      logger.e('[FAIL]: $e');
      return const BigCategoryEntity(
        id: 0,
        colorCode: '',
        bigCategoryName: '',
        resourcePath: '',
        displayOrder: 0,
        isDisplayed: 0,
      );
    }
  }
}