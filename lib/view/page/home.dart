import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/atom/calendar_next_arrow_button.dart';
import 'package:kakeibo/view/atom/calendar_previous_arrow_button.dart';

import 'package:kakeibo/view/atom/next_arrow_button.dart';
import 'package:kakeibo/view/atom/previous_arrow_button.dart';
import 'package:kakeibo/view/molecule/calendar_month_display.dart';
import 'package:kakeibo/view/organism/calendar/calendar_area.dart';
import 'package:kakeibo/view/organism/expense_history_list_area/expence_history_list_area.dart';

import 'package:kakeibo/view_model/reference_day_impl.dart';
import 'package:kakeibo/view_model/provider/selected_datetime/selected_datetime.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // ヘッダー
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
          //左矢印ボタン、押すと前の月に移動
          const CalendarPreviousArrowButton(),
          Consumer(builder: (context, ref, _) {
            final activeDt = ref.watch(selectedDatetimeNotifierProvider);
            final label = labelGetter(activeDt);
            return CalendarMonthDisplay(label: label);
          }),
          const CalendarNextArrowButton(),
        ]),
      ),

      // 本文
      backgroundColor: MyColors.secondarySystemBackground,
      body: Center(
        child: Column(children: [
          CalendarArea(),
          ExpenceHistoryArea(),
        ]),
      ),
    );
  }
}
