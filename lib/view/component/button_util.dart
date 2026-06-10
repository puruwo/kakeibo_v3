import 'package:flutter/material.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';

enum ButtonColorType { main, secondary }

extension ButtonColorTypeColor on ButtonColorType {
  /// 種別に対応する色を context のテーマから解決する。
  Color resolveColor(BuildContext context) => switch (this) {
        ButtonColorType.main => context.colors.primary,
        ButtonColorType.secondary => context.colors.fill,
      };
}

class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    this.buttonColor,
    this.disabledButtonColor,
    this.buttonType = ButtonColorType.main,
    this.icon,
    required this.onPressed,
    required this.buttonText,
  });

  final ButtonColorType buttonType;
  final Function()? onPressed;
  final String buttonText;
  final Color? buttonColor;
  final Color? disabledButtonColor;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = buttonColor ?? buttonType.resolveColor(context);
    final textStyle = buttonType == ButtonColorType.main
        ? AppTextStyles.mainButtonText
        : AppTextStyles.secondaryButtonText;

    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor:
              Color.alphaBlend(context.colors.overlay, backgroundColor),
          elevation: 0,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon!,
                    const SizedBox(width: 6),
                    Text(buttonText, style: textStyle),
                  ],
                )
              : Text(buttonText, style: textStyle),
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
          backgroundColor: buttonType.resolveColor(context),
          elevation: 0,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            buttonText,
            style: buttonType == ButtonColorType.main
                ? AppTextStyles.mainButtonText
                : AppTextStyles.secondaryButtonText,
          ),
        ),
      ),
    );
  }
}
