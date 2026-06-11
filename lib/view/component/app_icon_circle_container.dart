import 'package:flutter/material.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// アイコンボタン背景用の円形コンテナ
///
/// shape: BoxShape.circle で色をパラメータで指定する
class AppIconCircleContainer extends StatelessWidget {
  const AppIconCircleContainer({
    super.key,
    this.color,
    this.size,
    this.child,
  });

  final Color? color;
  final double? size;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color ?? context.colors.fillSecondary,
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}
