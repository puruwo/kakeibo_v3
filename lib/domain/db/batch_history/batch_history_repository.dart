import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/batch_history/batch_history_entity.dart';

/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final batchHistoryRepositoryProvider = Provider<BatchHistoryRepository>(
  (_) => throw UnimplementedError("BatchHistoryRepositoryの実装がされていません。"),
);

/// サブスク・固定費に関するリポジトリ
abstract interface class BatchHistoryRepository {
  // / 全ての登録情報を取得する
  Future<List<BatchHistoryEntity>> fetchAll();

  Future<BatchHistoryEntity> fetch({required String startDate,required String endDate});

  /// 最新のバッチ処理実行済み期間の最終日を取得する
  Future<String> fetchLatestDate();

  Future<int> insert(BatchHistoryEntity entity);

  void update(BatchHistoryEntity entity);

  void delete(int id);
}
