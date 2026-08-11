import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain_service/month_period_service/month_period_service.dart';

import '../helper/test_container.dart';

void main() {
  group('MonthPeriodService.fetchMonthPeriod（集計開始日25日）', () {
    test('開始日より前の日付は前月25日〜当月24日の期間になる', () async {
      final container = createContainer(
        overrides: aggregationSettingOverrides(),
      );
      final service = container.read(monthPeriodServiceProvider);

      final period = await service.fetchMonthPeriod(DateTime(2025, 7, 6));

      expect(
        period,
        PeriodValue(
          startDatetime: DateTime(2025, 6, 25),
          endDatetime: DateTime(2025, 7, 24),
        ),
      );
    });

    test('開始日当日は当月25日〜翌月24日の期間になる', () async {
      final container = createContainer(
        overrides: aggregationSettingOverrides(),
      );
      final service = container.read(monthPeriodServiceProvider);

      final period = await service.fetchMonthPeriod(DateTime(2025, 7, 25));

      expect(
        period,
        PeriodValue(
          startDatetime: DateTime(2025, 7, 25),
          endDatetime: DateTime(2025, 8, 24),
        ),
      );
    });

    test('期間終了日（24日）は前月開始の期間に含まれる', () async {
      final container = createContainer(
        overrides: aggregationSettingOverrides(),
      );
      final service = container.read(monthPeriodServiceProvider);

      final period = await service.fetchMonthPeriod(DateTime(2025, 7, 24));

      expect(
        period,
        PeriodValue(
          startDatetime: DateTime(2025, 6, 25),
          endDatetime: DateTime(2025, 7, 24),
        ),
      );
    });

    test('1月前半は前年12月開始の期間になる（年跨ぎ）', () async {
      final container = createContainer(
        overrides: aggregationSettingOverrides(),
      );
      final service = container.read(monthPeriodServiceProvider);

      final period = await service.fetchMonthPeriod(DateTime(2025, 1, 10));

      expect(
        period,
        PeriodValue(
          startDatetime: DateTime(2024, 12, 25),
          endDatetime: DateTime(2025, 1, 24),
        ),
      );
    });

    test('12月25日以降は翌年1月24日までの期間になる（年跨ぎ）', () async {
      final container = createContainer(
        overrides: aggregationSettingOverrides(),
      );
      final service = container.read(monthPeriodServiceProvider);

      final period = await service.fetchMonthPeriod(DateTime(2025, 12, 25));

      expect(
        period,
        PeriodValue(
          startDatetime: DateTime(2025, 12, 25),
          endDatetime: DateTime(2026, 1, 24),
        ),
      );
    });
  });

  group('MonthPeriodService.fetchMonthPeriod（集計開始日1日）', () {
    test('開始日1日なら暦月そのままの期間になる', () async {
      final container = createContainer(
        overrides: aggregationSettingOverrides(startDay: 1),
      );
      final service = container.read(monthPeriodServiceProvider);

      final period = await service.fetchMonthPeriod(DateTime(2025, 7, 6));

      expect(
        period,
        PeriodValue(
          startDatetime: DateTime(2025, 7, 1),
          endDatetime: DateTime(2025, 7, 31),
        ),
      );
    });

    test('開始日1日の2月は28日までになる（平年）', () async {
      final container = createContainer(
        overrides: aggregationSettingOverrides(startDay: 1),
      );
      final service = container.read(monthPeriodServiceProvider);

      final period = await service.fetchMonthPeriod(DateTime(2025, 2, 15));

      expect(
        period,
        PeriodValue(
          startDatetime: DateTime(2025, 2, 1),
          endDatetime: DateTime(2025, 2, 28),
        ),
      );
    });
  });

  group('MonthPeriodService.fetchShiftedMonthPeriod', () {
    // fetchShiftedMonthPeriodは設定リポジトリに依存しない純粋計算のため、
    // overridesなしのコンテナで実行する
    MonthPeriodService createService() =>
        createContainer().read(monthPeriodServiceProvider);

    PeriodValue period(DateTime start, DateTime end) =>
        PeriodValue(startDatetime: start, endDatetime: end);

    test('shift=0はそのまま返す', () {
      final service = createService();
      final base = period(DateTime(2025, 6, 25), DateTime(2025, 7, 24));

      expect(service.fetchShiftedMonthPeriod(base, 0), base);
    });

    test('+1で翌月の期間になる', () {
      final service = createService();
      final base = period(DateTime(2025, 6, 25), DateTime(2025, 7, 24));

      expect(
        service.fetchShiftedMonthPeriod(base, 1),
        period(DateTime(2025, 7, 25), DateTime(2025, 8, 24)),
      );
    });

    test('+2で2ヶ月先の期間になる', () {
      final service = createService();
      final base = period(DateTime(2025, 6, 25), DateTime(2025, 7, 24));

      expect(
        service.fetchShiftedMonthPeriod(base, 2),
        period(DateTime(2025, 8, 25), DateTime(2025, 9, 24)),
      );
    });

    test('-1で前月の期間になる', () {
      final service = createService();
      final base = period(DateTime(2025, 3, 25), DateTime(2025, 4, 24));

      expect(
        service.fetchShiftedMonthPeriod(base, -1),
        period(DateTime(2025, 2, 25), DateTime(2025, 3, 24)),
      );
    });

    test('-1で年をまたいで戻る（1月開始 → 前年12月開始）', () {
      final service = createService();
      final base = period(DateTime(2025, 1, 1), DateTime(2025, 1, 31));

      expect(
        service.fetchShiftedMonthPeriod(base, -1),
        period(DateTime(2024, 12, 1), DateTime(2024, 12, 31)),
      );
    });

    test('暦月期間（1日開始）の-1シフトは前の暦月になる', () {
      final service = createService();
      final base = period(DateTime(2025, 3, 1), DateTime(2025, 3, 31));

      expect(
        service.fetchShiftedMonthPeriod(base, -1),
        period(DateTime(2025, 2, 1), DateTime(2025, 2, 28)),
      );
    });

    test('開始日28日の期間の-1シフト（2/28〜3/27 → 1/28〜2/27）', () {
      final service = createService();
      final base = period(DateTime(2025, 2, 28), DateTime(2025, 3, 27));

      expect(
        service.fetchShiftedMonthPeriod(base, -1),
        period(DateTime(2025, 1, 28), DateTime(2025, 2, 27)),
      );
    });

    test('+1で年をまたぐ（12/25開始 → 翌年1/25開始）', () {
      final service = createService();
      final base = period(DateTime(2025, 12, 25), DateTime(2026, 1, 24));

      expect(
        service.fetchShiftedMonthPeriod(base, 1),
        period(DateTime(2026, 1, 25), DateTime(2026, 2, 24)),
      );
    });

    test('暦月期間の+1シフトは翌暦月になる（1/1〜1/31 → 2/1〜2/28）', () {
      final service = createService();
      final base = period(DateTime(2025, 1, 1), DateTime(2025, 1, 31));

      expect(
        service.fetchShiftedMonthPeriod(base, 1),
        period(DateTime(2025, 2, 1), DateTime(2025, 2, 28)),
      );
    });

    test('暦月期間の+1シフトで31日ある月へ移ると末日まで含む（2/1〜2/28 → 3/1〜3/31）', () {
      final service = createService();
      final base = period(DateTime(2025, 2, 1), DateTime(2025, 2, 28));

      expect(
        service.fetchShiftedMonthPeriod(base, 1),
        period(DateTime(2025, 3, 1), DateTime(2025, 3, 31)),
      );
    });

    test('暦月期間の-1シフトで31日ある月へ戻ると末日まで含む（2/1〜2/28 → 1/1〜1/31）', () {
      final service = createService();
      final base = period(DateTime(2025, 2, 1), DateTime(2025, 2, 28));

      expect(
        service.fetchShiftedMonthPeriod(base, -1),
        period(DateTime(2025, 1, 1), DateTime(2025, 1, 31)),
      );
    });

    test('閏年の2月への暦月シフトは29日まで含む（2024/1/1〜1/31 → 2024/2/1〜2/29）', () {
      final service = createService();
      final base = period(DateTime(2024, 1, 1), DateTime(2024, 1, 31));

      expect(
        service.fetchShiftedMonthPeriod(base, 1),
        period(DateTime(2024, 2, 1), DateTime(2024, 2, 29)),
      );
    });
  });
}
