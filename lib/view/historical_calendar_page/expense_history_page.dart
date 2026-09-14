import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/view/component/app_period_header.dart';
import 'package:kakeibo/view/component/app_year_month_picker.dart';
import 'package:kakeibo/view/config/config_top.dart';
import 'package:kakeibo/view/historical_calendar_page/calendar_area/calendar_area.dart';
import 'package:kakeibo/view/historical_calendar_page/expense_history_area/expence_history_list_area.dart';
import 'package:kakeibo/view_model/state/calendar_page/page_controller/calendar_page_controller.dart';
import 'package:kakeibo/view_model/state/date_scope/historical_page/selected_datetime/historical_selected_datetime.dart';
import 'package:kakeibo/constant/icon.dart';

class ExpenseHistoryPage extends StatelessWidget {
  const ExpenseHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ヘッダー
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        // 歯車（actions 48）と同じ幅を左にも取り、期間ヘッダーを画面中央に置く（KP-025）
        leading: const SizedBox.shrink(),
        leadingWidth: 48,
        titleSpacing: 0,
        // 地は透明のまま（ガラスの帯を敷くと本文との境界が出るため。KP-025 ユーザーレビュー）
        title: Consumer(
          builder: (context, ref, _) {
            // 同期プロバイダーを使用して、ローディング中の表示崩れを防止
            final selectedDate = ref.watch(
              historicalSelectedDatetimeNotifierProvider,
            );
            final canPrevious = canShiftPeriodMonth(
              year: selectedDate.year,
              month: selectedDate.month,
              delta: -1,
            );
            final canNext = canShiftPeriodMonth(
              year: selectedDate.year,
              month: selectedDate.month,
              delta: 1,
            );
            // 月の更新は CalendarArea の onPageChanged で行う（ページ移動に追従させる）
            return AppPeriodHeader(
              label: '${selectedDate.year}年 ${selectedDate.month}月',
              onTapLabel: () async {
                final picked = await showAppYearMonthPicker(
                  context: context,
                  mode: AppYearMonthPickerMode.calendarMonth,
                  initialDateTime: selectedDate,
                );
                if (picked == null) return;
                ref
                    .read(calendarPageControllerNotifierProvider.notifier)
                    .jumpToMonth(picked);
              },
              onPrevious: canPrevious
                  ? () => ref
                      .read(calendarPageControllerNotifierProvider.notifier)
                      .previousPage()
                  : null,
              onNext: canNext
                  ? () => ref
                      .read(calendarPageControllerNotifierProvider.notifier)
                      .nextPage()
                  : null,
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () => {
              // 設定画面にrootのNavigatorで遷移
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (context) => const ConfigTop()),
              ),
            },
            icon: const Icon(AppIcons.settings),
          ),
        ],
      ),

      // 本文（地は AppTheme の scaffoldBackgroundColor（surface）。KP-013）
      body: Column(children: [const CalendarArea(), ExpenceHistoryArea()]),
    );
  }
}
