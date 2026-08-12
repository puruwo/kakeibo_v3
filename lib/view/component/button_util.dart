import 'package:flutter/material.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/component/app_icon_circle_container.dart';

/// ADR-016で定義したボタンの語彙。
/// main=Primary（主要アクション）／secondary=Secondary（副次アクション）／
/// danger=Destructive（不可逆操作）。Icon-onlyは[IconOnlyButton]を使う。
enum ButtonColorType { main, secondary, danger }

extension ButtonColorTypeColor on ButtonColorType {
  /// 種別に対応する色を context のテーマから解決する。
  Color resolveColor(BuildContext context) => switch (this) {
        ButtonColorType.main => context.colors.primary,
        ButtonColorType.secondary => context.colors.fillSecondary,
        ButtonColorType.danger => context.colors.danger,
      };
}

/// ADR-016: Primary/Secondary/DestructiveはPrimaryと同じピル形状（StadiumBorder）で統一する。
const kButtonShape = StadiumBorder();

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
    final textStyle = buttonType == ButtonColorType.secondary
        ? AppTextStyles.secondaryButtonText
        : AppTextStyles.mainButtonText;

    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor:
              Color.alphaBlend(context.colors.overlay, backgroundColor),
          elevation: 0,
          shape: kButtonShape,
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
          shape: kButtonShape,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            buttonText,
            style: buttonType == ButtonColorType.secondary
                ? AppTextStyles.secondaryButtonText
                : AppTextStyles.mainButtonText,
          ),
        ),
      ),
    );
  }
}

/// ADR-016: Icon-only（ラベル無しの補助アクション）。
/// 円・46px固定（[size]は塗りの直径。ADR-017の境界線1pxが外側に付くため外形は48px。
/// これは[AppNavigationListTile]（内側46px＋境界線1px）と同じ寸法で、横に並べると高さが揃う）。
/// 既存の[AppIconCircleContainer]を経由し、独自にContainerを組まない。
/// 定義上「主役になれない」——主要導線と同格の重要度が必要な場合はIcon-onlyではなく
/// [MainButton]かナビゲーション行を使うこと。
class IconOnlyButton extends StatelessWidget {
  const IconOnlyButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.size = 46,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    // ADR-017: 隣に並ぶナビゲーション行（[AppNavigationListTile]）と同じ境界線を出し、
    // 面としての格を揃える。
    // [AppInkWell]のborderは角丸（borderRadius）で枠を描くため、border込みの外形48pxに
    // 半径23が当たって真円にならない（各辺の中央に直線が残る）。Icon-onlyは円が要件
    // （ADR-016）なので、shape: BoxShape.circle の外枠を直接重ねる。
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.surfaceBorder, width: 1),
        shape: BoxShape.circle,
      ),
      child: AppInkWell(
        borderRadius: BorderRadius.circular(size / 2),
        onTap: onTap,
        child: AppIconCircleContainer(
          size: size,
          color: backgroundColor ?? context.colors.fillQuaternary,
          child: Icon(
            icon,
            size: size * 0.4,
            color: iconColor ?? context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
