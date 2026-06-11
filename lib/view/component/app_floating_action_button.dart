import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// 汎用フローティングアクションボタン。
/// [label] を指定すると Extended（pill 形）、省略すると円形になる。
/// 背景色・前景色は引数で上書き可。既定は [MyColors.themeColor] / 白。
class AppFloatingActionButton extends StatelessWidget {
  const AppFloatingActionButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  final VoidCallback onTap;
  final IconData icon;

  /// ラベル文字列。null なら円形 FAB、指定で Extended（pill）FAB になる。
  final String? label;

  /// ボタン背景色。省略時は [MyColors.themeColor]。
  final Color? backgroundColor;

  /// アイコン・ラベルの前景色。省略時は白。
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? context.colors.primary;
    final fgColor = foregroundColor ?? Colors.white;
    final hasLabel = label != null;

    return Material(
      elevation: 6,
      shape: hasLabel ? const StadiumBorder() : const CircleBorder(),
      color: bgColor,
      child: InkWell(
        customBorder: hasLabel ? const StadiumBorder() : const CircleBorder(),
        splashColor: Colors.transparent,
        highlightColor: Colors.black.withValues(alpha: 0.1),
        onTap: onTap,
        child: hasLabel
            ? SizedBox(
                height: 46,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: fgColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        label!,
                        style: AppTextStyles.mainButtonText.copyWith(
                          color: fgColor,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox(
                width: 56,
                height: 46,
                child: Center(
                  child: Icon(icon, color: fgColor, size: 24),
                ),
              ),
      ),
    );
  }
}
