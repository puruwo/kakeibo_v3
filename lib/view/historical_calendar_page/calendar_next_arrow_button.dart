import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view_model/state/calendar_page/page_controller/calendar_page_controller.dart';

class CalendarNextArrowButton extends ConsumerWidget {
  const CalendarNextArrowButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () async {
        // selectedDatetimeの更新はonPageChanged内でselectedDatetimeを更新する
        ref.read(calendarPageControllerNotifierProvider.notifier).nextPage();
      },
      iconSize: 15,
      icon: const Icon(Icons.arrow_forward_ios_rounded),
      color: MyColors.white,
    );
  }
}
