import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';

enum ButtonColorType {
  main(MyColors.buttonPrimary),
  secondary(MyColors.buttonSecondary);

  final Color color;

  const ButtonColorType(this.color);
}

class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    this.buttonColor,
    this.buttonType = ButtonColorType.main,
    required this.onPressed,
    required this.buttonText,
  });

  final ButtonColorType buttonType;
  final Function()? onPressed;
  final String buttonText;
  final Color? buttonColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor ?? buttonType.color,
          elevation: 0,
        ),
        child: Text(
          buttonText,
          style: buttonType == ButtonColorType.main
              ? AppTextStyles.mainButtonText
              : AppTextStyles.secondaryButtonText,
        ),
      ),
    );
  }
}

class SubButton extends StatelessWidget {
  const SubButton({
    super.key,
    this.buttonType = ButtonColorType.main,
    required this.onPressed,
    required this.buttonText,
  });

  final ButtonColorType buttonType;
  final Function()? onPressed;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonType.color,
          elevation: 0,
        ),
        child: Text(
          buttonText,
          style: buttonType == ButtonColorType.main
              ? AppTextStyles.mainButtonText
              : AppTextStyles.secondaryButtonText,
        ),
      ),
    );
  }
}
