import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/calendar/calendar_tile_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/register_page/torok.dart';
import 'package:kakeibo/view_model/state/calendar_page/is_datebox_selected/is_datebox_selected.dart';
import 'package:kakeibo/view_model/state/date_scope/selected_datetime/selected_datetime.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';

enum CalendarTileStatus {
  selected,
  unselected,
  outOfPeriod,
}

class DateBox extends ConsumerWidget {
  const DateBox({
    super.key,
    required this.calendarTileEntity,
    required this.boxHeight,
    required this.boxWidth,
  });

  final CalendarTileEntity calendarTileEntity;

  final double boxHeight;

  final double boxWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isWithinAggregationRange = calendarTileEntity.isWithinAggregationRange;
    int year = calendarTileEntity.year;
    int month = calendarTileEntity.month;
    int day = calendarTileEntity.day;
    int weekday = calendarTileEntity.weekday;
    int totalExpenseBuff = calendarTileEntity.totalExpense;
    bool shouldDisplayMonth = calendarTileEntity.shouldDisplayMonth;

    // 選択された日付かどうかを判定
    final isSelected =
        ref.watch(isDateboxSelectedProvider(DateTime(year, month, day)));

    // タイルの状態をisWithinAggregationRangeとisSelectedから複合的に判定
    final tileStatus = switch (isWithinAggregationRange) {
      true => isSelected
          ? CalendarTileStatus.selected
          : CalendarTileStatus.unselected,
      false => CalendarTileStatus.outOfPeriod,
    };

    // 月を表示するかどうか判定して、日付ラベルを作成
    final dateLabel = shouldDisplayMonth ? '$month/$day' : '$day';

    // 金額ラベルを作成
    final priceLabel = caluculatePriceLabel(totalExpenseBuff);

    return InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: switch (tileStatus) {
          CalendarTileStatus.unselected => () {
              final notifier =
                  ref.read(selectedDatetimeNotifierProvider.notifier);
              notifier.updateState(DateTime(year, month, day));
            },
          CalendarTileStatus.selected => () {
              _showEditExpenseSheet(context, DateTime(year, month, day));
            },
          CalendarTileStatus.outOfPeriod => () {},
        },
        child: switch (tileStatus) {
          CalendarTileStatus.selected =>
            activeDateBox(weekday, dateLabel, priceLabel, boxHeight, boxWidth),
          CalendarTileStatus.unselected =>
            normalDateBox(weekday, dateLabel, priceLabel, boxHeight, boxWidth),
          CalendarTileStatus.outOfPeriod =>
            vacantDateBox(weekday, dateLabel, boxHeight, boxWidth),
        });
  }
}

Text caluculatePriceLabel(int totalExpenseBuff) {
  if (totalExpenseBuff == 0) {
    return const Text('');
  } else {
    if (totalExpenseBuff > 1888888) {
      return const Text('');
    } else if (totalExpenseBuff <= 9999) {
      final buff = formattedPriceGetter(totalExpenseBuff);
      return Text('¥$buff',
          textAlign: TextAlign.center,
          overflow: TextOverflow.fade,
          style: MyFonts.calendarDateBoxLarge);
    } else if (totalExpenseBuff <= 99999) {
      final buff = formattedPriceGetter(totalExpenseBuff);
      return Text(buff,
          textAlign: TextAlign.center,
          overflow: TextOverflow.fade,
          style: MyFonts.calendarDateBoxLarge);
    } else {
      final buff = formattedPriceGetter(totalExpenseBuff);
      return Text(buff,
          textAlign: TextAlign.center,
          overflow: TextOverflow.fade,
          style: MyFonts.calendarDateBoxSmall);
    }
  }
}

Container activeDateBox(int weekday, String dateLabel, Text priceLabel,
    double boxHeight, double boxWidth) {
  return Container(
    width: boxWidth,
    height: boxHeight,
    decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        color: MyColors.tirtiarySystemfill),
    child: Center(
      child: Column(
        children: [
          Text(
            dateLabel,
            style: TextStyle(
              color: weekday == 6
                  ? MyColors.blue
                  : weekday == 7
                      ? MyColors.red
                      : MyColors.secondaryLabel,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: SizedBox(
              width: boxWidth,
              child: priceLabel,
            ),
          )
        ],
      ),
    ),
  );
}

Container normalDateBox(int weekday, String dateLabel, Text priceLabel,
    double boxHeight, double boxWidth) {
  return Container(
    width: boxWidth,
    height: boxHeight,
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(6)),
    ),
    child: Center(
      child: Column(
        children: [
          Text(
            dateLabel,
            style: TextStyle(
              color: weekday == 6
                  ? MyColors.blue
                  : weekday == 7
                      ? MyColors.red
                      : MyColors.secondaryLabel,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: SizedBox(
              width: boxWidth,
              child: priceLabel,
            ),
          )
        ],
      ),
    ),
  );
}

Container vacantDateBox(
    int weekday, String dateLabel, double boxHeight, double boxWidth) {
  return Container(
    width: boxWidth,
    height: boxHeight,
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(6)),
    ),
    child: Center(
      child: Column(
        children: [
          Text(dateLabel,
              style: const TextStyle(color: MyColors.tirtiaryLabel)),
        ],
      ),
    ),
  );
}

void _showEditExpenseSheet(BuildContext context, DateTime selectedDate) {
  showModalBottomSheet(
    //sccafoldの上に出すか
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(
      maxWidth: 2000,
    ),
    context: context,
    // constで呼び出さないとリビルドがかかってtextfieldのも何度も作り直してしまう
    builder: (context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MediaQuery.withClampedTextScaling(
            // テキストサイズの制御
            minScaleFactor: 0.7,
            maxScaleFactor: 0.95,
            child: Torok(
              expenseEntity: ExpenseEntity(
                  date: DateFormat('yyyyMMdd').format(selectedDate),),
              mode: RegisterScreenMode.add,
            )),
      );
    },
  );
}
