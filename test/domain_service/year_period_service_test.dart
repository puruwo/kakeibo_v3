import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain_service/year_period_service/month_period_service.dart';

import '../helper/test_container.dart';

void main() {
  group('YearPeriodService.fetchYearPeriod（開始月4月・開始日25日）', () {
    test('基準日以降の日付は当年4/25〜翌年4/24の期間になる', () async {
      final container = createContainer(
        overrides: aggregationSettingOverrides(),
      );
      final service = container.read(yearPeriodServiceProvider);

      final period = await service.fetchYearPeriod(DateTime(2025, 7, 6));

      expect(
        period,
        PeriodValue(
          startDatetime: DateTime(2025, 4, 25),
          endDatetime: DateTime(2026, 4, 24),
        ),
      );
    });

    test('基準日より前の日付は前年4/25〜当年4/24の期間になる', () async {
      final container = createContainer(
        overrides: aggregationSettingOverrides(),
      );
      final service = container.read(yearPeriodServiceProvider);

      final period = await service.fetchYearPeriod(DateTime(2025, 3, 1));

      expect(
        period,
        PeriodValue(
          startDatetime: DateTime(2024, 4, 25),
          endDatetime: DateTime(2025, 4, 24),
        ),
      );
    });

    test('基準日当日（4/25）は当年開始の期間に含まれる', () async {
      final container = createContainer(
        overrides: aggregationSettingOverrides(),
      );
      final service = container.read(yearPeriodServiceProvider);

      final period = await service.fetchYearPeriod(DateTime(2025, 4, 25));

      expect(
        period,
        PeriodValue(
          startDatetime: DateTime(2025, 4, 25),
          endDatetime: DateTime(2026, 4, 24),
        ),
      );
    });

    test('基準日前日（4/24）は前年開始の期間に含まれる', () async {
      final container = createContainer(
        overrides: aggregationSettingOverrides(),
      );
      final service = container.read(yearPeriodServiceProvider);

      final period = await service.fetchYearPeriod(DateTime(2025, 4, 24));

      expect(
        period,
        PeriodValue(
          startDatetime: DateTime(2024, 4, 25),
          endDatetime: DateTime(2025, 4, 24),
        ),
      );
    });
  });

  group('YearPeriodService.fetchYearPeriod（設定変更時）', () {
    test('開始月1月・開始日1日なら暦年そのままの期間になる', () async {
      final container = createContainer(
        overrides: aggregationSettingOverrides(startDay: 1, startMonth: 1),
      );
      final service = container.read(yearPeriodServiceProvider);

      final period = await service.fetchYearPeriod(DateTime(2025, 6, 1));

      expect(
        period,
        PeriodValue(
          startDatetime: DateTime(2025, 1, 1),
          endDatetime: DateTime(2025, 12, 31),
        ),
      );
    });
  });
}
