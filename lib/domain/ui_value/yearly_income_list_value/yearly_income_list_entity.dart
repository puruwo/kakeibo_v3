import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/ui_value/income_history_tile_value/income_history_tile_value.dart';
import 'package:kakeibo/domain/ui_value/yearly_income_list_value/income_category_summary_value.dart';

//Freezedで生成されるデータクラス
part 'yearly_income_list_entity.freezed.dart';

// 年間収入一覧のエンティティ
@freezed
class YearlyIncomeListValue with _$YearlyIncomeListValue {
  const factory YearlyIncomeListValue({
    required List<MonthlyIncomeGroup> monthlyGroups,
    required int totalIncome,
    required List<IncomeCategorySummaryValue> categorySummaries,
  }) = _YearlyIncomeListValue;
}

// 月ごとの収入グループ
@freezed
class MonthlyIncomeGroup with _$MonthlyIncomeGroup {
  const factory MonthlyIncomeGroup({
    required String monthLabel, // 例: "2023年 12月"
    required List<IncomeHistoryTileValue> incomes,
  }) = _MonthlyIncomeGroup;
}
