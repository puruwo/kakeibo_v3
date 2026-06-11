import 'package:flutter/material.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/constant/font_style.dart';

/// 予測グラフで使用するテキストスタイル定義
class GraphTextStyles {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // グラフ本体のラベル
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// グラフ軸ラベル（「¥ 0」「日別」「収入」「予算」「予測」）
  static final TextStyle graphLabel = MyFontStyle.notoSans.copyWith(
      fontSize: 12,
      color: AppColorsDark.textSecondary,
      fontWeight: FontWeight.w500);

  /// グラフ金額ラベル（収入・予算・予測の金額部分、X軸日付）
  static final TextStyle graphPriceLabel = MyFontStyle.sfUi.copyWith(
      fontSize: 14,
      color: AppColorsDark.textSecondary,
      fontWeight: FontWeight.w500);

  /// グラフ金額ラベル（収入・予算・予測の金額部分、X軸日付）
  static final TextStyle graphMiniLabel = MyFontStyle.notoSans.copyWith(
      fontSize: 11,
      color: AppColorsDark.textSecondary,
      fontWeight: FontWeight.w500);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ツールチップ
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// ツールチップ日付（例: 12/29）
  static final tooltipDate = MyFontStyle.sfUi.copyWith(
    fontSize: 14,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w700,
  );

  /// ツールチップ累計金額（例: ¥12,345）
  static final tooltipSubtitle = MyFontStyle.sfUi.copyWith(
    fontSize: 13,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w600,
  );

  /// ツールチップカテゴリー金額（例: ¥1,234）
  static final tooltipCategory = MyFontStyle.sfUi.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColorsDark.text,
  );

  /// ツールチップ補助ラベル（「累計」など小さめのラベル）
  static final tooltipCumulativeLabel = MyFontStyle.notoSans.copyWith(
    fontSize: 10,
    color: AppColorsDark.textSecondary,
  );
}
