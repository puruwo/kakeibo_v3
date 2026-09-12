import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_type_scale.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// ============================================================================
/// 予測グラフ・生活収支グラフ専用の役割スタイル
/// 値は AppTypeScale の段を参照する。新しいスタイルは AppTextStyles に置く（画面専用クラスは新設しない）
/// ============================================================================
class GraphTextStyles {
  /// [colors] は現在のテーマの色トークン。通常は `context.graphStyles` 経由で受け取る
  const GraphTextStyles(this.colors);

  /// 役割スタイルの色の出どころ（ライト／ダークで値が変わる）
  final AppColors colors;

  /// context 無しに使う固定インスタンス（テストの期待値・Painter への注入元）
  static const GraphTextStyles light = GraphTextStyles(AppColors.light);
  static const GraphTextStyles dark = GraphTextStyles(AppColors.dark);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // グラフ本体のラベル
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// 軸ラベルの和文部分（「収入」「予算」「予測」「日別」）
  TextStyle get graphLabel =>
      AppTypeScale.noto12w500.copyWith(color: colors.textSecondary);

  /// 軸ラベルの金額部分・X軸の日付
  TextStyle get graphPriceLabel =>
      AppTypeScale.sfUi14w500.copyWith(color: colors.textSecondary);

  /// 生活収支グラフの小さな数値ラベル（月「8月」・金額・Y軸目盛り「300万」）
  TextStyle get graphMiniLabel =>
      AppTypeScale.sfUi11w500.copyWith(color: colors.textSecondary);

  /// 生活収支グラフの当月ラベル（強調）
  TextStyle get graphMiniLabelEmphasis =>
      AppTypeScale.sfUi11w700.copyWith(color: colors.text);

  /// 生活収支グラフの小さな和文ラベル（「収支」）
  TextStyle get graphMiniTextLabel =>
      AppTypeScale.noto11w500.copyWith(color: colors.textSecondary);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ツールチップ
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// ツールチップの日付（例: 12/29）
  TextStyle get tooltipDate =>
      AppTypeScale.sfUi14w700.copyWith(color: colors.text);

  /// ツールチップの累計金額（例: ¥12,345）
  TextStyle get tooltipSubtitle =>
      AppTypeScale.sfUi13w600.copyWith(color: colors.text);

  /// ツールチップのカテゴリー金額（例: ¥1,234）
  TextStyle get tooltipCategory =>
      AppTypeScale.sfUi12w700.copyWith(color: colors.text);

  /// ツールチップの補助ラベル（「累計」など）
  TextStyle get tooltipCumulativeLabel =>
      AppTypeScale.noto10w400.copyWith(color: colors.textSecondary);
}

/// BuildContext から現在のテーマのグラフ専用の役割スタイルを取る（KP-013）
extension GraphTextStylesX on BuildContext {
  GraphTextStyles get graphStyles => GraphTextStyles(colors);
}
