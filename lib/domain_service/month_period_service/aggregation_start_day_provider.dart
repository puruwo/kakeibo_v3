import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/aggregation_start_day_entity/aggregation_start_day_entity.dart';
import 'package:kakeibo/domain/db/aggregation_start_day_entity/aggregation_start_day_repository.dart';

// ユーザ設定の基準日開始日を管理するprovider
final aggregationStartDayProvider =
    Provider<AggregationStartDayService>(AggregationStartDayService.new);

class AggregationStartDayService {
  AggregationStartDayService(this._ref);

  final Ref _ref;
  AggregationStartDayRepository get aggregationStartDateRepository =>
      _ref.read(aggregationStartDayRepositoryProvider);

  // ユーザ設定の集計開始日を取得する
  Future<AggregationStartDayEntity> fetchAggregationStartDay() async {
    AggregationStartDayEntity aggregationStartDateEntity =
        await aggregationStartDateRepository.fetch();
    return aggregationStartDateEntity;
  }
}
