import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view_model/state/calendar_page/page_controller/calendar_page_controller.dart';
import 'package:kakeibo/constant/icon.dart';

class CalendarPreviousArrowButton extends ConsumerWidget {
  const CalendarPreviousArrowButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () async {
        // selectedDatetimeの更新はonPageChanged内でselectedDatetimeを更新する
        ref
            .read(calendarPageControllerNotifierProvider.notifier)
            .previousPage();
      },
      // chevron は24グリッド内で小さく描かれるため、期間ピッカーと同じ24にする（KP-023）
      iconSize: 24,
      icon: const Icon(AppIcons.periodPrev),
      color: context.colors.text,
    );
  }
}
