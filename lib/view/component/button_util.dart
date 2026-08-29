import 'package:flutter/material.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/component/app_icon_circle_container.dart';
import 'package:kakeibo/view/component/card_container.dart';

/// ADR-016で定義したボタンの語彙。
/// main=Primary（主要アクション）／secondary=Secondary（副次アクション）／
/// danger=Destructive（不可逆操作）。Icon-onlyは[IconOnlyButton]を使う。
enum ButtonColorType { main, secondary, danger }

/// 案件 UIデザイン改修 §1: StadiumBorderを廃止し、カード語彙（角丸+1px枠+微グラデ）に統一する。
BorderRadius get kButtonRadius => BorderRadius.circular(12);

/// Tint地のアルファ。primaryTintトークン（primary 16%）と同値。
/// danger・buttonColor指定時のアクセント色にも同じ比率でTint地を作る。
const double _kTintAlpha = 0.16;

/// ボタン1種の見た目（地・枠・文字色）の解決結果
class _ButtonSpec {
  const _ButtonSpec({
    required this.background,
    required this.borderColor,
    required this.labelColor,
  });

  final Color background;
  final Color borderColor;
  final Color labelColor;
}

/// 種別・上書き色からボタンの見た目を解決する（案件 UIデザイン改修 §1）。
/// - main: primaryTint地 + primary枠 + primary文字
/// - secondary: fillQuaternary地 + surfaceBorder枠 + text文字
/// - danger: dangerのTint地 + danger枠 + danger文字
/// - buttonColor指定時: その色をアクセントとしてTint語彙を適用（入力モード色のSubmitButton用）
_ButtonSpec _resolveButtonSpec(
  BuildContext context,
  ButtonColorType type, {
  Color? buttonColor,
  Color? textColor,
}) {
  final colors = context.colors;

  if (buttonColor != null) {
    return _ButtonSpec(
      background: buttonColor.withValues(alpha: _kTintAlpha),
      borderColor: buttonColor,
      labelColor: textColor ?? buttonColor,
    );
  }

  return switch (type) {
    ButtonColorType.main => _ButtonSpec(
        background: colors.primaryTint,
        borderColor: colors.primary,
        labelColor: textColor ?? colors.primary,
      ),
    ButtonColorType.secondary => _ButtonSpec(
        background: colors.fillQuaternary,
        borderColor: colors.surfaceBorder,
        labelColor: textColor ?? colors.text,
      ),
    ButtonColorType.danger => _ButtonSpec(
        background: colors.danger.withValues(alpha: _kTintAlpha),
        borderColor: colors.danger,
        labelColor: textColor ?? colors.danger,
      ),
  };
}

/// Tint地+1px枠+微グラデの共通ボタン面。
/// グラデはCardContainer（ADR-017 #1）と同じ「左上からの控えめなハイライト」
/// （[resolveSurfaceHighlight]を共有）。
class _ButtonSurface extends StatelessWidget {
  const _ButtonSurface({
    required this.height,
    required this.spec,
    required this.enabled,
    required this.onPressed,
    required this.child,
  });

  final double height;
  final _ButtonSpec spec;
  final bool enabled;
  final Function()? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // 非活性時: 地はoverlay合成で沈め、枠も減衰させる（Tint語彙は枠と文字が
    // 支配的なため、地の変化だけでは非活性が伝わらない。文字色は呼び出し側で減衰）
    final background = enabled
        ? spec.background
        : Color.alphaBlend(context.colors.overlay, spec.background);
    final borderColor = enabled ? spec.borderColor : context.colors.disabled;
    final highlightColor = resolveSurfaceHighlight(context, background);

    // ElevatedButtonから置き換えたため、ボタンとしてのSemanticsを明示的に付与する
    return Semantics(
      button: true,
      enabled: enabled,
      child: SizedBox(
        height: height,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [highlightColor, background],
              stops: const [0.0, 1.0],
            ),
            border: Border.all(color: borderColor, width: 1),
            borderRadius: kButtonRadius,
          ),
          child: AppInkWell(
            borderRadius: kButtonRadius,
            onTap: enabled ? () => onPressed!() : null,
            // widthFactor: 1 で幅は内容にフィットさせる（OverflowBar等の緩い制約下で
            // 全幅に広がらないように）。Expanded・width: infinity のタイト制約下では全幅になる
            child: Center(
              widthFactor: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FittedBox(fit: BoxFit.scaleDown, child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    this.buttonColor,
    this.buttonType = ButtonColorType.main,
    this.icon,
    this.textColor,
    required this.onPressed,
    required this.buttonText,
  });

  final ButtonColorType buttonType;
  final Function()? onPressed;
  final String buttonText;

  /// アクセント色の上書き。指定時はこの色でTint語彙（Tint地+枠+文字）を組む（仕様 §1）
  final Color? buttonColor;
  final Widget? icon;

  /// ラベルの文字色。secondary背景にdanger文字を載せる削除ボタン用（仕様 §6.7）
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final spec = _resolveButtonSpec(
      context,
      buttonType,
      buttonColor: buttonColor,
      textColor: textColor,
    );
    // ADR-017 #4: secondaryButtonTextはmainButtonTextと同値だったため統合（種別によらず同一スタイル）
    final textStyle = AppTextStyles.mainButtonText.copyWith(
      color: enabled ? spec.labelColor : context.colors.textTertiary,
    );

    return _ButtonSurface(
      height: 40,
      spec: spec,
      enabled: enabled,
      onPressed: onPressed,
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
    final enabled = onPressed != null;
    final spec = _resolveButtonSpec(context, buttonType);

    return _ButtonSurface(
      height: 30,
      spec: spec,
      enabled: enabled,
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: AppTextStyles.mainButtonText.copyWith(
          color: enabled ? spec.labelColor : context.colors.textTertiary,
        ),
      ),
    );
  }
}

/// ADR-016: Icon-only（ラベル無しの補助アクション）。
/// 円・46px固定（[size]は塗りの直径。ADR-017の境界線1pxが外側に付くため外形は48px。
/// 内側46px＋境界線1pxは、かつて隣に並べていたナビゲーション行と同寸にした名残（KP-004で同行は削除済み））。
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
    // ADR-017: 他のカード・行と同じ境界線を出し、面としての格を揃える。
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
