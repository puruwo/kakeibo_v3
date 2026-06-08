import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// リキッドグラス風の半透明ブラー背景を持つAppBar用背景ウィジェット
/// AppBarのflexibleSpaceに設定して使用する
class GlassAppBarBackground extends StatelessWidget {
  const GlassAppBarBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          color: context.colors.surfaceElevated.withOpacity(0.7),
        ),
      ),
    );
  }
}
