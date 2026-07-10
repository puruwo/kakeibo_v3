import 'package:kakeibo/domain/db/aggregation_start_day_entity/aggregation_start_day_entity.dart';
import 'package:kakeibo/domain/db/aggregation_start_day_entity/aggregation_start_day_repository.dart';
import 'package:kakeibo/model/aggregation_settings_store.dart';

class ImplementsAggregationStartDayRepository implements AggregationStartDayRepository {

  @override
  Future<AggregationStartDayEntity> fetch() async {
    // ユーザー設定の集計開始日を設定ストアから取得する（未設定時は既定値25日）
    final day = await AggregationSettingsStore().fetchStartDay();
    return AggregationStartDayEntity(day: day);
  }
}
