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
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final BorderRadius? borderRadius;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.transparent,
      borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(12)),
      child: InkWell(
        borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(12)),
        splashColor: Colors.transparent,
        highlightColor: highlightColor ?? Colors.black.withOpacity(0.1),
        onTap: onTap,
        onLongPress: onLongPress,
        child: child,
      ),
    );
  }
}