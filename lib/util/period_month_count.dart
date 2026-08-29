import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';

/// 期間に含まれる集計月数（年度なら12）
///
/// 集計開始日が1日以外の年度期間（例: 4/25〜翌4/24）でも12を返すよう、
/// 終端の日が開始日以上のときだけ1ヶ月に数える。
int periodMonthCount(PeriodValue period) {
  return _monthCountBetween(period.startDatetime, period.endDatetime);
}

/// 年度内の経過月数（月平均の分母。ユーザー指定 2026-08-29）
///
/// 年度開始月から、[today] が属する集計月（集計開始日起点）までを数える。
/// 今日が年度終了後なら全月数、年度開始前なら1（0除算を避ける）。
int elapsedPeriodMonthCount(PeriodValue period, DateTime today) {
  if (today.isBefore(period.startDatetime)) return 1;
  if (today.isAfter(period.endDatetime)) return periodMonthCount(period);
  return _monthCountBetween(period.startDatetime, today);
}

int _monthCountBetween(DateTime start, DateTime end) {
  final months =
      (end.year - start.year) * 12 +
      (end.month - start.month) +
      (end.day >= start.day ? 1 : 0);
  return months <= 0 ? 1 : months;
}
