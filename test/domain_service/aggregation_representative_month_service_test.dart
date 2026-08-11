import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/month_value/month_value.dart';
import 'package:kakeibo/domain/db/month_basis_entity/month_basis_entity.dart';
import 'package:kakeibo/domain_service/month_period_service/aggregation_representative_month_service.dart';

import '../helper/test_container.dart';

void main() {
  group('AggregationRepresentativeMonthService.fetchMonth（開始日25日）', () {
    test('basis=startなら期間の開始日側の月を返す（6/25〜7/24 → 202506）', () async {
      final container = createContainer(
        overrides: aggregationSettingOverrides(),
      );
      final service = container.read(
        aggregationRepresentativeMonthServiceProvider,
      );

      final month = await service.fetchMonth(DateTime(2025, 7, 6));

      expect(month, const MonthValue(month: '202506'));
    });

    test('basis=endなら期間の終了日側の月を返す（6/25〜7/24 → 202507）', () async {
      final container = createContainer(
        overrides: aggregationSettingOverrides(monthBasis: MonthBasis.end),
      );
      final service = container.read(
        aggregationRepresentativeMonthServiceProvider,
      );

      final month = await service.fetchMonth(DateTime(2025, 7, 6));

      expect(month, const MonthValue(month: '202507'));
    });

    test('年跨ぎ期間のbasis=startは前年12月を返す（12/25〜1/24 → 202412）', () async {
      final container = createContainer(
        overrides: aggregationSettingOverrides(),
      );
      final service = container.read(
        aggregationRepresentativeMonthServiceProvider,
      );

      final month = await service.fetchMonth(DateTime(2025, 1, 10));

      expect(month, const MonthValue(month: '202412'));
    });

    test('年跨ぎ期間のbasis=endは当年1月を返す（12/25〜1/24 → 202501）', () async {
      final container = createContainer(
        overrides: aggregationSettingOverrides(monthBasis: MonthBasis.end),
      );
      final service = container.read(
        aggregationRepresentativeMonthServiceProvider,
      );

      final month = await service.fetchMonth(DateTime(2025, 1, 10));

      expect(month, const MonthValue(month: '202501'));
    });

    test('開始日25日以降の日付は当月が代表月になる（7/25 → 202507）', () async {
      final container = createContainer(
        overrides: aggregationSettingOverrides(),
      );
      final service = container.read(
        aggregationRepresentativeMonthServiceProvider,
      );

      final month = await service.fetchMonth(DateTime(2025, 7, 25));

      expect(month, const MonthValue(month: '202507'));
    });
  });

  group('MonthValueExtension', () {
    test('year/monthNumberはyyyyMM文字列から数値を取り出す', () {
      const value = MonthValue(month: '202506');

      expect(value.year, 2025);
      expect(value.monthNumber, 6);
    });

    test('beforMonthは前の月を返す', () {
      expect(
        const MonthValue(month: '202506').beforMonth,
        const MonthValue(month: '202505'),
      );
    });

    test('beforMonthは1月から前年12月に戻る', () {
      expect(
        const MonthValue(month: '202501').beforMonth,
        const MonthValue(month: '202412'),
      );
    });
  });
}
