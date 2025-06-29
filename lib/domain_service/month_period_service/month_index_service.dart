import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/core/month_value/month_value.dart';
import 'package:kakeibo/domain/db/aggregation_start_month_entity/aggregation_start_month_entity.dart';
import 'package:kakeibo/domain_service/month_period_service/aggregation_representative_month_service.dart';
import 'package:kakeibo/domain_service/year_period_service/aggregation_start_month_provider.dart';

final monthIndexServiceProvider = Provider<MonthIndexService>(
  (ref) => MonthIndexService(ref),
);


// 集計期間の代表月を取得するサービス
class MonthIndexService{

  MonthIndexService(this._ref);

  final Ref _ref;

  AggregationRepresentativeMonthService get _aRMService => _ref.read(aggregationRepresentativeMonthServiceProvider);
  AggregationStartMonthService get _aSMService => _ref.read(aggregationStartMonthProvider);

  // 入力した日付が含まれるの代表月を取得する
  Future<int> fetchMonthIndex(DateTime selectedDate) async{

    // 選択されている月から代表月を取得する
    MonthValue monthValue = await _aRMService.fetchMonth(selectedDate);
    final currentMonth = monthValue.monthNumber;

    // ユーザ設定の集計開始月を取得する
    AggregationStartMonthEntity aggregationStartMonth = await _aSMService.fetchAggregationStartMonth();
    final startMonthNumber = aggregationStartMonth.month;

    final index = (currentMonth - startMonthNumber) % 12;

    return index;
  }

  
}

