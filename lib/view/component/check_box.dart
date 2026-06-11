import 'package:flutter/material.dart';

import 'package:kakeibo/theme/app_colors.dart';

class CheckBox extends StatelessWidget {
  const CheckBox({required this.isChecked, super.key});
  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return isChecked == true
        ? Container(
            height: 23,
            width: 23,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.primary,
            ),
            child: Icon(
              Icons.done_rounded,
              size: 19,
              color: context.colors.text,
            ),
          )
        : Container(
            height: 23,
            width: 23,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.fillSecondary),
              color: Colors.transparent,
            ),
          );
  }
}
