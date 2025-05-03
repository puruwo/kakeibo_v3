import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/providerLogger.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsSmallCategoryRepository implements ExpenseSmallCategoryRepository {
  // カテゴリーNumberを指定して取得する
  @override
  Future<ExpenseSmallCategoryEntity> fetchBySmallCategory(
      {required int smallCategoryId}) async {
    final sql = '''
      SELECT 
        a.${TBL201RecordKey().id} AS id,
        a.${TBL201RecordKey().smallCategoryOrderKey} AS smallCategoryOrderKey,
        a.${TBL201RecordKey().bigCategoryKey} AS bigCategoryKey,
        a.${TBL201RecordKey().displayedOrderInBig} AS displayedOrderInBig,
        a.${TBL201RecordKey().categoryName} AS smallCategoryName,
        a.${TBL201RecordKey().defaultDisplayed} AS defaultDisplayed
      FROM ${TBL201RecordKey().tableName} a
      where a.${TBL201RecordKey().id} = $smallCategoryId;
    ''';

    try {
      final jsonList = await db.query(sql);

      logger.i('====SQLが実行されました====\n ImplementsSmallCategoryRepository fetchBySmallCategory(int smallCategoryId)\n$sql');
      
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
    final sql = '''
      SELECT 
        a.${TBL201RecordKey().id} AS id,
        a.${TBL201RecordKey().smallCategoryOrderKey} AS smallCategoryOrderKey,
        a.${TBL201RecordKey().bigCategoryKey} AS bigCategoryKey,
        a.${TBL201RecordKey().displayedOrderInBig} AS displayedOrderInBig,
        a.${TBL201RecordKey().categoryName} AS smallCategoryName,
        a.${TBL201RecordKey().defaultDisplayed} AS defaultDisplayed
      FROM ${TBL201RecordKey().tableName} a;
    ''';

    // SQLを実行して結果を取得
    final jsonList = await db.query(sql);
    logger.i('====SQLが実行されました====\n ImplementsSmallCategoryRepository fetchAll()\n$sql');

    // 取得したjsonListをSmallCategoryEntityのリストに変換
    final result = jsonList.map((e) {
      return ExpenseSmallCategoryEntity.fromJson(e);
    }).toList();

    return result;
  }

  @override
  Future<List<ExpenseSmallCategoryEntity>> fetchByBigCategory(
      {required int bigCategoryId}) {
    // TODO: implement fetchByBigCategory
    throw UnimplementedError();
  }
}
