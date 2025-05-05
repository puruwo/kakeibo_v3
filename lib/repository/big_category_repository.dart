import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/providerLogger.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsBigCategoryRepository implements ExpenseBigCategoryRepository {
  
  @override
  Future<ExpenseBigCategoryEntity> fetchAll() {
    // TODO: implement fetchAll
    throw UnimplementedError();
  }

  // カテゴリーを指定して取得する
  @override
  Future<ExpenseBigCategoryEntity> fetchByBigCategory({required int bigCategoryId}) async {

    final sql = '''
      SELECT 
        a.${SqfExpenseBigCategory.id} AS id,
        a.${SqfExpenseBigCategory.colorCode} AS colorCode,
        a.${SqfExpenseBigCategory.name} AS bigCategoryName, 
        a.${SqfExpenseBigCategory.resourcePath} AS resourcePath, 
        a.${SqfExpenseBigCategory.displayOrder} AS displayOrder, 
        a.${SqfExpenseBigCategory.isDisplayed} AS isDisplayed
      FROM ${SqfExpenseBigCategory.tableName} a
      where a.${SqfExpenseBigCategory.id} = $bigCategoryId;
    ''';

    try {
      final jsonList = await db.query(sql);
      logger.i('====SQLが実行されました====\n ImplementsBigCategoryRepository\n$sql');

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