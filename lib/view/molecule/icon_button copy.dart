import 'package:flutter/material.dart';

import 'package:kakeibo/constant/colors.dart';

class CheckBox extends StatelessWidget {
  const CheckBox({required this.isChecked, super.key});
  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return isChecked == true
        ? Container(
            height: 23,
            width: 23,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: MyColors.themeColor,
            ),
            child: const Icon(
              Icons.done_rounded,
              size: 19,
              color: MyColors.label,
            ),
          )
        : Container(
            height: 23,
            width: 23,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: MyColors.secondarySystemfill),
              color: Colors.transparent,
            ),
          );
  }
}
