import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/logger.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsIncomeBigCategoryRepository
    implements IncomeBigCategoryRepository {
  @override
  Future<List<IncomeBigCategoryEntity>> fetchAll() async {
    // カテゴリーを指定しないで取得する
    const sql =
        '''
      SELECT
        a.${SqfIncomeBigCategory.id} AS id,
        a.${SqfIncomeBigCategory.name} AS name,
        a.${SqfIncomeBigCategory.colorCode} AS colorCode,
        a.${SqfIncomeBigCategory.resourcePath} AS iconPath,
        a.${SqfIncomeBigCategory.accountType} AS accountType,
        a.${SqfIncomeBigCategory.deleteFlag} AS deleteFlag
      FROM ${SqfIncomeBigCategory.tableName} a
      ORDER BY a.${SqfIncomeBigCategory.id} ASC;
    ''';

    try {
      final jsonList = await db.query(sql);
      // logger.i('====SQLが実行されました====\n ImplementsBigCategoryRepository\n$sql');

      final results = jsonList
          .map((e) => IncomeBigCategoryEntity.fromJson(e))
          .toList();

      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return const [
        IncomeBigCategoryEntity(id: 0, name: '', colorCode: '', iconPath: ''),
      ];
    }
  }

  @override
  Future<IncomeBigCategoryEntity> fetchByBigCategory({
    required int bigCategoryId,
  }) async {
    // カテゴリーidを指定して大カテゴリーを取得する
    final sql =
        '''
      SELECT
        a.${SqfIncomeBigCategory.id} AS id,
        a.${SqfIncomeBigCategory.name} AS name,
        a.${SqfIncomeBigCategory.colorCode} AS colorCode,
        a.${SqfIncomeBigCategory.resourcePath} AS iconPath,
        a.${SqfIncomeBigCategory.accountType} AS accountType,
        a.${SqfIncomeBigCategory.deleteFlag} AS deleteFlag
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
    final id = await db.insert(SqfIncomeBigCategory.tableName, {
      SqfIncomeBigCategory.name: entity.name,
      SqfIncomeBigCategory.colorCode: entity.colorCode,
      SqfIncomeBigCategory.resourcePath: entity.iconPath,
      SqfIncomeBigCategory.accountType: entity.accountType,
    });
    return id;
  }

  @override
  Future<void> update({required IncomeBigCategoryEntity entity}) async {
    await db.update(SqfIncomeBigCategory.tableName, {
      SqfIncomeBigCategory.name: entity.name,
      SqfIncomeBigCategory.colorCode: entity.colorCode,
      SqfIncomeBigCategory.resourcePath: entity.iconPath,
      SqfIncomeBigCategory.accountType: entity.accountType,
    }, entity.id);
  }

  @override
  Future<List<IncomeBigCategoryEntity>> fetchAllActive() async {
    final list = await fetchAll();
    return list.where((e) => e.deleteFlag == 0).toList();
  }

  // 既定カテゴリー（月次収入・ボーナス）は他機能で参照されているため削除させない
  // 行は消さずに論理削除する（登録済みの収入の参照先を残すため。KP-024）
  @override
  Future<void> delete({required int id}) async {
    if (IncomeBigCategoryConstants.isDefaultCategory(id)) {
      throw StateError('id=1（月次収入）/ id=2（ボーナス）は削除できません');
    }
    await db.update(
      SqfIncomeBigCategory.tableName,
      {SqfIncomeBigCategory.deleteFlag: 1},
      id,
    );
  }

  @override
  Future<int> getMaxId() async {
    const sql =
        '''
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
