import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view/config/config_top.dart';
import 'package:kakeibo/view/historical_calendar_page/calendar_area/calendar_area.dart';
import 'package:kakeibo/view/historical_calendar_page/calendar_next_arrow_button.dart';
import 'package:kakeibo/view/historical_calendar_page/calendar_previous_arrow_button.dart';
import 'package:kakeibo/view/historical_calendar_page/expense_history_area/expence_history_list_area.dart';
import 'package:kakeibo/view_model/state/date_scope/historical_page/historical_date_scope.dart';

class ExpenseHistoryPage extends StatelessWidget {
  const ExpenseHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ヘッダー
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Stack(children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //左矢印ボタン、押すと前の月に移動
                const CalendarPreviousArrowButton(),
                Consumer(builder: (context, ref, _) {
                  final dateScopeAsync =
                      ref.watch(historicalDateScopeEntityProvider);
                  final selectedDate = dateScopeAsync.whenOrNull(
                      data: (data) => data.selectedDate);
                  final label = selectedDate != null
                      ? '${selectedDate.year}年 ${selectedDate.month}月'
                      : '';
                  return Text(
                    label,
                    style: AppTextStyles.pageHeaderText,
                  );
                }),
                //右矢印ボタン、押すと次の月に移動
                const CalendarNextArrowButton(),
              ]),
          Positioned(
            right: 0,
            child: IconButton(
                onPressed: () => {
                      // 設定画面にrootのNavigatorで遷移
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => const ConfigTop(),
                        ),
                      )
                    },
                icon: const Icon(Icons.settings_rounded)),
          )
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
