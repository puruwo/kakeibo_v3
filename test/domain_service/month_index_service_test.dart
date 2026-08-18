import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain_service/month_period_service/month_index_service.dart';

import '../helper/test_container.dart';

void main() {
  group('MonthIndexService.fetchMonthIndex（開始月4月・開始日25日・basis=start）', () {
    Future<int> fetchIndex(DateTime selectedDate) async {
      final container = createContainer(
        overrides: aggregationSettingOverrides(),
      );
      final service = container.read(monthIndexServiceProvider);
      return service.fetchMonthIndex(selectedDate);
    }

    test('年度最初の月（代表月4月）はindex 0', () async {
      // 2025/5/1 → 集計期間4/25〜5/24 → 代表月202504
      expect(await fetchIndex(DateTime(2025, 5, 1)), 0);
    });

    test('年度2番目の月（代表月5月）はindex 1', () async {
      // 2025/6/1 → 集計期間5/25〜6/24 → 代表月202505
      expect(await fetchIndex(DateTime(2025, 6, 1)), 1);
    });

    test('年末の月（代表月12月）はindex 8', () async {
      // 2026/1/10 → 集計期間12/25〜1/24 → 代表月202512
      expect(await fetchIndex(DateTime(2026, 1, 10)), 8);
    });

    test('年度をまたぐ前の1月（代表月1月）はindex 9', () async {
      // 2026/2/1 → 集計期間1/25〜2/24 → 代表月202601
      expect(await fetchIndex(DateTime(2026, 2, 1)), 9);
    });

    test('年度最後の月（代表月3月）はindex 11', () async {
      // 2026/4/1 → 集計期間3/25〜4/24 → 代表月202603
      expect(await fetchIndex(DateTime(2026, 4, 1)), 11);
    });

    test('年度末境界: 4/24は前年度最後の月に属する', () async {
      // 2026/4/24 → 集計期間3/25〜4/24 → 代表月202603 → index 11
      expect(await fetchIndex(DateTime(2026, 4, 24)), 11);
    });

    test('年度始まり境界: 4/25は新年度最初の月に属する', () async {
      // 2026/4/25 → 集計期間4/25〜5/24 → 代表月202604 → index 0
      expect(await fetchIndex(DateTime(2026, 4, 25)), 0);
    });
  });
}
