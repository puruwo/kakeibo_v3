import 'package:flutter/material.dart';

class AppInkWell extends StatelessWidget {
  const AppInkWell({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.color,
    this.borderRadius,
    this.highlightColor,
    this.border,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final BorderRadius? borderRadius;
  final Color? highlightColor;

  /// ADR-017: `color`を塗る「カード/行」として使う場合の境界線。
  /// MaterialはBoxDecoration.borderを持てないため、指定時は外側にborderだけの
  /// Containerを重ねる（未指定なら従来通りMaterialのみ、見た目は変わらない）。
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final resolvedRadius =
        borderRadius ?? const BorderRadius.all(Radius.circular(12));

    final material = Material(
      color: color ?? Colors.transparent,
      borderRadius: resolvedRadius,
      child: InkWell(
        borderRadius: resolvedRadius,
        splashColor: Colors.transparent,
        highlightColor: highlightColor ?? Colors.black.withOpacity(0.1),
        onTap: onTap,
        onLongPress: onLongPress,
        child: child,
      ),
    );

    if (border == null) return material;

    return Container(
      decoration: BoxDecoration(border: border, borderRadius: resolvedRadius),
      child: material,
    );
  }
}
