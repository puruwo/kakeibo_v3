// 集計期間設定ページのプレビュー計算のUT（KP-005 テストケース A群）
//
// A-1/A-2 は純粋関数の境界値、A-3 は既存の MonthPeriodService / YearPeriodService
// との一致（二重実装の回帰防止）を固定する。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain_service/aggregation_period_preview/aggregation_period_preview.dart';
import 'package:kakeibo/domain_service/month_period_service/month_period_service.dart';
import 'package:kakeibo/domain_service/year_period_service/month_period_service.dart';

import '../../helper/test_container.dart';

/// 月の期間ケース（A-1）
class _MonthCase {
  const _MonthCase(this.name, this.today, this.startDay, this.start, this.end);
  final String name;
  final DateTime today;
  final int startDay;
  final DateTime start;
  final DateTime end;
}

/// 年度の期間ケース（A-2）
class _YearCase {
  const _YearCase(
    this.name,
    this.today,
    this.startDay,
    this.startMonth,
    this.start,
    this.end,
  );
  final String name;
  final DateTime today;
  final int startDay;
  final int startMonth;
  final DateTime start;
  final DateTime end;
}

void main() {
  final monthCases = [
    _MonthCase(
      '開始日以降（基本）',
      DateTime(2026, 8, 29),
      25,
      DateTime(2026, 8, 25),
      DateTime(2026, 9, 24),
    ),
    _MonthCase(
      '開始日より前',
      DateTime(2026, 8, 10),
      25,
      DateTime(2026, 7, 25),
      DateTime(2026, 8, 24),
    ),
    _MonthCase(
      '境界: today == 開始日',
      DateTime(2026, 8, 25),
      25,
      DateTime(2026, 8, 25),
      DateTime(2026, 9, 24),
    ),
    _MonthCase(
      '境界: today == 開始日−1',
      DateTime(2026, 8, 24),
      25,
      DateTime(2026, 7, 25),
      DateTime(2026, 8, 24),
    ),
    _MonthCase(
      '開始日1（暦月）はendが月末',
      DateTime(2026, 8, 15),
      1,
      DateTime(2026, 8, 1),
      DateTime(2026, 8, 31),
    ),
    _MonthCase(
      '暦月・2月（平年）',
      DateTime(2026, 2, 15),
      1,
      DateTime(2026, 2, 1),
      DateTime(2026, 2, 28),
    ),
    _MonthCase(
      '暦月・2月（閏年）',
      DateTime(2028, 2, 15),
      1,
      DateTime(2028, 2, 1),
      DateTime(2028, 2, 29),
    ),
    _MonthCase(
      '年跨ぎ（前年へ）',
      DateTime(2026, 1, 10),
      25,
      DateTime(2025, 12, 25),
      DateTime(2026, 1, 24),
    ),
    _MonthCase(
      '年跨ぎ（翌年へ）',
      DateTime(2026, 12, 28),
      25,
      DateTime(2026, 12, 25),
      DateTime(2027, 1, 24),
    ),
    _MonthCase(
      '開始日28・2月',
      DateTime(2026, 3, 1),
      28,
      DateTime(2026, 2, 28),
      DateTime(2026, 3, 27),
    ),
    _MonthCase(
      '上限28',
      DateTime(2026, 8, 29),
      28,
      DateTime(2026, 8, 28),
      DateTime(2026, 9, 27),
    ),
  ];

  final yearCases = [
    _YearCase(
      '基準日以降（基本）',
      DateTime(2026, 8, 29),
      25,
      4,
      DateTime(2026, 4, 25),
      DateTime(2027, 4, 24),
    ),
    _YearCase(
      '基準日より前（前年度）',
      DateTime(2026, 3, 10),
      25,
      4,
      DateTime(2025, 4, 25),
      DateTime(2026, 4, 24),
    ),
    _YearCase(
      '境界: today == 基準日',
      DateTime(2026, 4, 25),
      25,
      4,
      DateTime(2026, 4, 25),
      DateTime(2027, 4, 24),
    ),
    _YearCase(
      '境界: today == 基準日−1',
      DateTime(2026, 4, 24),
      25,
      4,
      DateTime(2025, 4, 25),
      DateTime(2026, 4, 24),
    ),
    _YearCase(
      '暦年',
      DateTime(2026, 8, 29),
      1,
      1,
      DateTime(2026, 1, 1),
      DateTime(2026, 12, 31),
    ),
    _YearCase(
      '開始月12・年跨ぎ',
      DateTime(2026, 8, 29),
      1,
      12,
      DateTime(2025, 12, 1),
      DateTime(2026, 11, 30),
    ),
    _YearCase(
      '開始月12・基準日以降',
      DateTime(2026, 12, 15),
      1,
      12,
      DateTime(2026, 12, 1),
      DateTime(2027, 11, 30),
    ),
    _YearCase(
      '開始日28・開始月2',
      DateTime(2026, 8, 29),
      28,
      2,
      DateTime(2026, 2, 28),
      DateTime(2027, 2, 27),
    ),
    _YearCase(
      '閏年の2/28が基準日',
      DateTime(2028, 2, 28),
      28,
      2,
      DateTime(2028, 2, 28),
      DateTime(2029, 2, 27),
    ),
  ];

  group('AggregationPeriodPreview.monthPeriod', () {
    for (final c in monthCases) {
      test('${c.name}: ${c.today.month}/${c.today.day}・開始日${c.startDay}', () {
        final period = AggregationPeriodPreview.monthPeriod(
          today: c.today,
          startDay: c.startDay,
        );
        expect(period, PeriodValue(startDatetime: c.start, endDatetime: c.end));
      });
    }
  });

  group('AggregationPeriodPreview.yearPeriod', () {
    for (final c in yearCases) {
      test('${c.name}: ${c.today.year}/${c.today.month}/${c.today.day}・'
          '開始日${c.startDay}・開始月${c.startMonth}', () {
        final period = AggregationPeriodPreview.yearPeriod(
          today: c.today,
          startDay: c.startDay,
          startMonth: c.startMonth,
        );
        expect(period, PeriodValue(startDatetime: c.start, endDatetime: c.end));
      });
    }
  });

  group('既存サービスとの一致（回帰）', () {
    test('monthPeriod は同じ開始日を注入した MonthPeriodService と全ケース一致する', () async {
      for (final c in monthCases) {
        final container = createContainer(
          overrides: aggregationSettingOverrides(startDay: c.startDay),
        );
        final expected = await container
            .read(monthPeriodServiceProvider)
            .fetchMonthPeriod(c.today);

        final actual = AggregationPeriodPreview.monthPeriod(
          today: c.today,
          startDay: c.startDay,
        );
        expect(actual, expected, reason: c.name);
      }
    });

    test('yearPeriod は同じ設定を注入した YearPeriodService と全ケース一致する', () async {
      for (final c in yearCases) {
        final container = createContainer(
          overrides: aggregationSettingOverrides(
            startDay: c.startDay,
            startMonth: c.startMonth,
          ),
        );
        final expected = await container
            .read(yearPeriodServiceProvider)
            .fetchYearPeriod(c.today);

        final actual = AggregationPeriodPreview.yearPeriod(
          today: c.today,
          startDay: c.startDay,
          startMonth: c.startMonth,
        );
        expect(actual, expected, reason: c.name);
      }
    });
  });
}
