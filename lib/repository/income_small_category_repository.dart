import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/logger.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsIncomeSmallCategoryRepository
    implements IncomeSmallCategoryRepository {
  // カテゴリーNumberを指定して取得する
  @override
  Future<IncomeSmallCategoryEntity> fetchBySmallCategory(
      {required int smallCategoryId}) async {
    final sql = '''
      SELECT
        a.${SqfIncomeSmallCategory.id} AS id,
        a.${SqfIncomeSmallCategory.smallCategoryOrderKey} AS smallCategoryOrderKey,
        a.${SqfIncomeSmallCategory.bigCategoryKey} AS bigCategoryKey,
        a.${SqfIncomeSmallCategory.displayedOrderInBig} AS displayedOrderInBig,
        a.${SqfIncomeSmallCategory.name} AS smallCategoryName,
        a.${SqfIncomeSmallCategory.defaultDisplayed} AS defaultDisplayed
      FROM ${SqfIncomeSmallCategory.tableName} a
      where a.${SqfIncomeSmallCategory.id} = $smallCategoryId;
    ''';

    try {
      final jsonList = await db.query(sql);

      final results = IncomeSmallCategoryEntity.fromJson(jsonList[0]);

      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return const IncomeSmallCategoryEntity(
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
  Future<List<IncomeSmallCategoryEntity>> fetchAll() async {
    const sql = '''
      SELECT
        a.${SqfIncomeSmallCategory.id} AS id,
        a.${SqfIncomeSmallCategory.smallCategoryOrderKey} AS smallCategoryOrderKey,
        a.${SqfIncomeSmallCategory.bigCategoryKey} AS bigCategoryKey,
        a.${SqfIncomeSmallCategory.displayedOrderInBig} AS displayedOrderInBig,
        a.${SqfIncomeSmallCategory.name} AS smallCategoryName,
        a.${SqfIncomeSmallCategory.defaultDisplayed} AS defaultDisplayed
      FROM ${SqfIncomeSmallCategory.tableName} a
      ORDER BY a.${SqfIncomeSmallCategory.id} ASC;
    ''';

    final jsonList = await db.query(sql);

    final result = jsonList.map((e) {
      return IncomeSmallCategoryEntity.fromJson(e);
    }).toList();

    return result;
  }

  @override
  Future<List<IncomeSmallCategoryEntity>> fetchByBigCategory(
      {required int bigCategoryId}) async {
    final sql = '''
      SELECT
        a.${SqfIncomeSmallCategory.id} AS id,
        a.${SqfIncomeSmallCategory.smallCategoryOrderKey} AS smallCategoryOrderKey,
        a.${SqfIncomeSmallCategory.bigCategoryKey} AS bigCategoryKey,
        a.${SqfIncomeSmallCategory.displayedOrderInBig} AS displayedOrderInBig,
        a.${SqfIncomeSmallCategory.name} AS smallCategoryName,
        a.${SqfIncomeSmallCategory.defaultDisplayed} AS defaultDisplayed
      FROM ${SqfIncomeSmallCategory.tableName} a
      WHERE a.${SqfIncomeSmallCategory.bigCategoryKey} = $bigCategoryId
      ORDER BY a.${SqfIncomeSmallCategory.displayedOrderInBig} ASC;
    ''';

    final jsonList = await db.query(sql);

    final result = jsonList.map((e) {
      return IncomeSmallCategoryEntity.fromJson(e);
    }).toList();

    return result;
  }

  @override
  Future<int> add({required IncomeSmallCategoryEntity entity}) async {
    final id = await db.insert(
      SqfIncomeSmallCategory.tableName,
      {
        SqfIncomeSmallCategory.bigCategoryKey: entity.bigCategoryKey,
        SqfIncomeSmallCategory.name: entity.smallCategoryName,
        SqfIncomeSmallCategory.smallCategoryOrderKey:
            entity.smallCategoryOrderKey,
        SqfIncomeSmallCategory.displayedOrderInBig: entity.displayedOrderInBig,
        SqfIncomeSmallCategory.defaultDisplayed: entity.defaultDisplayed,
      },
    );
    return id;
  }

  @override
  Future<void> update({required IncomeSmallCategoryEntity entity}) async {
    await db.update(
      SqfIncomeSmallCategory.tableName,
      {
        SqfIncomeSmallCategory.bigCategoryKey: entity.bigCategoryKey,
        SqfIncomeSmallCategory.name: entity.smallCategoryName,
        SqfIncomeSmallCategory.smallCategoryOrderKey:
            entity.smallCategoryOrderKey,
        SqfIncomeSmallCategory.displayedOrderInBig: entity.displayedOrderInBig,
        SqfIncomeSmallCategory.defaultDisplayed: entity.defaultDisplayed,
      },
      entity.id,
    );
  }

  @override
  Future<void> delete({required int id}) async {
    await db.delete(SqfIncomeSmallCategory.tableName, id);
  }

  @override
  Future<List<int>> deleteByBigCategory({required int bigCategoryId}) async {
    // 削除対象の小カテゴリーIDを取得
    final ids =
        await fetchSmallCategoryIdListByBigCategoryId(bigCategoryId: bigCategoryId);

    for (final id in ids) {
      await db.delete(SqfIncomeSmallCategory.tableName, id);
    }
    return ids;
  }

  /// 小カテゴリーの最大の表示順序を取得する（全カテゴリー対象）
  @override
  Future<int> getMaxSmallCategoryOrderKey({required int bigCategoryId}) async {
    const sql = '''
      SELECT MAX(${SqfIncomeSmallCategory.smallCategoryOrderKey}) AS maxOrderKey
      FROM ${SqfIncomeSmallCategory.tableName};
    ''';

    final jsonList = await db.query(sql);

    if (jsonList.isNotEmpty && jsonList[0]['maxOrderKey'] != null) {
      return jsonList[0]['maxOrderKey'] as int;
    } else {
      return 0;
    }
  }

  @override
  Future<List<int>> fetchSmallCategoryIdListByBigCategoryId(
      {required int bigCategoryId}) async {
    final sql = '''
      SELECT ${SqfIncomeSmallCategory.id} as smallCategoryId
      FROM ${SqfIncomeSmallCategory.tableName}
      WHERE ${SqfIncomeSmallCategory.bigCategoryKey} = $bigCategoryId;
    ''';
    final jsonList = await db.query(sql);
    return jsonList.map((e) => e['smallCategoryId'] as int).toList();
  }
}
