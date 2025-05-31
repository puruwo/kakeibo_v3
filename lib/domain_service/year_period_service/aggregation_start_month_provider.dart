import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/aggregation_start_month_entity/aggregation_start_month_entity.dart';
import 'package:kakeibo/domain/db/aggregation_start_month_entity/aggregation_start_month_repository.dart';

// ユーザ設定の基準日開始日を管理するprovider
final aggregationStartMonthProvider =
    Provider<AggregationStartMonthService>(AggregationStartMonthService.new);

class AggregationStartMonthService {
  AggregationStartMonthService(this._ref);

  final Ref _ref;
  AggregationStartMonthRepository get aggregationStartMonthRepository =>
      _ref.read(aggregationStartMonthRepositoryProvider);

  // ユーザ設定の集計開始日を取得する
  Future<AggregationStartMonthEntity> fetchAggregationStartMonth() async {
    AggregationStartMonthEntity aggregationStartMonthEntity =
        await aggregationStartMonthRepository.fetch();
    return aggregationStartMonthEntity;
  }
}