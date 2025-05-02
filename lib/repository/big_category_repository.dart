import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/providerLogger.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsBigCategoryRepository implements ExpenseBigCategoryRepository {
  
  @override
  Future<ExpenseBigCategoryEntity> fetchAll() {
    // TODO: implement fetchAll
    throw UnimplementedError();
  }

  // カテゴリーを指定しないで取得する
  @override
  Future<ExpenseBigCategoryEntity> fetchByBigCategory({required int bigCategoryId}) async {

    final sql = '''
      SELECT 
        a._id AS id,
        a.color_code AS colorCode,
        a.big_category_name AS bigCategoryName, 
        a.resource_path AS resourcePath, 
        a.display_order AS displayOrder, 
        a.is_displayed AS isDisplayed
      FROM TBL202 a
      where a._id = $bigCategoryId;
    ''';

    try {
      final jsonList = await db.query(sql);

      final results = ExpenseBigCategoryEntity.fromJson(jsonList[0]);

      return results;
    } catch (e) {

      logger.e('[FAIL]: $e');
      return const ExpenseBigCategoryEntity(
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