import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/properties.dart';
import 'package:kakeibo/domain/calendar_day_entity/calendar_tile_entity.dart';
import 'package:kakeibo/domain/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain_service/month_period_service/month_period_service.dart';

import 'package:kakeibo/domain/daily_expense_entity/daily_expense_entity.dart';
import 'package:kakeibo/domain/daily_expense_entity/daily_expense_repository.dart';

final calendarUsecaseProvider = Provider<CalendarUsecase>(
  CalendarUsecase.new,
);

class CalendarUsecase {
  final Ref _ref;

  CalendarUsecase(this._ref);

  DailyExpenseRepository get _dailyExpenseRepository =>
      _ref.watch(dailyExpenseRepositoryProvider);

  // 集計期間に関するリポジトリ
  MonthPeriodService get _monthPeriodServiceProvider => _ref.watch(monthPeriodServiceProvider);

  // 入力した日付を含む集計期間のデータを取得する
  Future<List<List<CalendarTileEntity>>> fetch(int calendarPage) async {
    
    // カレンダーページと初期カレンダーページの差分を取得
    final distanceFromInitialPage = calendarPage - CalendarProperties().initialCalendarPage;

    // 取得するデータをカレンダーページとselectedDateから取得する
    final selectedDateInThisPage = safeDate(DateTime.now(),distanceFromInitialPage);

    // 集計期間を取得する
    final MonthPeriodValue monthPeriod = await _monthPeriodServiceProvider.fetchMonthPeriod(selectedDateInThisPage);

    // 期間内の日毎の支出データを取得する
    final List<CalendarTileEntity> inPeriodCalendarTileList = [];
    
    // 集計開始日を取得する
    final int aggregationStartDay = await _monthPeriodServiceProvider.fetchAggregationStartDay();

    // 期間開始日から終了日までのデータを取得する
    DateTime thisLoopDatetime = monthPeriod.startDatetime;
    for (var i = 0; thisLoopDatetime.isBefore(monthPeriod.endDatetime); i++) {
      
      thisLoopDatetime = monthPeriod.startDatetime.add(Duration(days: i));
      
      final DailyExpenseEntity dailyExpenseEntity = await _dailyExpenseRepository.fetch(dateTime: thisLoopDatetime);

      // カレンダーの日づげ表示に月を表示するかどうか
      bool shouldDisplayMonth = false;
      if(dailyExpenseEntity.date.day == 1 || dailyExpenseEntity.date.day == aggregationStartDay) shouldDisplayMonth=true;

      // CalendarTileEntityを作成
      final CalendarTileEntity calendarTileEntity = CalendarTileEntity(
        year: dailyExpenseEntity.date.year,
        month: dailyExpenseEntity.date.month,
        day: dailyExpenseEntity.date.day,
        weekday: dailyExpenseEntity.date.weekday,
        totalExpense: dailyExpenseEntity.totalExpense,
        isWithinAggregationRange: true,
        shouldDisplayMonth: shouldDisplayMonth,
      );
      
      inPeriodCalendarTileList.add(calendarTileEntity);
    }

    // カレンダーの表示領域の集計期間外の日を埋める
    final calendarTileEntityList = fillOutOfPeriod(inPeriodCalendarTileList);

    // Listを一週間ごとに分割する
    final List<List<CalendarTileEntity>>calendarTileList = [];
    for (var i = 0; i < calendarTileEntityList.length; i += 7) {
      calendarTileList.add(calendarTileEntityList.sublist(i, i + 7));
    }

    return calendarTileList;
  }
}

// 月を跨ぐ際に日付を安全に取得する
DateTime safeDate(DateTime selectedDate, int calendarPage) {
  DateTime endDateInThisPage = DateTime(selectedDate.year, selectedDate.month + calendarPage, 0);
  
  // 移動前の日付が移動後の月の月末日より大きい場合、月末にする
  if(selectedDate.day > endDateInThisPage.day)return endDateInThisPage;
  
  // 移動前の日付が移動後の月の月末日より小さい場合、そのままの日付にする
  return DateTime(selectedDate.year, selectedDate.month + calendarPage, selectedDate.day);
}

// カレンダーの表示領域の集計期間外の日を埋める
List<CalendarTileEntity> fillOutOfPeriod(List<CalendarTileEntity> inPeriodcalendarTileList) {
  
  // 期間内の最初の日が日曜日でない場合、期間外の日を埋める
  while(inPeriodcalendarTileList.first.weekday != DateTime.sunday){
    final firstDate = inPeriodcalendarTileList.first;
    final previousDate = DateTime(firstDate.year, firstDate.month, firstDate.day - 1);
    final previousCalendarTileEntity = CalendarTileEntity(
      year: previousDate.year,
      month: previousDate.month,
      day: previousDate.day,
      weekday: previousDate.weekday,
      totalExpense: 0,
      isWithinAggregationRange: false,
      shouldDisplayMonth: false,
    );
    inPeriodcalendarTileList.insert(0, previousCalendarTileEntity);
  }

  // 期間内の最後の日が土曜日でない場合、期間外の日を埋める
  while(inPeriodcalendarTileList.last.weekday != DateTime.saturday){
    final lastDate = inPeriodcalendarTileList.last;
    final nextDate = DateTime(lastDate.year, lastDate.month, lastDate.day + 1);
    final nextCalendarTileEntity = CalendarTileEntity(
      year: nextDate.year,
      month: nextDate.month,
      day: nextDate.day,
      weekday: nextDate.weekday,
      totalExpense: 0,
      isWithinAggregationRange: false,
      shouldDisplayMonth: false,
    );
    inPeriodcalendarTileList.add(nextCalendarTileEntity);
  }

  return inPeriodcalendarTileList;
}
