import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/util/util.dart';

import 'package:kakeibo/view/atom/next_arrow_button.dart';
import 'package:kakeibo/view/atom/previous_arrow_button.dart';
import 'package:kakeibo/view/molecule/calendar_month_display.dart';
import 'package:kakeibo/view/organism/calendar_area.dart';
import 'package:kakeibo/view/organism/expence_history_list_area.dart';

import 'package:kakeibo/view_model/provider/active_datetime.dart';
import 'package:kakeibo/view_model/reference_day_impl.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    // pageViewのコントローラ
    // 閾値：[0,1000] 初期値：500
    const initialCenter = 500;
    final pageController = PageController(initialPage: initialCenter);

    return Scaffold(
      // ヘッダー
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
          //左矢印ボタン、押すと前の月に移動
          PreviousArrowButton(function: () async {
            await pageController.previousPage(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic);
          }),
          Consumer(builder: (context, ref, _) {
            final activeDt = ref.watch(activeDatetimeNotifierProvider);
            final label = labelGetter(activeDt);
            return CalendarMonthDisplay(label: label);
          }),
          NextArrowButton(function: () async {
            await pageController.nextPage(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic);
          }),
        ]),
      ),

      // 本文
      backgroundColor: MyColors.secondarySystemBackground,
      body: Center(
        child: Column(children: [
          CalendarArea(
            pageController: pageController,
          ),
          ExpenceHistoryArea(),
        ]),
      ),
    );
  }
}
