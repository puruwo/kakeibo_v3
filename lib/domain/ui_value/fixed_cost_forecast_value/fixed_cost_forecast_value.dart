import 'package:freezed_annotation/freezed_annotation.dart';

part 'fixed_cost_forecast_value.freezed.dart';

/// 固定費見込みの算出結果（仕様 §7.3）
///
/// 予算設定画面で「固定費見込み ◯◯円」を大カテゴリー別に併記するために使う。
@freezed
class FixedCostForecastValue with _$FixedCostForecastValue {
  const FixedCostForecastValue._();

  const factory FixedCostForecastValue({
    /// 大カテゴリー別の見込み（見込み0円のカテゴリーは含まない）
    required List<FixedCostForecastByCategory> byBigCategory,

    /// 対象期間の見込み合計
    required int total,
  }) = _FixedCostForecastValue;

  /// 大カテゴリーidを指定して見込み額を引く（該当なしは0）
  int amountOf(int expenseBigCategoryId) {
    for (final e in byBigCategory) {
      if (e.expenseBigCategoryId == expenseBigCategoryId) return e.amount;
    }
    return 0;
  }
}

/// 大カテゴリー単位の固定費見込み
@freezed
class FixedCostForecastByCategory with _$FixedCostForecastByCategory {
  const factory FixedCostForecastByCategory({
    required int expenseBigCategoryId,
    required String bigCategoryName,
    required int amount,
  }) = _FixedCostForecastByCategory;
}
