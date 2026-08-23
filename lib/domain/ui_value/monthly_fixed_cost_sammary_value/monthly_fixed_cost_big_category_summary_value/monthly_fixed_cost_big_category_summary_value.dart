import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_fixed_cost_big_category_summary_value.freezed.dart';

/// カテゴリー別の固定費サマリー
@freezed
class MonthlyFixedCostBigCategorySummaryValue with _$MonthlyFixedCostBigCategorySummaryValue {
  const factory MonthlyFixedCostBigCategorySummaryValue({
    /// 支出大カテゴリーid（v10で固定費カテゴリーから移行）
    required int expenseBigCategoryId,
    required String categoryName,
    required String colorCode,
    required String resourcePath,
    /// 全て確定している場合はtrue
    required bool isAllConfirmed,
    /// カテゴリー内の確定済み固定費の合計
    required int totalAmount,
  }) = _MonthlyFixedCostBigCategorySummaryValue;
}
