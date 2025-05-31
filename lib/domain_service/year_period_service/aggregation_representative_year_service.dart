import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/domain/core/year_value/year_value.dart';
import 'package:kakeibo/domain/db/year_basis_entity/year_basis_entity.dart';
import 'package:kakeibo/domain_service/year_period_service/month_basis_provider.dart';
import 'package:kakeibo/domain_service/year_period_service/month_period_service.dart';

final aggregationRepresentativeYearServiceProvider = Provider<AggregationRepresentativeYearService>(
  (ref) => AggregationRepresentativeYearService(ref),
);


// 集計期間の代表月を取得するサービス
class AggregationRepresentativeYearService{

  AggregationRepresentativeYearService(this._ref);

  final Ref _ref;

  YearBasisService get _yearBasisService => _ref.read(yearBasisProvider);
  YearPeriodService get _yearPeriodService => _ref.read(yearPeriodServiceProvider);

  // 入力した集計期間の代表付きを取得する
  Future<YearValue> fetchYear(DateTime selectedDate) async{

    final period = await _yearPeriodService.fetchYearPeriod(selectedDate);

    // ユーザ設定の代表月設定を取得する
    YearBasisEntity aggregationStartMonthEntity = await _yearBasisService.fetch();
    
    // 設定が初日の場合
    if(aggregationStartMonthEntity.monthBasis == YearBasis.start){

      // 集計期間の開始日を取得し、日付を落とす
      final year = DateFormat('yyyy').format(period.startDatetime);
      
      return YearValue(year: year);

    }
    // 設定が初日の場合
    else if(aggregationStartMonthEntity.monthBasis == YearBasis.end){

      // 集計期間の最終日を取得し、日付を落とす
      final year = DateFormat('yyyy').format(period.endDatetime);
      
      return YearValue(year: year);

    }else{
      throw Exception('集計期間の代表年の取得に失敗しました');
    }
  }

  
}

