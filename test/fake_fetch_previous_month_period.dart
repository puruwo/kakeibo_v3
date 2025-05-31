import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';

PeriodValue fetchPreviousMonthPeriod(PeriodValue monthPeriodValue) {
    final previousMonthStartDateBuff = DateTime(monthPeriodValue.startDatetime.year, monthPeriodValue.startDatetime.month - 1, monthPeriodValue.startDatetime.day);

    // 開始日
    DateTime previousMonthPeriodStartDate;

    // 前月の最終日の日付よりも、開始基準日が大きい場合 
    if (previousMonthStartDateBuff.day < monthPeriodValue.startDatetime.day) {
      // 開始日: 前月の最終日を開始日として扱い
      previousMonthPeriodStartDate = previousMonthStartDateBuff;
    } 
    // 開始基準日が前月に存在する場合 
    else if (previousMonthStartDateBuff.day >= monthPeriodValue.startDatetime.day) {
      // 開始日: 前月の年と月の値と、開始基準日を代入して返却
      previousMonthPeriodStartDate = DateTime(previousMonthStartDateBuff.year, previousMonthStartDateBuff.month, monthPeriodValue.startDatetime.day); 
    }else{
      throw Exception('開始基準日の処理に失敗しました');
    }

    // 終了日: 前月の開始基準日を終了日として扱う
    final previousMonthPeriodEndDate = monthPeriodValue.startDatetime.add(const Duration(days: -1));

    return PeriodValue(startDatetime:previousMonthPeriodStartDate,endDatetime: previousMonthPeriodEndDate);
  }