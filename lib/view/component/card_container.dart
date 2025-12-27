import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';

/// アプリ共通のカードコンテナ
///
/// 背景色: MyColors.quarternarySystemfill
/// 角丸: 18px
///
/// Containerの代用として使用可能。decorationは固定で、
/// それ以外のContainerプロパティはすべて指定可能です。
class CardContainer extends StatelessWidget {
  const CardContainer({
    super.key,
    this.alignment,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.foregroundDecoration,
    this.transform,
    this.transformAlignment,
    this.clipBehavior = Clip.none,
    this.child,
  });

  /// コンテナ内の配置
  final AlignmentGeometry? alignment;

  /// コンテナ内のパディング
  final EdgeInsetsGeometry? padding;

  /// コンテナ外のマージン
  final EdgeInsetsGeometry? margin;

  /// コンテナの幅
  final double? width;

  /// コンテナの高さ
  final double? height;

  /// サイズ制約
  final BoxConstraints? constraints;

  /// 前景装飾
  final Decoration? foregroundDecoration;

  /// 変形行列
  final Matrix4? transform;

  /// 変形の原点
  final AlignmentGeometry? transformAlignment;

  /// クリップ動作
  final Clip clipBehavior;

  /// コンテナ内のウィジェット
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      constraints: constraints,
      foregroundDecoration: foregroundDecoration,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: MyColors.quarternarySystemfill,
        borderRadius: appCardRadius,
      ),
      child: child,
    );
  }
}

BorderRadius get appCardRadius => BorderRadius.circular(18);
