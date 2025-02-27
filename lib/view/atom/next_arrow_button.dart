import 'package:flutter/material.dart';

import 'package:kakeibo/constant/colors.dart';

class NextArrowButton extends StatelessWidget {
  const NextArrowButton({required this.function, super.key});
  final Function function;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => function.call(),
      iconSize: 15,
      icon: const Icon(Icons.arrow_forward_ios_rounded),
      color: MyColors.white,
    );
  }
}
