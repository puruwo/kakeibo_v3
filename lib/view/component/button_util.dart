import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';

enum ButtonType {
  main(MyColors.buttonPrimary),
  secondary(MyColors.buttonSecondary);

  final Color color;

  const ButtonType(this.color);
}

class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    this.buttonType = ButtonType.main,
    required this.onPressed,
    required this.buttonText,
  });

  final ButtonType buttonType;
  final Function()? onPressed;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonType.color,
      ),
      child: Text(
        buttonText,
        style: buttonType == ButtonType.main
            ? MyFonts.mainButtonText
            : MyFonts.secondaryButtonText,
      ),
    );
  }
}
