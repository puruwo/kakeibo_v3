import 'package:flutter/material.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/register_page/common_input_field/const_getter.dart/const_input_page_size_getter.dart';

/// 入力ページ共通のピル型コンテナ
///
/// 背景色: MyColors.secondarySystemfill
/// 角丸: 50px（ピル形状）
/// 高さ: InputPageWidgetSize.pillHeight
/// ADR-017 #1: カードと同じ極薄境界線を付ける。ピルは高さが小さくグラデーションだと
/// バンディングして見えるため、境界線のみでカードと差をつける。
class AppPillContainer extends StatelessWidget {
  const AppPillContainer({
    super.key,
    this.width,
    this.padding,
    this.child,
  });

  final double? width;
  final EdgeInsetsGeometry? padding;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: InputPageWidgetSize.pillHeight,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: context.colors.fillSecondary,
        border: Border.all(color: context.colors.surfaceBorder, width: 1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: child,
    );
  }
}
