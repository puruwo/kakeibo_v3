import 'package:flutter/material.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// アプリ共通のカードコンテナ
///
/// 背景色: MyColors.quarternarySystemfill
/// 角丸: 18px
/// ADR-017 #1: 極薄境界線＋上から光が当たるような微細なグラデーションハイライトで
/// 背景（surface）との奥行きを出す。
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
    final baseColor = context.colors.fillQuaternary;
    final highlightColor = resolveSurfaceHighlight(context, baseColor);

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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [highlightColor, baseColor],
          stops: const [0.0, 1.0],
        ),
        border: Border.all(color: context.colors.surfaceBorder, width: 1),
        borderRadius: appCardRadius,
      ),
      child: child,
    );
  }
}

BorderRadius get appCardRadius => BorderRadius.circular(18);

/// 一覧行カード（AppListCard・月間分析のカテゴリーカード）の角丸。
/// KP-004: 面カード（CardContainer, 18px）より一回り小さく、ボタン（kButtonRadius）と同じ12pxに揃える。
BorderRadius get appListCardRadius => BorderRadius.circular(12);

/// ADR-017 #1（実機フィードバックにより調整）: 面のグラデハイライトの開始色。
/// ハイライトは控えめに、縦ではなく斜め（左上→右下）に乗せる。stopsは面全体
/// （0.0〜1.0）に引き伸ばし、背の高いカードでも途中に遷移の境界線が見えないようにする。
/// カード（[CardContainer]）とボタン（button_util.dart）で同じ質感を共有するための単一定義。
Color resolveSurfaceHighlight(BuildContext context, Color base) {
  return Color.alphaBlend(
    context.colors.surfaceBorder.withValues(alpha: 0.035),
    base,
  );
}
