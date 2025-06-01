import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/logger.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsIncomeSmallCategoryRepository implements IncomeSmallCategoryRepository {
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

      // logger.i('====SQLが実行されました====\n ImplementsIncomeSmallCategoryRepository fetchBySmallCategory(int smallCategoryId)\n$sql');
      
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
      FROM ${SqfIncomeSmallCategory.tableName} a;
    ''';

    // SQLを実行して結果を取得
    final jsonList = await db.query(sql);
    // logger.i('====SQLが実行されました====\n ImplementsSmallCategoryRepository fetchAll()\n$sql');

    // 取得したjsonListをSmallCategoryEntityのリストに変換
    final result = jsonList.map((e) {
      return IncomeSmallCategoryEntity.fromJson(e);
    }).toList();

    return result;
  }

  @override
  Future<List<IncomeSmallCategoryEntity>> fetchByBigCategory(
      {required int bigCategoryId}) {
    // TODO: implement fetchByBigCategory
    throw UnimplementedError();
  }
}
