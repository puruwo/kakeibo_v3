import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view_model/provider/calendar_page_controller/calendar_page_controller.dart';

class PreviousArrowButton extends ConsumerWidget {
  const PreviousArrowButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () async {
        // selectedDatetimeを更新するのではなく、calendarPageControllerを更新する
        // onPageChanged内でselectedDatetimeを更新する
        ref.read(calendarPageControllerNotifierProvider.notifier).previousPage();
      },
      iconSize: 15,
      icon: const Icon(Icons.arrow_back_ios_rounded),
      color: MyColors.white,
    );
  }
}
