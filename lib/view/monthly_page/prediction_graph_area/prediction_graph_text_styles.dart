import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';

/// 予測グラフで使用するテキストスタイル定義
class PredictionGraphTextStyles {
  PredictionGraphTextStyles._();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // グラフラベル（0円、日別、収入、予算、予測、X軸）
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// グラフ軸ラベル（"0円"、"日別"、"収入"、"予算"、"予測"、X軸日付）
  static const graphLabel = TextStyle(
    fontSize: 12,
    color: MyColors.secondaryLabel,
    fontFamily: 'sf_ui',
  );

  /// グラフ金額ラベル（収入金額、予算金額、予測金額）
  static const graphPriceLabel = TextStyle(
    fontSize: 14,
    color: MyColors.secondaryLabel,
    fontFamily: 'sf_ui',
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // メッセージ（エラー、空状態）
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// エラー・空状態メッセージ（「選択月の支出の入力がありません」「エラーが発生しました」）
  static const message = TextStyle(
    color: MyColors.secondaryLabel,
    fontSize: 16,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ツールチップ
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// ツールチップ日付（太字白文字）
  static const tooltipDate = TextStyle(
    fontSize: 14,
    // fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  /// ツールチップ累計支出
  static const tooltipSubtitle = TextStyle(
    fontSize: 14,
    // fontWeight: FontWeight.bold,
    color: MyColors.label,
  );

  /// ツールチップカテゴリー行（金額）
  static const tooltipCategory = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  /// ツールチップカテゴリー名（小さめ、薄め）
  static const tooltipCategoryName = TextStyle(
    fontSize: 10,
    color: Colors.white70,
  );

  /// ツールチップ累計ラベル（「累計」文字用）
  static const tooltipCumulativeLabel = TextStyle(
    fontSize: 10,
    color: Colors.white70,
  );
}
