import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'aggregation_start_day_entity.dart';

/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final aggregationStartDayRepositoryProvider = Provider<AggregationStartDayRepository>(
  (_) => throw UnimplementedError("AggregationStartDayRepositoryの実装がされていません。"),
);


abstract interface class AggregationStartDayRepository {

  /// ユーザ設定を取得する
  Future<AggregationStartDayEntity> fetch();
}
