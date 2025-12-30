import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';

/// 予測グラフで使用するテキストスタイル定義
class PredictionGraphTextStyles {
  PredictionGraphTextStyles._();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // グラフ本体のラベル
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// グラフ軸ラベル（「￥0」「日別」「収入」「予算」「予測」）
  static const graphLabel = TextStyle(
    fontSize: 12,
    color: MyColors.secondaryLabel,
    fontFamily: 'sf_ui',
  );

  /// グラフ金額ラベル（収入・予算・予測の金額部分、X軸日付）
  static const graphPriceLabel = TextStyle(
    fontSize: 14,
    color: MyColors.secondaryLabel,
    fontFamily: 'sf_ui',
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // グラフエリアのメッセージ
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// 空状態・エラーメッセージ
  static const message = TextStyle(
    color: MyColors.secondaryLabel,
    fontSize: 16,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ツールチップ
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// ツールチップ日付（例: 12/29）
  static const tooltipDate = TextStyle(
    fontSize: 14,
    color: MyColors.label,
  );

  /// ツールチップ累計金額（例: ¥12,345）
  static const tooltipSubtitle = TextStyle(
    fontSize: 14,
    color: MyColors.label,
  );

  /// ツールチップカテゴリー金額（例: ¥1,234）
  static const tooltipCategory = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: MyColors.label,
  );

  /// ツールチップ補助ラベル（「累計」「固定費」など小さめのラベル）
  static const tooltipCumulativeLabel = TextStyle(
    fontSize: 10,
    color: MyColors.secondaryLabel,
  );
}
