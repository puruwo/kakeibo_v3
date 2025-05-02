import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/home/calendar_next_arrow_button.dart';
import 'package:kakeibo/view/home/calendar_previous_arrow_button.dart';

import 'package:kakeibo/view/home/calendar/calendar_area.dart';
import 'package:kakeibo/view/home/expense_history/expence_history_list_area.dart';

import 'package:kakeibo/view_model/state/date_scope/selected_datetime/selected_datetime.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ヘッダー
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //左矢印ボタン、押すと前の月に移動
              const CalendarPreviousArrowButton(),
              Consumer(builder: (context, ref, _) {
                final activeDt = ref.watch(selectedDatetimeNotifierProvider);
                final label = labelGetter(activeDt);
                return Text(label,
                    style: const TextStyle(color: MyColors.white, fontSize: 20));
              }),
              const CalendarNextArrowButton(),
            ]),
      ),

      // 本文
      backgroundColor: MyColors.secondarySystemBackground,
      body: Center(
        child: Column(children: [
          const CalendarArea(),
          ExpenceHistoryArea(),
        ]),
      ),
    );
  }
}
