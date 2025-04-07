import 'package:kakeibo/domain/aggregation_start_day_entity/aggregation_start_day_entity.dart';
import 'package:kakeibo/domain/aggregation_start_day_entity/aggregation_start_day_repository.dart';
import 'package:kakeibo/model/database_helper.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsAggregationStartDayRepository implements AggregationStartDayRepository {

  @override
  Future<AggregationStartDayEntity> fetch() async {

    return const AggregationStartDayEntity(day: 25);
  }
}