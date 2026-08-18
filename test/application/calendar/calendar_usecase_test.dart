import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/calendar/calendar_usecase.dart';
import 'package:kakeibo/constant/properties.dart';
import 'package:kakeibo/domain/core/daily_expense_entity/daily_expense_entity.dart';
import 'package:kakeibo/domain/core/daily_expense_entity/daily_expense_repository.dart';
import 'package:kakeibo/domain/ui_value/calendar/calendar_tile_entity.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  /// 指定した暦月の「集計期間内タイル」を組み立てる（fillOutOfPeriod の入力）
  List<CalendarTileEntity> buildInPeriodTiles(int year, int month) {
    // 翌月0日＝当月末日
    final lastDay = DateTime(year, month + 1, 0).day;
    return [
      for (var day = 1; day <= lastDay; day++)
        CalendarTileEntity(
          year: year,
          month: month,
          day: day,
          weekday: DateTime(year, month, day).weekday,
          totalExpense: 100,
          totalIncome: 200,
          isWithinAggregationRange: true,
          shouldDisplayMonth: day == 1,
        ),
    ];
  }

  /// 週ごとに分割された結果を平坦化する
  List<CalendarTileEntity> flatten(List<List<CalendarTileEntity>> weeks) =>
      weeks.expand((week) => week).toList();

  /// 集計期間内（＝対象暦月）のタイルだけ取り出す
  List<CalendarTileEntity> inRangeTiles(List<List<CalendarTileEntity>> weeks) =>
      flatten(weeks).where((tile) => tile.isWithinAggregationRange).toList();

  ProviderContainer createCalendarContainer({
    Map<DateTime, DailyExpenseEntity> dailyExpenses = const {},
    DateTime? systemDate,
  }) {
    return createContainer(
      overrides: [
        // システム日時を2025/7/15に固定する（初期ページ＝2025年7月）
        ...aggregationSettingOverrides(
          systemDate: systemDate ?? DateTime(2025, 7, 15),
        ),
        dailyExpenseRepositoryProvider.overrideWithValue(
          FakeDailyExpenseRepository(dailyExpenses: dailyExpenses),
        ),
      ],
    );
  }

  group('fillOutOfPeriod', () {
    test('月初が日曜なら前パディングは追加されない', () {
      // 2025/6/1は日曜
      final result = fillOutOfPeriod(buildInPeriodTiles(2025, 6));

      expect(result.first.year, 2025);
      expect(result.first.month, 6);
      expect(result.first.day, 1);
      expect(result.first.weekday, DateTime.sunday);
      expect(result.first.isWithinAggregationRange, isTrue);
    });

    test('月初が日曜以外なら直前の日曜まで前パディングが追加される', () {
      // 2025/7/1は火曜 → 6/30(月)・6/29(日)の2日が前に付く
      final result = fillOutOfPeriod(buildInPeriodTiles(2025, 7));

      expect(result.first.weekday, DateTime.sunday);
      final padding = result
          .takeWhile((tile) => !tile.isWithinAggregationRange)
          .toList();
      expect(padding, hasLength(2));
      expect(padding.map((tile) => tile.day), [29, 30]);
    });

    test('月末が土曜なら後パディングは追加されない', () {
      // 2025/5/31は土曜
      final result = fillOutOfPeriod(buildInPeriodTiles(2025, 5));

      expect(result.last.year, 2025);
      expect(result.last.month, 5);
      expect(result.last.day, 31);
      expect(result.last.weekday, DateTime.saturday);
      expect(result.last.isWithinAggregationRange, isTrue);
    });

    test('月末が土曜以外なら直後の土曜まで後パディングが追加される', () {
      // 2025/7/31は木曜 → 8/1(金)・8/2(土)の2日が後に付く
      final result = fillOutOfPeriod(buildInPeriodTiles(2025, 7));

      expect(result.last.weekday, DateTime.saturday);
      final padding = result.reversed
          .takeWhile((tile) => !tile.isWithinAggregationRange)
          .toList()
          .reversed
          .toList();
      expect(padding, hasLength(2));
      expect(padding.map((tile) => tile.day), [1, 2]);
    });

    test('パディングタイルは期間外・金額0で前月/翌月の日付になる（月跨ぎ）', () {
      final result = fillOutOfPeriod(buildInPeriodTiles(2025, 7));

      final padding = result
          .where((tile) => !tile.isWithinAggregationRange)
          .toList();

      expect(padding, hasLength(4));
      for (final tile in padding) {
        expect(tile.isWithinAggregationRange, isFalse);
        expect(tile.totalExpense, 0);
        expect(tile.totalIncome, 0);
        // パディングは1日であっても月表示しない
        expect(tile.shouldDisplayMonth, isFalse);
      }
      // 前パディングは前月（6月）、後パディングは翌月（8月）の日付になる
      expect(padding.map((tile) => (tile.year, tile.month, tile.day)), [
        (2025, 6, 29),
        (2025, 6, 30),
        (2025, 8, 1),
        (2025, 8, 2),
      ]);
    });
  });

  group('CalendarUsecaseNotifier.fetch', () {
    test('ページ番号から対象の暦月が決まる（初期ページ＝当月・±1で前後月）', () async {
      final initialPage = CalendarProperties().initialCalendarPage;
      final container = createCalendarContainer();

      final current = await container.read(
        calendarUsecaseNotifierProvider(initialPage).future,
      );
      final previous = await container.read(
        calendarUsecaseNotifierProvider(initialPage - 1).future,
      );
      final next = await container.read(
        calendarUsecaseNotifierProvider(initialPage + 1).future,
      );

      // 初期ページはシステム日時の月（2025年7月）
      final currentTiles = inRangeTiles(current);
      expect(currentTiles, hasLength(31));
      expect((currentTiles.first.year, currentTiles.first.month), (2025, 7));
      expect(currentTiles.first.day, 1);
      expect(currentTiles.last.day, 31);

      // -1で前月（2025年6月・30日まで）
      final previousTiles = inRangeTiles(previous);
      expect(previousTiles, hasLength(30));
      expect((previousTiles.first.year, previousTiles.first.month), (2025, 6));
      expect(previousTiles.last.day, 30);

      // +1で翌月（2025年8月・31日まで）
      final nextTiles = inRangeTiles(next);
      expect(nextTiles, hasLength(31));
      expect((nextTiles.first.year, nextTiles.first.month), (2025, 8));
      expect(nextTiles.last.day, 31);
    });

    test('月表示フラグが立つのは1日のタイルだけ', () async {
      final container = createCalendarContainer();

      final result = await container.read(
        calendarUsecaseNotifierProvider(
          CalendarProperties().initialCalendarPage,
        ).future,
      );

      final monthDisplayed = flatten(
        result,
      ).where((tile) => tile.shouldDisplayMonth).toList();

      // 8/1はパディングなので対象外。7/1だけが月表示になる
      expect(monthDisplayed, hasLength(1));
      expect((monthDisplayed.single.month, monthDisplayed.single.day), (7, 1));
    });

    test('取得した日毎の金額が7日ごとの週リストに分割される', () async {
      final container = createCalendarContainer(
        dailyExpenses: {
          DateTime(2025, 7, 1): DailyExpenseEntity(
            date: DateTime(2025, 7, 1),
            totalExpense: 1200,
            totalIncome: 300,
          ),
        },
      );

      final result = await container.read(
        calendarUsecaseNotifierProvider(
          CalendarProperties().initialCalendarPage,
        ).future,
      );

      // 前後パディング込みで7の倍数になり、どの週も7要素
      for (final week in result) {
        expect(week, hasLength(7));
      }
      expect(flatten(result), hasLength(result.length * 7));

      // リポジトリから取得した金額がタイルに反映される
      final july1 = flatten(
        result,
      ).firstWhere((tile) => tile.month == 7 && tile.day == 1);
      expect(july1.totalExpense, 1200);
      expect(july1.totalIncome, 300);
      // 未設定の日は合計0
      final july2 = flatten(
        result,
      ).firstWhere((tile) => tile.month == 7 && tile.day == 2);
      expect(july2.totalExpense, 0);
      expect(july2.totalIncome, 0);
    });
  });
}
