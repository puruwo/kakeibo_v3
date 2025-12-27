import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';

/// register_page以下で使用するTextStyleを一元管理
class RegisterPageStyles {
  // =============================================
  // 金額表示（大きなフォント）
  // =============================================

  /// 金額入力フィールドのスタイル（¥42,000）
  static const TextStyle priceInput = TextStyle(
    color: MyColors.white,
    fontSize: 42,
    fontWeight: FontWeight.bold,
    height: 1.0,
  );

  /// 未確定金額表示（---）
  static const TextStyle priceUnconfirmed = TextStyle(
    color: MyColors.secondaryLabel,
    fontSize: 42,
    fontWeight: FontWeight.bold,
    height: 1.0,
  );

  /// 円記号（¥）のスタイル - 色は動的に設定
  static TextStyle yenSymbol(Color color) => TextStyle(
        color: color,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      );

  // =============================================
  // ピル・ボタン
  // =============================================

  /// ピルのラベル（支出/収入）- 色は動的に設定
  static TextStyle pillLabel(Color color) => TextStyle(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.0,
      );

  /// 日付ボタンのテキスト（2/29）
  static const TextStyle dateButton = TextStyle(
    color: MyColors.white,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  /// 予算ラベル（予算）
  static const TextStyle budgetLabel = TextStyle(
    color: MyColors.secondaryLabel,
    fontSize: 15,
  );

  /// 予算選択値（生活収支）
  static const TextStyle budgetValue = TextStyle(
    color: MyColors.white,
    fontSize: 15,
  );

  // =============================================
  // カテゴリーエリア
  // =============================================

  /// カテゴリーアイコン下のラベル
  static const TextStyle categoryLabel = TextStyle(
    fontSize: 13,
    color: MyColors.white,
  );

  /// 「アイコンを並べ替える」リンク
  static const TextStyle rearrangeLink = TextStyle(
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  // =============================================
  // ピッカー・ダイアログ
  // =============================================

  /// ドロップダウンの大きいテキスト（数字）
  static const TextStyle pickerLargeNumber = TextStyle(
    fontSize: 24,
    color: MyColors.label,
    fontWeight: FontWeight.bold,
  );

  /// ドロップダウンの中サイズテキスト（単位）
  static const TextStyle pickerMediumText = TextStyle(
    fontSize: 20,
    color: MyColors.label,
    fontWeight: FontWeight.bold,
  );
}
