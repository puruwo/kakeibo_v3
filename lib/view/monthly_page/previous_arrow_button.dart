import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view_model/state/date_scope/selected_datetime/selected_datetime.dart';
import 'package:kakeibo/view_model/state/page_manager/page_manager.dart';


class PreviousArrowButton extends ConsumerWidget {
  const PreviousArrowButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () async {
        // selectedDatetimeとpageManagerNotifierProviderを更新する
        ref.read(pageManagerNotifierProvider.notifier).previousPage();
        ref.read(selectedDatetimeNotifierProvider.notifier).updateToPreviousMonth();
      },
      iconSize: 15,
      icon: const Icon(Icons.arrow_back_ios_rounded),
      color: MyColors.white,
    );
  }
}
