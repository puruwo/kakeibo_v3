import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/domain/core/month_value/month_value.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/month_basis_entity/month_basis_entity.dart';
import 'package:kakeibo/domain_service/month_period_service/month_basis_provider.dart';
import 'package:kakeibo/domain_service/month_period_service/month_period_service.dart';

final aggregationRepresentativeMonthServiceProvider = Provider<AggregationRepresentativeMonthService>(
  (ref) => AggregationRepresentativeMonthService(ref),
);


// 集計期間の代表月を取得するサービス
class AggregationRepresentativeMonthService{

  AggregationRepresentativeMonthService(this._ref);

  final Ref _ref;

  MonthBasisService get _monthBasisService => _ref.read(monthBasisProvider);
  MonthPeriodService get _monthPeriodService => _ref.read(monthPeriodServiceProvider);

  // 入力した日付が含まれるの代表月を取得する
  Future<MonthValue> fetchMonth(DateTime selectedDate) async{

    // 指定した日付を含む集計期間を取得する
    PeriodValue period = await _monthPeriodService.fetchMonthPeriod(selectedDate);

    // ユーザ設定の代表月設定を取得する
    MonthBasisEntity aggregationStartDateEntity = await _monthBasisService.fetch();
    
    // 設定が初日の場合
    if(aggregationStartDateEntity.monthBasis == MonthBasis.start){

      // 集計期間の開始日を取得し、日付を落とす
      final month = DateFormat('yyyyMM').format(period.startDatetime);
      
      return MonthValue(month: month);

    }
    // 設定が初日の場合
    else if(aggregationStartDateEntity.monthBasis == MonthBasis.end){

      // 集計期間の最終日を取得し、日付を落とす
      final month = DateFormat('yyyyMM').format(period.endDatetime);
      
      return MonthValue(month: month);

    }else{
      throw Exception('集計期間の代表月の取得に失敗しました');
    }
  }

  
}

