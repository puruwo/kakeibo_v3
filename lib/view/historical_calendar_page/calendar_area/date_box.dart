import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/calendar/calendar_tile_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';
import 'package:kakeibo/view_model/state/calendar_page/is_datebox_selected/is_datebox_selected.dart';
import 'package:kakeibo/view_model/state/date_scope/historical_page/selected_datetime/historical_selected_datetime.dart';

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

    // 支出ラベルを作成
    final expenseLabel = calculatePriceLabel(totalExpenseBuff, isIncome: false);
    // 収入ラベルを作成
    final incomeLabel =
        calculatePriceLabel(calendarTileEntity.totalIncome, isIncome: true);

    return AppInkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: switch (tileStatus) {
          CalendarTileStatus.unselected => () {
              final notifier =
                  ref.read(historicalSelectedDatetimeNotifierProvider.notifier);
              notifier.updateState(DateTime(year, month, day));
            },
          CalendarTileStatus.selected => () {
              _showEditExpenseSheet(context, DateTime(year, month, day));
            },
          CalendarTileStatus.outOfPeriod => () {},
        },
        child: switch (tileStatus) {
          CalendarTileStatus.selected => activeDateBox(weekday, dateLabel,
              expenseLabel, incomeLabel, boxHeight, boxWidth),
          CalendarTileStatus.unselected => normalDateBox(weekday, dateLabel,
              expenseLabel, incomeLabel, boxHeight, boxWidth),
          CalendarTileStatus.outOfPeriod =>
            vacantDateBox(weekday, dateLabel, boxHeight, boxWidth),
        });
  }
}

Widget calculatePriceLabel(int amount, {required bool isIncome}) {
  if (amount == 0) {
    return const SizedBox.shrink();
  } else {
    final buff = formattedPriceGetter(amount);

    if (amount > 1888888) {
      return const SizedBox.shrink(); // overflow対策の既存ロジック
    }

    // 支出用のフォントスタイルを使用（収入も同じフォント）
    TextStyle style;
    if (amount <= 99999) {
      style = MyFonts.calendarDateBoxLarge;
    } else {
      style = MyFonts.calendarDateBoxSmall;
    }

    // アイコンとテキストを横並びで表示
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 収入は青い+アイコン、支出は赤い-アイコン
        Icon(
          isIncome ? Icons.add : Icons.remove,
          color: isIncome ? MyColors.mintBlue : MyColors.pink,
          size: 10,
        ),
        Text(
          buff,
          textAlign: TextAlign.center,
          overflow: TextOverflow.fade,
          style: style,
        ),
      ],
    );
  }
}

Container activeDateBox(int weekday, String dateLabel, Widget expenseLabel,
    Widget incomeLabel, double boxHeight, double boxWidth) {
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
            style: weekday == 6
                ? MyFonts.calendarDateLabelSaturday
                : weekday == 7
                    ? MyFonts.calendarDateLabelSunday
                    : MyFonts.calendarDateLabel,
          ),
          // 支出
          if (expenseLabel is! SizedBox)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: boxWidth,
                child: expenseLabel,
              ),
            ),
          // 収入
          if (incomeLabel is! SizedBox)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: boxWidth,
                child: incomeLabel,
              ),
            )
        ],
      ),
    ),
  );
}

Container normalDateBox(int weekday, String dateLabel, Widget expenseLabel,
    Widget incomeLabel, double boxHeight, double boxWidth) {
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
            style: weekday == 6
                ? MyFonts.calendarDateLabelSaturday
                : weekday == 7
                    ? MyFonts.calendarDateLabelSunday
                    : MyFonts.calendarDateLabel,
          ),
          // 支出
          if (expenseLabel is! SizedBox)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: boxWidth,
                child: expenseLabel,
              ),
            ),
          // 収入
          if (incomeLabel is! SizedBox)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: boxWidth,
                child: incomeLabel,
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
          Text(dateLabel, style: MyFonts.calendarOutOfPeriodDateLabel),
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
        theme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(),
        home: MediaQuery.withClampedTextScaling(
            // テキストサイズの制御
            minScaleFactor: 0.7,
            maxScaleFactor: 0.95,
            child: RegisaterPageBase.addExpense(
              expenseEntity: ExpenseEntity(
                date: DateFormat('yyyyMMdd').format(selectedDate),
              ),
            )),
      );
    },
  );
}
