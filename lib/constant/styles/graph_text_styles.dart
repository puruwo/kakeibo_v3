import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_type_scale.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// ============================================================================
/// 予測グラフ・生活収支グラフ専用の役割スタイル
/// 値は AppTypeScale の段を参照する。新しいスタイルは AppTextStyles に置く（画面専用クラスは新設しない）
/// ============================================================================
class GraphTextStyles {
  GraphTextStyles._();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // グラフ本体のラベル
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// 軸ラベルの和文部分（「収入」「予算」「予測」「日別」）
  static final TextStyle graphLabel = AppTypeScale.noto12w500.copyWith(
    color: AppColorsDark.textSecondary,
  );

  /// 軸ラベルの金額部分・X軸の日付
  static final TextStyle graphPriceLabel = AppTypeScale.sfUi14w500.copyWith(
    color: AppColorsDark.textSecondary,
  );

  /// 生活収支グラフの小さな数値ラベル（月「8月」・金額・Y軸目盛り「300万」）
  static final TextStyle graphMiniLabel = AppTypeScale.sfUi11w500.copyWith(
    color: AppColorsDark.textSecondary,
  );

  /// 生活収支グラフの当月ラベル（強調）
  static final TextStyle graphMiniLabelEmphasis = AppTypeScale.sfUi11w700
      .copyWith(color: AppColorsDark.text);

  /// 生活収支グラフの小さな和文ラベル（「収支」）
  static final TextStyle graphMiniTextLabel = AppTypeScale.noto11w500.copyWith(
    color: AppColorsDark.textSecondary,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ツールチップ
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// ツールチップの日付（例: 12/29）
  static final TextStyle tooltipDate = AppTypeScale.sfUi14w700.copyWith(
    color: AppColorsDark.text,
  );

  /// ツールチップの累計金額（例: ¥12,345）
  static final TextStyle tooltipSubtitle = AppTypeScale.sfUi13w600.copyWith(
    color: AppColorsDark.text,
  );

  /// ツールチップのカテゴリー金額（例: ¥1,234）
  static final TextStyle tooltipCategory = AppTypeScale.sfUi12w700.copyWith(
    color: AppColorsDark.text,
  );

  /// ツールチップの補助ラベル（「累計」など）
  static final TextStyle tooltipCumulativeLabel = AppTypeScale.noto10w400
      .copyWith(color: AppColorsDark.textSecondary);
}
