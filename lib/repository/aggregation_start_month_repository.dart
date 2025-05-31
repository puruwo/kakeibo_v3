import 'package:kakeibo/domain/db/aggregation_start_month_entity/aggregation_start_month_entity.dart';
import 'package:kakeibo/domain/db/aggregation_start_month_entity/aggregation_start_month_repository.dart';
import 'package:kakeibo/model/database_helper.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsAggregationStartMonthRepository implements AggregationStartMonthRepository {

  @override
  Future<AggregationStartMonthEntity> fetch() async {

    return const AggregationStartMonthEntity(month: 4);
  }
}