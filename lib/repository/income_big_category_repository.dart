import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/logger.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsIncomeBigCategoryRepository implements IncomeBigCategoryRepository {
  @override
  Future<List<IncomeBigCategoryEntity>> fetchAll() async {
    // カテゴリーを指定しないで取得する
    const sql = '''
      SELECT 
        a.${SqfIncomeBigCategory.id} AS id,
        a.${SqfIncomeBigCategory.name} AS name, 
        a.${SqfIncomeBigCategory.colorCode} AS colorCode,
        a.${SqfIncomeBigCategory.resourcePath} AS iconPath
      FROM ${SqfIncomeBigCategory.tableName} a;
    ''';

    try {
      final jsonList = await db.query(sql);
      logger.i('====SQLが実行されました====\n ImplementsBigCategoryRepository\n$sql');

      final results =
          jsonList.map((e) => IncomeBigCategoryEntity.fromJson(e)).toList();

      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return const [
        IncomeBigCategoryEntity(
          id: 0,
          name: '',
          colorCode: '',
          iconPath: '',
        )
      ];
    }
  }

  @override
  Future<IncomeBigCategoryEntity> fetchByBigCategory(
      {required int bigCategoryId}) async {
    // カテゴリーを指定して取得する
    final sql = '''
      SELECT 
        a.${SqfIncomeBigCategory.id} AS id,
        a.${SqfIncomeBigCategory.name} AS name, 
        a.${SqfIncomeBigCategory.colorCode} AS colorCode,
        a.${SqfIncomeBigCategory.resourcePath} AS iconPath
      FROM ${SqfIncomeBigCategory.tableName} a
      where a.${SqfIncomeBigCategory.id} = $bigCategoryId;
    ''';

    try {
      final jsonList = await db.query(sql);
      logger.i(
          '====SQLが実行されました====\n ImplementsBigCategoryRepository fetchByBigCategory(int bigCategoryId)\n$sql');

      final results = IncomeBigCategoryEntity.fromJson(jsonList[0]);

      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return const IncomeBigCategoryEntity(
        id: 0,
        name: '',
        colorCode: '',
        iconPath: '',
      );
    }
  }
}
