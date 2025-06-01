import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view_model/state/date_scope/selected_datetime/selected_datetime.dart';
import 'package:kakeibo/view_model/state/page_manager/page_manager.dart';

class NextArrowButton extends ConsumerWidget {
  const NextArrowButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () async {
        // selectedDatetimeを更新するだけでなく、pageManagerNotifierProviderを更新する
        ref.read(pageManagerNotifierProvider.notifier).nextPage();
        ref.read(selectedDatetimeNotifierProvider.notifier).updateToNextMonth();
      },
      iconSize: 15,
      icon: const Icon(Icons.arrow_forward_ios_rounded),
      color: MyColors.white,
    );
  }
}
