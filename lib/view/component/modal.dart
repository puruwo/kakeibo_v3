import 'package:flutter/material.dart';

Future<void> showModalBottomSheetFunc(BuildContext context, Widget page) async {
    showModalBottomSheet(
      //sccafoldの上に出すか
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(
        maxWidth: 2000,
      ),
      context: context,
      builder: (context) {
        return page;
      },
    );
  }