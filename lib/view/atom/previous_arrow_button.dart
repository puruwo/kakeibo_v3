import 'package:flutter/material.dart';

import 'package:kakeibo/constant/colors.dart';

class PreviousArrowButton extends StatelessWidget {
  const PreviousArrowButton({required this.function, super.key});
  final Function function;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await function.call();
      },
      iconSize: 15,
      icon: const Icon(Icons.arrow_back_ios_rounded),
      color: MyColors.white,
    );
  }
}
