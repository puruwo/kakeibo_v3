// 年度期間の月数（月平均の分母）の単体テスト
//
// 月平均は「12で割る」のではなく、年度内の経過月数で割る（ユーザー指定 2026-08-29）。
// 集計開始日が1日以外の年度（4/25〜翌4/24）で境界の扱いを固定する。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/util/period_month_count.dart';

void main() {
  // 年度は2025/4/25〜2026/4/24（集計月は 4/25〜5/24, 5/25〜6/24, …）
  final yearPeriod = PeriodValue(
    startDatetime: DateTime(2025, 4, 25),
    endDatetime: DateTime(2026, 4, 24),
  );

  // 集計開始日1日の年度（暦月そのまま）
  final calendarYearPeriod = PeriodValue(
    startDatetime: DateTime(2025, 4, 1),
    endDatetime: DateTime(2026, 3, 31),
  );

  group('periodMonthCount（年度の全月数）', () {
    test('開始日25日の年度は12ヶ月', () {
      expect(periodMonthCount(yearPeriod), 12);
    });

    test('開始日1日の年度も12ヶ月', () {
      expect(periodMonthCount(calendarYearPeriod), 12);
    });
  });

  group('elapsedPeriodMonthCount（年度内の経過月数）', () {
    test('今日が年度の3ヶ月目（7/6は 6/25〜7/24 の集計月）なら3', () {
      expect(elapsedPeriodMonthCount(yearPeriod, DateTime(2025, 7, 6)), 3);
    });

    test('集計月の境界: 7/24までは3ヶ月目、7/25から4ヶ月目', () {
      expect(elapsedPeriodMonthCount(yearPeriod, DateTime(2025, 7, 24)), 3);
      expect(elapsedPeriodMonthCount(yearPeriod, DateTime(2025, 7, 25)), 4);
    });

    test('今日は時刻付き（DateTime.now相当）でも日付だけで判定される', () {
      expect(
        elapsedPeriodMonthCount(yearPeriod, DateTime(2025, 7, 24, 23, 59)),
        3,
      );
      expect(
        elapsedPeriodMonthCount(yearPeriod, DateTime(2025, 7, 25, 0, 1)),
        4,
      );
      // 年度最終日の時刻付きは endDatetime(00:00) より後だが結果は全月数のまま
      expect(
        elapsedPeriodMonthCount(yearPeriod, DateTime(2026, 4, 24, 15, 0)),
        12,
      );
    });

    test('年度開始日当日は1（0除算にならない）', () {
      expect(elapsedPeriodMonthCount(yearPeriod, DateTime(2025, 4, 25)), 1);
    });

    test('年度開始前でも1（未来の年度を開いたとき）', () {
      expect(elapsedPeriodMonthCount(yearPeriod, DateTime(2025, 4, 1)), 1);
    });

    test('年跨ぎ後も数え続ける（2026/1/10 は 12/25〜1/24 で9ヶ月目）', () {
      expect(elapsedPeriodMonthCount(yearPeriod, DateTime(2026, 1, 10)), 9);
    });

    test('年度最終日は12', () {
      expect(elapsedPeriodMonthCount(yearPeriod, DateTime(2026, 4, 24)), 12);
    });

    test('年度終了後（過去の年度を開いたとき）は全月数の12', () {
      expect(elapsedPeriodMonthCount(yearPeriod, DateTime(2026, 8, 1)), 12);
    });

    test('開始日1日の年度は暦月どおりに数える（7/6は4ヶ月目・7/1も4ヶ月目）', () {
      expect(
        elapsedPeriodMonthCount(calendarYearPeriod, DateTime(2025, 7, 6)),
        4,
      );
      expect(
        elapsedPeriodMonthCount(calendarYearPeriod, DateTime(2025, 7, 1)),
        4,
      );
      expect(
        elapsedPeriodMonthCount(calendarYearPeriod, DateTime(2025, 6, 30)),
        3,
      );
    });
  });
}
