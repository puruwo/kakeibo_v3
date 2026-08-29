import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';

/// 集計期間（月・年度）の区切り規則（純粋関数・正本）
///
/// 開始日・開始月から「ある日を含む集計期間」を求める規則をここに一本化する。
/// - [MonthPeriodService] / [YearPeriodService] は保存済み設定を Provider から読み、本クラスへ委譲する
/// - 集計期間設定ページは未保存の選択値を渡してプレビューする
///
/// 規則の境界値は `test/domain_service/aggregation_period_rule/aggregation_period_rule_test.dart`
/// で固定している。
class AggregationPeriodRule {
  AggregationPeriodRule._();

  /// [today] を含む月の集計期間
  ///
  /// - `today.day >= startDay` → 当月 startDay 〜 翌月 startDay-1
  /// - `today.day <  startDay` → 前月 startDay 〜 当月 startDay-1
  ///
  /// `DateTime(year, month, 0)` の正規化で月末を得るため、開始日1日は暦月になる。
  static PeriodValue monthPeriod({
    required DateTime today,
    required int startDay,
  }) {
    if (today.day < startDay) {
      return PeriodValue(
        startDatetime: DateTime(today.year, today.month - 1, startDay),
        endDatetime: DateTime(today.year, today.month, startDay - 1),
      );
    }
    return PeriodValue(
      startDatetime: DateTime(today.year, today.month, startDay),
      endDatetime: DateTime(today.year, today.month + 1, startDay - 1),
    );
  }

  /// [today] を含む年度の集計期間
  ///
  /// その年の基準日 = (today.year, startMonth, startDay) とし、
  /// today が基準日より前なら前年の基準日から、以降なら当年の基準日から1年間。
  static PeriodValue yearPeriod({
    required DateTime today,
    required int startDay,
    required int startMonth,
  }) {
    final basis = DateTime(today.year, startMonth, startDay);
    if (today.isBefore(basis)) {
      return PeriodValue(
        startDatetime: DateTime(today.year - 1, startMonth, startDay),
        endDatetime: DateTime(today.year, startMonth, startDay - 1),
      );
    }
    return PeriodValue(
      startDatetime: basis,
      endDatetime: DateTime(today.year + 1, startMonth, startDay - 1),
    );
  }
}
