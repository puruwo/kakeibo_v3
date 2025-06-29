import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/ui_value/annual_balance_chart_value/monthly_balance_value/monthly_balance_value.dart';

//Freezedで生成されるデータクラス
part 'annual_balance_chart_value.freezed.dart';

// 年間収支グラフのエンティティ
@freezed
class AnnualBalanceChartValue with _$AnnualBalanceChartValue {
  const factory AnnualBalanceChartValue({
    required int monthIndex, // 現在の月のインデックス
    required int currentMonth, // 現在の月
    required List<MonthlyBalanceValue> monthlyBalanceValues,
    required bool hasNoRecord, // 未来の月のみの収支かどうか
  }) = _AnnualBalanceChartValue;
}