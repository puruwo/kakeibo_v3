import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/selected_datetime/analyze_page_selected_datetime.dart';

class PreviousArrowButton extends ConsumerWidget {
  const PreviousArrowButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () async {
        ref.read(analyzePageSelectedDatetimeNotifierProvider.notifier).updateToPreviousMonth();
      },
      iconSize: 15,
      icon: const Icon(Icons.arrow_back_ios_rounded),
      color: MyColors.white,
    );
  }
}
