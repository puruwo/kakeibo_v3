import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/month_value/month_value.dart';
import 'package:kakeibo/domain_service/month_period_service/period_status_service.dart';

import '../helper/test_container.dart';

void main() {
  group('PeriodStatusService.comparePeriodStatus', () {
    // comparePeriodStatusは依存を読まない純粋計算のため、overridesなしでよい
    PeriodStatusService createService() =>
        createContainer().read(periodStatusServiceProvider);

    test('選択月がシステム月より前ならpast', () {
      final service = createService();
      expect(
        service.comparePeriodStatus(
          const MonthValue(month: '202506'),
          const MonthValue(month: '202507'),
        ),
        PeriodStatus.past,
      );
    });

    test('選択月とシステム月が同じならcurrent', () {
      final service = createService();
      expect(
        service.comparePeriodStatus(
          const MonthValue(month: '202507'),
          const MonthValue(month: '202507'),
        ),
        PeriodStatus.current,
      );
    });

    test('選択月がシステム月より後ならfuture', () {
      final service = createService();
      expect(
        service.comparePeriodStatus(
          const MonthValue(month: '202508'),
          const MonthValue(month: '202507'),
        ),
        PeriodStatus.future,
      );
    });

    test('年をまたいだ過去判定（202412 vs 202501）', () {
      final service = createService();
      expect(
        service.comparePeriodStatus(
          const MonthValue(month: '202412'),
          const MonthValue(month: '202501'),
        ),
        PeriodStatus.past,
      );
    });
  });

  group('PeriodStatusService.fetchPeriodStatus（システム日時2025/7/6固定・開始日25日）', () {
    // システム日時2025/7/6 → 集計期間6/25〜7/24 → システム代表月202506
    PeriodStatusService createService() {
      final container = createContainer(
        overrides: aggregationSettingOverrides(
          systemDate: DateTime(2025, 7, 6),
        ),
      );
      return container.read(periodStatusServiceProvider);
    }

    test('前の集計期間の日付はpast', () async {
      final service = createService();
      // 2025/6/10 → 期間5/25〜6/24 → 代表月202505
      expect(
        await service.fetchPeriodStatus(DateTime(2025, 6, 10)),
        PeriodStatus.past,
      );
    });

    test('同じ集計期間内の日付はcurrent', () async {
      final service = createService();
      // 2025/7/10 → 期間6/25〜7/24 → 代表月202506（システムと同じ）
      expect(
        await service.fetchPeriodStatus(DateTime(2025, 7, 10)),
        PeriodStatus.current,
      );
    });

    test('期間終了日ぴったり（7/24）はcurrent', () async {
      final service = createService();
      expect(
        await service.fetchPeriodStatus(DateTime(2025, 7, 24)),
        PeriodStatus.current,
      );
    });

    test('次の集計期間の開始日（7/25）はfuture', () async {
      final service = createService();
      // 2025/7/25 → 期間7/25〜8/24 → 代表月202507
      expect(
        await service.fetchPeriodStatus(DateTime(2025, 7, 25)),
        PeriodStatus.future,
      );
    });
  });
}
