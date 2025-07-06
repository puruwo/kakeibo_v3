import 'package:kakeibo/domain/db/batch_history/batch_history_entity.dart';
import 'package:kakeibo/domain/db/batch_history/batch_history_repository.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/logger.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsBatchHistoryRepository implements BatchHistoryRepository {
  // 全ての固定費情報を取得する
  @override
  Future<List<BatchHistoryEntity>> fetchAll() async {
    const sql = '''
      SELECT 
        a.${SqfBatchHistory.id} AS id,
        a.${SqfBatchHistory.startDate} AS startDate, 
        a.${SqfBatchHistory.endDate} AS endDate,
        a.${SqfBatchHistory.status} AS status
      FROM ${SqfBatchHistory.tableName} a
      ORDER BY a.${SqfBatchHistory.id} ASC;
    ''';

    try {
      final jsonList = await db.query(sql);
      final results =
          jsonList.map((json) => BatchHistoryEntity.fromJson(json)).toList();

      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return [];
    }
  }

  // 固定費情報をID指定で取得する
  @override
  Future<BatchHistoryEntity> fetch(
      {required String startDate, required String endDate}) async {
    final sql = '''
      SELECT 
        a.${SqfBatchHistory.id} AS id,
        a.${SqfBatchHistory.startDate} AS startDate, 
        a.${SqfBatchHistory.endDate} AS endDate,
        a.${SqfBatchHistory.status} AS status
      FROM ${SqfBatchHistory.tableName} a
      WHERE a.${SqfBatchHistory.startDate} = $startDate AND a.${SqfBatchHistory.endDate} = $endDate
      ORDER BY a.${SqfBatchHistory.id} ASC;
    ''';

    try {
      final jsonList = await db.query(sql);
      final result = BatchHistoryEntity.fromJson(jsonList[0]);
      return result;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return const BatchHistoryEntity(
        id: 0,
        startDate: '',
        endDate: '',
        status: 0,
      );
    }
  }

  @override
  Future<String> fetchLatestDate() async {
    const sql = '''
      SELECT 
        a.${SqfBatchHistory.endDate} AS endDate
      FROM ${SqfBatchHistory.tableName} a
      ORDER BY a.${SqfBatchHistory.endDate} DESC
      LIMIT 1;
    ''';

    try {
      // トランザクションを利用して安全に処理する
      final jsonList = await db.query(sql);
      final result =
          jsonList.isNotEmpty ? jsonList[0]["endDate"] as String : '';
      return result;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return '';
    }
  }

  @override
  Future<int> insert(BatchHistoryEntity batchHistoryEntity) async {
    final id = db.insert(SqfBatchHistory.tableName, {
      SqfBatchHistory.startDate: batchHistoryEntity.startDate,
      SqfBatchHistory.endDate: batchHistoryEntity.endDate,
      SqfBatchHistory.status: batchHistoryEntity.status,
    });
    return id;
  }

  @override
  void update(BatchHistoryEntity batchHistoryEntity) {
    db.update(
        SqfBatchHistory.tableName,
        {
          SqfBatchHistory.id: batchHistoryEntity.id,
          SqfBatchHistory.startDate: batchHistoryEntity.startDate,
          SqfBatchHistory.endDate: batchHistoryEntity.endDate,
          SqfBatchHistory.status: batchHistoryEntity.status,
        },
        batchHistoryEntity.id!);
  }

  @override
  void delete(int id) async {
    await db.delete(SqfBatchHistory.tableName, id);
  }
}
