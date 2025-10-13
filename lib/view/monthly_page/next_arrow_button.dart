import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/selected_datetime/analyze_page_selected_datetime.dart';

class NextArrowButton extends ConsumerWidget {
  const NextArrowButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () async {
        ref.read(analyzePageSelectedDatetimeNotifierProvider.notifier).updateToNextMonth();
      },
      iconSize: 15,
      icon: const Icon(Icons.arrow_forward_ios_rounded),
      color: MyColors.white,
    );
  }
}
