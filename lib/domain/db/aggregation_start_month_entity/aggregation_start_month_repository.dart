import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/aggregation_start_month_entity/aggregation_start_month_entity.dart';

/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final aggregationStartMonthRepositoryProvider = Provider<AggregationStartMonthRepository>(
  (_) => throw UnimplementedError("AggregationStartMonthRepositoryの実装がされていません。"),
);


abstract interface class AggregationStartMonthRepository {

  /// ユーザ設定を取得する
  Future<AggregationStartMonthEntity> fetch();
}
