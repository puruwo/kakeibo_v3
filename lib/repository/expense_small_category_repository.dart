import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/logger.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsExpenseSmallCategoryRepository
    implements ExpenseSmallCategoryRepository {
  // カテゴリーNumberを指定して取得する
  @override
  Future<ExpenseSmallCategoryEntity> fetchBySmallCategory(
      {required int smallCategoryId}) async {
    final sql = '''
      SELECT 
        a.${SqfExpenseSmallCategory.id} AS id,
        a.${SqfExpenseSmallCategory.smallCategoryOrderKey} AS smallCategoryOrderKey,
        a.${SqfExpenseSmallCategory.bigCategoryKey} AS bigCategoryKey,
        a.${SqfExpenseSmallCategory.displayedOrderInBig} AS displayedOrderInBig,
        a.${SqfExpenseSmallCategory.name} AS smallCategoryName,
        a.${SqfExpenseSmallCategory.defaultDisplayed} AS defaultDisplayed
      FROM ${SqfExpenseSmallCategory.tableName} a
      where a.${SqfExpenseSmallCategory.id} = $smallCategoryId;
    ''';

    try {
      final jsonList = await db.query(sql);

      // logger.i('====SQLが実行されました====\n ImplementsSmallCategoryRepository fetchBySmallCategory(int smallCategoryId)\n$sql');

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
        a.${SqfExpenseSmallCategory.id} AS id,
        a.${SqfExpenseSmallCategory.smallCategoryOrderKey} AS smallCategoryOrderKey,
        a.${SqfExpenseSmallCategory.bigCategoryKey} AS bigCategoryKey,
        a.${SqfExpenseSmallCategory.displayedOrderInBig} AS displayedOrderInBig,
        a.${SqfExpenseSmallCategory.name} AS smallCategoryName,
        a.${SqfExpenseSmallCategory.defaultDisplayed} AS defaultDisplayed
      FROM ${SqfExpenseSmallCategory.tableName} a
      ORDER BY a.${SqfExpenseSmallCategory.id} ASC;
    ''';

    // SQLを実行して結果を取得
    final jsonList = await db.query(sql);
    // logger.i('====SQLが実行されました====\n ImplementsSmallCategoryRepository fetchAll()\n$sql');

    // 取得したjsonListをSmallCategoryEntityのリストに変換
    final result = jsonList.map((e) {
      return ExpenseSmallCategoryEntity.fromJson(e);
    }).toList();

    return result;
  }

  @override
  Future<List<ExpenseSmallCategoryEntity>> fetchByBigCategory(
      {required int bigCategoryId}) async {
    final sql = '''
      SELECT 
        a.${SqfExpenseSmallCategory.id} AS id,
        a.${SqfExpenseSmallCategory.smallCategoryOrderKey} AS smallCategoryOrderKey,
        a.${SqfExpenseSmallCategory.bigCategoryKey} AS bigCategoryKey,
        a.${SqfExpenseSmallCategory.displayedOrderInBig} AS displayedOrderInBig,
        a.${SqfExpenseSmallCategory.name} AS smallCategoryName,
        a.${SqfExpenseSmallCategory.defaultDisplayed} AS defaultDisplayed
      FROM ${SqfExpenseSmallCategory.tableName} a
      WHERE a.${SqfExpenseSmallCategory.bigCategoryKey} = $bigCategoryId
      ORDER BY a.${SqfExpenseSmallCategory.displayedOrderInBig} ASC
      ;
    ''';

    // SQLを実行して結果を取得
    final jsonList = await db.query(sql);
    // logger.i('====SQLが実行されました====\n ImplementsSmallCategoryRepository fetchAll()\n$sql');

    // 取得したjsonListをSmallCategoryEntityのリストに変換
    final result = jsonList.map((e) {
      return ExpenseSmallCategoryEntity.fromJson(e);
    }).toList();

    return result;
  }

  @override
  Future<void> update({required ExpenseSmallCategoryEntity entity}) async {
    db.update(
        SqfExpenseSmallCategory.tableName,
        {
          SqfExpenseSmallCategory.id: entity.id,
          SqfExpenseSmallCategory.bigCategoryKey: entity.bigCategoryKey,
          SqfExpenseSmallCategory.name: entity.smallCategoryName,
          SqfExpenseSmallCategory.smallCategoryOrderKey:
              entity.smallCategoryOrderKey,
          SqfExpenseSmallCategory.displayedOrderInBig:
              entity.displayedOrderInBig,
          SqfExpenseSmallCategory.defaultDisplayed: entity.defaultDisplayed,
        },
        entity.id);
  }

  @override
  Future<int> add({required ExpenseSmallCategoryEntity entity}) async {
    final id = await db.insert(
      SqfExpenseSmallCategory.tableName,
      {
        SqfExpenseSmallCategory.bigCategoryKey: entity.bigCategoryKey,
        SqfExpenseSmallCategory.name: entity.smallCategoryName,
        SqfExpenseSmallCategory.smallCategoryOrderKey:
            entity.smallCategoryOrderKey,
        SqfExpenseSmallCategory.displayedOrderInBig: entity.displayedOrderInBig,
        SqfExpenseSmallCategory.defaultDisplayed: entity.defaultDisplayed,
      },
    );
    return id;
  }

  /// 小カテゴリーの最大の表示順序を取得する（全カテゴリー対象）
  @override
  Future<int> getMaxSmallCategoryOrderKey({required int bigCategoryId}) async {
    // bigCategoryIdは互換性のため引数として残すが、全カテゴリーから最大値を取得する
    const sql = '''
      SELECT MAX(${SqfExpenseSmallCategory.smallCategoryOrderKey}) AS maxOrderKey
      FROM ${SqfExpenseSmallCategory.tableName};
    ''';

    final jsonList = await db.query(sql);
    // logger.i('====SQLが実行されました====\n ImplementsExpenseSmallCategoryRepository getMaxSmallCategoryOrderKey(int bigCategoryId)\n$sql');

    if (jsonList.isNotEmpty && jsonList[0]['maxOrderKey'] != null) {
      return jsonList[0]['maxOrderKey'] as int;
    } else {
      return 0; // デフォルト値
    }
  }

  /// 大カテゴリーを指定して、それにふくまれる小カテゴリーのidを取得する
  @override
  Future<List<int>> fetchSmallCategoryIdListByBigCategoryId(
      {required int bigCategoryId}) async {
    final sql = '''
      SELECT ${SqfExpenseSmallCategory.id} as smallCategoryId
      FROM ${SqfExpenseSmallCategory.tableName}
      WHERE ${SqfExpenseSmallCategory.bigCategoryKey} = $bigCategoryId;
    ''';
    final jsonList = await db.query(sql);
    // logger.i('====SQLが実行されました====\n ImplementsExpenseSmallCategoryRepository fetchSmallCategoryIdListByBigCategoryId(int bigCategoryId)\n$sql');
    return jsonList.map((e) => e['smallCategoryId'] as int).toList();
  }
}
