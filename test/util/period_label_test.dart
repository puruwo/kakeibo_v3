// 月度の表示ラベル（lib/util/util.dart の mmToMMGetter / periodDayRangeGetter）のUT
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/util/util.dart';

void main() {
  PeriodValue period(DateTime start, DateTime end) =>
      PeriodValue(startDatetime: start, endDatetime: end);

  group('mmToMMGetter', () {
    test('開始日が1日なら、その月だけを出す', () {
      expect(
        mmToMMGetter(period(DateTime(2026, 9, 1), DateTime(2026, 9, 30))),
        '9月',
      );
    });

    test('開始日が1日以外なら、開始月と次の月を出す', () {
      expect(
        mmToMMGetter(period(DateTime(2026, 8, 25), DateTime(2026, 9, 24))),
        '8 - 9月',
      );
    });

    test('12月開始で年をまたぐときは次の月が1月になる', () {
      expect(
        mmToMMGetter(period(DateTime(2026, 12, 25), DateTime(2027, 1, 24))),
        '12 - 1月',
      );
    });
  });

  group('periodDayRangeGetter', () {
    test('開始日と終了日（期間に含む日）を M/d〜M/d で出す', () {
      expect(
        periodDayRangeGetter(
          period(DateTime(2026, 8, 25), DateTime(2026, 9, 24)),
        ),
        '8/25〜9/24',
      );
    });

    test('月初開始の期間は月末までを出す', () {
      expect(
        periodDayRangeGetter(
          period(DateTime(2026, 2, 1), DateTime(2026, 2, 28)),
        ),
        '2/1〜2/28',
      );
    });
  });
}
