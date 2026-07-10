import 'package:kakeibo/domain/db/aggregation_start_month_entity/aggregation_start_month_entity.dart';
import 'package:kakeibo/domain/db/aggregation_start_month_entity/aggregation_start_month_repository.dart';
import 'package:kakeibo/model/aggregation_settings_store.dart';

class ImplementsAggregationStartMonthRepository implements AggregationStartMonthRepository {

  @override
  Future<AggregationStartMonthEntity> fetch() async {
    // ユーザー設定の集計開始月を設定ストアから取得する（未設定時は既定値4月）
    final month = await AggregationSettingsStore().fetchStartMonth();
    return AggregationStartMonthEntity(month: month);
  }
}
