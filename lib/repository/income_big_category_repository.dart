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
      FROM ${SqfIncomeBigCategory.tableName} a
      ORDER BY a.${SqfIncomeBigCategory.id} ASC;
    ''';

    try {
      final jsonList = await db.query(sql);
      // logger.i('====SQLが実行されました====\n ImplementsBigCategoryRepository\n$sql');

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
    // カテゴリーidを指定して大カテゴリーを取得する
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
      // logger.i(
      //     '====SQLが実行されました====\n ImplementsBigCategoryRepository fetchByBigCategory(int bigCategoryId)\n$sql');

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

  @override
  Future<int> add({required IncomeBigCategoryEntity entity}) async {
    final id = await db.insert(
      SqfIncomeBigCategory.tableName,
      {
        SqfIncomeBigCategory.name: entity.name,
        SqfIncomeBigCategory.colorCode: entity.colorCode,
        SqfIncomeBigCategory.resourcePath: entity.iconPath,
      },
    );
    return id;
  }

  @override
  Future<void> update({required IncomeBigCategoryEntity entity}) async {
    await db.update(
      SqfIncomeBigCategory.tableName,
      {
        SqfIncomeBigCategory.name: entity.name,
        SqfIncomeBigCategory.colorCode: entity.colorCode,
        SqfIncomeBigCategory.resourcePath: entity.iconPath,
      },
      entity.id,
    );
  }

  // id=1（月次収入）/ id=2（ボーナス）は他機能でハードコード参照されているため削除させない
  @override
  Future<void> delete({required int id}) async {
    if (id == 1 || id == 2) {
      throw StateError('id=1（月次収入）/ id=2（ボーナス）は削除できません');
    }
    await db.delete(SqfIncomeBigCategory.tableName, id);
  }

  @override
  Future<int> getMaxId() async {
    const sql = '''
      SELECT MAX(${SqfIncomeBigCategory.id}) AS maxId
      FROM ${SqfIncomeBigCategory.tableName};
    ''';
    final jsonList = await db.query(sql);
    if (jsonList.isNotEmpty && jsonList[0]['maxId'] != null) {
      return jsonList[0]['maxId'] as int;
    } else {
      return 0;
    }
  }
}
