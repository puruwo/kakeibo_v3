import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';

extension DateTimeAdditions on DateTime {
  // nヶ月後を計算
  DateTime addMonths(int months) {
    final int newYear = year + ((month - 1 + months) ~/ 12);
    final int newMonth = ((month - 1 + months) % 12) + 1;
    // 対象月の最終日を取得
    final lastDay = DateTime(newYear, newMonth + 1, 0).day;
    final newDay = day > lastDay ? lastDay : day;
    return DateTime(newYear, newMonth, newDay);
  }

  // n年後を計算
  DateTime addYears(int years) {
    final int newYear = year + years;
    final int newMonth = month;
    final lastDay = DateTime(newYear, newMonth + 1, 0).day;
    final newDay = day > lastDay ? lastDay : day;
    return DateTime(newYear, newMonth, newDay);
  }

  // 日付を文字列に変換
  String toFormattedString() {
    return '${year.toString().padLeft(4, '0')}${month.toString().padLeft(2, '0')}${day.toString().padLeft(2, '0')}';
  }

  // その月の期間を返却
  PeriodValue getMonthPeriod() {
    final startDatetime = DateTime(year, month, 1);
    final endDatetime =
        DateTime(year, month + 1, 1).subtract(const Duration(days: 1));
    return PeriodValue(startDatetime: startDatetime, endDatetime: endDatetime);
  }
}

extension DateTimeParsing on String {
  // 文字列をDateTimeに変換
  DateTime toDateTime() {
    DateTime dateTime = DateTime.parse(
        '${substring(0, 4)}${substring(4, 6)}${substring(6, 8)}');

    return dateTime;
  }
}

extension DateTimeComparison on DateTime {
  // 日付が同じかどうかを比較
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
