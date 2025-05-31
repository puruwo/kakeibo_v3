// test/implements_daily_expense_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'fake_fetch_previous_month_period.dart';

void main() {

  group('ImplementsDailyExpenseRepository.fetch', () {
    test('test1', () async {
      // テスト用の日付を設定
      final testStartDate = DateTime(2025, 03, 25);
      final testEndDate = DateTime(2025, 04, 24);
      final testMonthPeriodValue = PeriodValue(
        startDatetime: testStartDate,
        endDatetime: testEndDate,
      );

      // 正解日付
      final correctStartDate = DateTime(2025, 02, 25);
      final correctEndDate = DateTime(2025, 03, 24);
      final correctMonthPeriodValue = PeriodValue(
        startDatetime: correctStartDate,
        endDatetime: correctEndDate,
      );

      // 結果の検証
      expect(fetchPreviousMonthPeriod(testMonthPeriodValue), equals(correctMonthPeriodValue));
    });

    test('test2', () async {
      // テスト用の日付を設定
      final testStartDate = DateTime(2025, 03, 01);
      final testEndDate = DateTime(2025, 03, 31);
      final testMonthPeriodValue = PeriodValue(
        startDatetime: testStartDate,
        endDatetime: testEndDate,
      );

      // 正解日付
      final correctStartDate = DateTime(2025, 02, 01);
      final correctEndDate = DateTime(2025, 02, 28);
      final correctMonthPeriodValue = PeriodValue(
        startDatetime: correctStartDate,
        endDatetime: correctEndDate,
      );

      // 結果の検証
      expect(fetchPreviousMonthPeriod(testMonthPeriodValue), equals(correctMonthPeriodValue));
    });

    test('test3', () async {
      // テスト用の日付を設定
      final testStartDate = DateTime(2025, 02, 28);
      final testEndDate = DateTime(2025, 03, 27);
      final testMonthPeriodValue = PeriodValue(
        startDatetime: testStartDate,
        endDatetime: testEndDate,
      );

      // 正解日付
      final correctStartDate = DateTime(2025, 01, 28);
      final correctEndDate = DateTime(2025, 02, 27);
      final correctMonthPeriodValue = PeriodValue(
        startDatetime: correctStartDate,
        endDatetime: correctEndDate,
      );

      // 結果の検証
      expect(fetchPreviousMonthPeriod(testMonthPeriodValue), equals(correctMonthPeriodValue));
    });

    test('test4', () async {
      // テスト用の日付を設定
      final testStartDate = DateTime(2025, 01, 31);
      final testEndDate = DateTime(2025, 02, 27);
      final testMonthPeriodValue = PeriodValue(
        startDatetime: testStartDate,
        endDatetime: testEndDate,
      );

      // 正解日付
      final correctStartDate = DateTime(2024, 12, 31);
      final correctEndDate = DateTime(2025, 01, 30);
      final correctMonthPeriodValue = PeriodValue(
        startDatetime: correctStartDate,
        endDatetime: correctEndDate,
      );

      // 結果の検証
      expect(fetchPreviousMonthPeriod(testMonthPeriodValue), equals(correctMonthPeriodValue));
    });
    test('test5', () async {
      // テスト用の日付を設定
      final testStartDate = DateTime(2025, 01, 01);
      final testEndDate = DateTime(2025, 01, 31);
      final testMonthPeriodValue = PeriodValue(
        startDatetime: testStartDate,
        endDatetime: testEndDate,
      );

      // 正解日付
      final correctStartDate = DateTime(2024, 12, 01);
      final correctEndDate = DateTime(2024, 12, 31);
      final correctMonthPeriodValue = PeriodValue(
        startDatetime: correctStartDate,
        endDatetime: correctEndDate,
      );

      // 結果の検証
      expect(fetchPreviousMonthPeriod(testMonthPeriodValue), equals(correctMonthPeriodValue));
    });
    test('test6', () async {
      // テスト用の日付を設定
      final testStartDate = DateTime(2025, 01, 31);
      final testEndDate = DateTime(2025, 02, 27);
      final testMonthPeriodValue = PeriodValue(
        startDatetime: testStartDate,
        endDatetime: testEndDate,
      );

      // 正解日付
      final correctStartDate = DateTime(2024, 12, 31);
      final correctEndDate = DateTime(2025, 01, 30);
      final correctMonthPeriodValue = PeriodValue(
        startDatetime: correctStartDate,
        endDatetime: correctEndDate,
      );

      // 結果の検証
      expect(fetchPreviousMonthPeriod(testMonthPeriodValue), equals(correctMonthPeriodValue));
    });
    test('test7', () async {
      // テスト用の日付を設定
      final testStartDate = DateTime(2025, 02, 28);
      final testEndDate = DateTime(2025, 03, 27);
      final testMonthPeriodValue = PeriodValue(
        startDatetime: testStartDate,
        endDatetime: testEndDate,
      );

      // 正解日付
      final correctStartDate = DateTime(2025, 01, 28);
      final correctEndDate = DateTime(2025, 02, 27);
      final correctMonthPeriodValue = PeriodValue(
        startDatetime: correctStartDate,
        endDatetime: correctEndDate,
      );

      // 結果の検証
      expect(fetchPreviousMonthPeriod(testMonthPeriodValue), equals(correctMonthPeriodValue));
    });
    test('test8', () async {
      // テスト用の日付を設定
      final testStartDate = DateTime(2025, 02, 01);
      final testEndDate = DateTime(2025, 02, 28);
      final testMonthPeriodValue = PeriodValue(
        startDatetime: testStartDate,
        endDatetime: testEndDate,
      );

      // 正解日付
      final correctStartDate = DateTime(2025, 01, 01);
      final correctEndDate = DateTime(2025, 01, 31);
      final correctMonthPeriodValue = PeriodValue(
        startDatetime: correctStartDate,
        endDatetime: correctEndDate,
      );

      // 結果の検証
      expect(fetchPreviousMonthPeriod(testMonthPeriodValue), equals(correctMonthPeriodValue));
    });
    test('test9', () async {
      // テスト用の日付を設定
      final testStartDate = DateTime(2025, 02, 28);
      final testEndDate = DateTime(2025, 03, 30);
      final testMonthPeriodValue = PeriodValue(
        startDatetime: testStartDate,
        endDatetime: testEndDate,
      );

      // 正解日付
      final correctStartDate = DateTime(2025, 01, 28);
      final correctEndDate = DateTime(2025, 02, 27);
      final correctMonthPeriodValue = PeriodValue(
        startDatetime: correctStartDate,
        endDatetime: correctEndDate,
      );

      // 結果の検証
      expect(fetchPreviousMonthPeriod(testMonthPeriodValue), equals(correctMonthPeriodValue));
    }); 

  });

  
}