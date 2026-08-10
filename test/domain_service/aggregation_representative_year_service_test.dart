import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/year_value/year_value.dart';
import 'package:kakeibo/domain/db/year_basis_entity/year_basis_entity.dart';
import 'package:kakeibo/domain_service/year_period_service/aggregation_representative_year_service.dart';

import '../helper/test_container.dart';

void main() {
  group('AggregationRepresentativeYearService.fetchYear（開始月4月・開始日25日）', () {
    test('basis=startなら年度期間の開始年を返す（2026/4/25〜2027/4/24 → 2026）', () async {
      final container = createContainer(
        overrides: aggregationSettingOverrides(),
      );
      final service = container.read(
        aggregationRepresentativeYearServiceProvider,
      );

      final year = await service.fetchYear(DateTime(2026, 7, 6));

      expect(year, const YearValue(year: '2026'));
    });

    test('basis=endなら年度期間の終了年を返す（2026/4/25〜2027/4/24 → 2027）', () async {
      final container = createContainer(
        overrides: aggregationSettingOverrides(yearBasis: YearBasis.end),
      );
      final service = container.read(
        aggregationRepresentativeYearServiceProvider,
      );

      final year = await service.fetchYear(DateTime(2026, 7, 6));

      expect(year, const YearValue(year: '2027'));
    });

    test('基準日より前の日付は前年開始の年度になる（2026/3/1 → 2025）', () async {
      final container = createContainer(
        overrides: aggregationSettingOverrides(),
      );
      final service = container.read(
        aggregationRepresentativeYearServiceProvider,
      );

      final year = await service.fetchYear(DateTime(2026, 3, 1));

      expect(year, const YearValue(year: '2025'));
    });
  });
}
