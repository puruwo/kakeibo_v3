import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/util/extension/datetime_extension.dart';

void main() {
  group('DateTimeAdditions.addMonths', () {
    test('通常の月加算', () {
      expect(DateTime(2025, 7, 15).addMonths(1), DateTime(2025, 8, 15));
    });

    test('複数月の加算', () {
      expect(DateTime(2025, 7, 15).addMonths(3), DateTime(2025, 10, 15));
    });

    test('年をまたぐ加算', () {
      expect(DateTime(2025, 12, 25).addMonths(1), DateTime(2026, 1, 25));
    });

    test('12ヶ月の加算はちょうど1年後になる', () {
      expect(DateTime(2025, 7, 15).addMonths(12), DateTime(2026, 7, 15));
    });

    test('加算先の月に同じ日が存在しない場合は月末に丸める（1/31 + 1ヶ月 → 2/28）', () {
      expect(DateTime(2025, 1, 31).addMonths(1), DateTime(2025, 2, 28));
    });

    test('閏年の2月へは29日に丸める（2024/1/31 + 1ヶ月 → 2024/2/29）', () {
      expect(DateTime(2024, 1, 31).addMonths(1), DateTime(2024, 2, 29));
    });

    test('31日から30日までの月への加算は30日に丸める', () {
      expect(DateTime(2025, 3, 31).addMonths(1), DateTime(2025, 4, 30));
    });

    test('負の値で月を戻す', () {
      expect(DateTime(2025, 7, 15).addMonths(-1), DateTime(2025, 6, 15));
    });

    test('負の値で年をまたいで戻す', () {
      expect(DateTime(2025, 1, 15).addMonths(-1), DateTime(2024, 12, 15));
    });

    test('負の値でも月末丸めが効く（3/31 - 1ヶ月 → 2/28）', () {
      expect(DateTime(2025, 3, 31).addMonths(-1), DateTime(2025, 2, 28));
    });

    test('0ヶ月の加算は同じ日付を返す', () {
      expect(DateTime(2025, 7, 15).addMonths(0), DateTime(2025, 7, 15));
    });
  });

  group('DateTimeAdditions.addYears', () {
    test('通常の年加算', () {
      expect(DateTime(2025, 7, 15).addYears(1), DateTime(2026, 7, 15));
    });

    test('閏日からの加算は2/28に丸める（2024/2/29 + 1年 → 2025/2/28）', () {
      expect(DateTime(2024, 2, 29).addYears(1), DateTime(2025, 2, 28));
    });

    test('複数年の加算', () {
      expect(DateTime(2025, 7, 15).addYears(3), DateTime(2028, 7, 15));
    });
  });

  group('DateTimeAdditions.toFormattedString', () {
    test('yyyyMMdd形式にゼロ埋めで変換する', () {
      expect(DateTime(2025, 3, 5).toFormattedString(), '20250305');
    });

    test('2桁の月日はそのまま', () {
      expect(DateTime(2025, 12, 31).toFormattedString(), '20251231');
    });
  });

  group('DateTimeAdditions.getMonthPeriod', () {
    test('その日を含む暦月の1日〜末日を返す', () {
      expect(
        DateTime(2025, 7, 15).getMonthPeriod(),
        PeriodValue(
          startDatetime: DateTime(2025, 7, 1),
          endDatetime: DateTime(2025, 7, 31),
        ),
      );
    });

    test('2月は28日まで（平年）', () {
      expect(
        DateTime(2025, 2, 10).getMonthPeriod(),
        PeriodValue(
          startDatetime: DateTime(2025, 2, 1),
          endDatetime: DateTime(2025, 2, 28),
        ),
      );
    });

    test('12月は年内で完結する', () {
      expect(
        DateTime(2025, 12, 10).getMonthPeriod(),
        PeriodValue(
          startDatetime: DateTime(2025, 12, 1),
          endDatetime: DateTime(2025, 12, 31),
        ),
      );
    });
  });

  group('DateTimeParsing.toDateTime', () {
    test('yyyyMMdd文字列をDateTimeに変換する', () {
      expect('20250325'.toDateTime(), DateTime(2025, 3, 25));
    });

    test('月初日の変換', () {
      expect('20250101'.toDateTime(), DateTime(2025, 1, 1));
    });
  });

  group('DateTimeComparison.isSameDate', () {
    test('同じ日付なら時刻が違ってもtrue', () {
      expect(
        DateTime(2025, 7, 15, 10, 30).isSameDate(DateTime(2025, 7, 15, 23, 59)),
        isTrue,
      );
    });

    test('日が違えばfalse', () {
      expect(DateTime(2025, 7, 15).isSameDate(DateTime(2025, 7, 16)), isFalse);
    });

    test('同じ日でも月が違えばfalse', () {
      expect(DateTime(2025, 7, 15).isSameDate(DateTime(2025, 8, 15)), isFalse);
    });
  });
}
