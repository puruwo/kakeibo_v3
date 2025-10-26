import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_fixed_cost_category_summary_value.freezed.dart';

/// カテゴリー別の固定費サマリー
@freezed
class MonthlyFixedCostCategorySummaryValue with _$MonthlyFixedCostCategorySummaryValue {
  const factory MonthlyFixedCostCategorySummaryValue({
    required int fixedCostCategoryId,
    required String categoryName,
    required String colorCode,
    required String resourcePath,
    /// 全て確定している場合はtrue
    required bool isAllConfirmed,
    /// カテゴリー内の確定済み固定費の合計
    required int totalAmount,
  }) = _MonthlyFixedCostCategorySummaryValue;
}
