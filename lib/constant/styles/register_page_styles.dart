import 'package:flutter/material.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/constant/font_style.dart';

/// ============================================================================
/// 登録ページ（register_page）で使用するTextStyleを定義
/// ============================================================================
class RegisterPageStyles {
  // ==========================================================================
  // 入力フィールド
  // ==========================================================================

  /// プレースホルダー用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: register_page内各種入力フィールド
  ///   - エリア: memo_input_field.dart (メモ入力フィールド)
  ///   - 詳細: 「メモを入力」などのプレースホルダーテキスト
  ///
  /// - ページ: register_page
  ///   - エリア: budget_row.dart (予算行)
  ///   - 詳細: 「予算」ラベル
  ///
  /// - ページ: register_page
  ///   - エリア: payment_frequency_input_field.dart
  ///   - 詳細: 「支払い頻度」ラベル
  ///
  /// - ページ: register_page
  ///   - エリア: payment_frequency_picker.dart
  ///   - 詳細: ピッカー内のラベル
  static final TextStyle placeHolder = MyFontStyle.notoSans.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColorsDark.textSecondary,
  );

  /// 一般入力テキスト用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: register_page
  ///   - エリア: memo_input_field.dart (メモ入力フィールド)
  ///   - 詳細: メモの入力テキスト表示
  ///
  /// - ページ: register_page
  ///   - エリア: budget_row.dart (予算行)
  ///   - 詳細: 「生活収支」「ボーナス」などの選択値表示
  ///
  /// - ページ: register_page
  ///   - エリア: payment_frequency_input_field.dart
  ///   - 詳細: 「1ヶ月に1回」などの頻度表示
  static final TextStyle inputText = MyFontStyle.notoSans.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColorsDark.text,
    height: 1.0,
  );

  // ==========================================================================
  // 金額表示（大きなフォント）
  // ==========================================================================

  /// 金額入力フィールドのスタイル（¥42,000）
  ///
  /// 【使用箇所】
  /// - ページ: register_page
  ///   - エリア: large_price_display.dart (大型金額表示)
  ///   - 詳細: 入力中の金額表示
  static final TextStyle priceInput = MyFontStyle.sfUi.copyWith(
    color: AppColorsDark.text,
    fontSize: 42,
    fontWeight: FontWeight.bold,
    height: 1.0,
  );

  /// 未確定金額表示（---）
  ///
  /// 【使用箇所】
  /// - ページ: register_page
  ///   - エリア: large_price_display.dart (大型金額表示)
  ///   - 詳細: 金額未入力時の「---」表示
  static final TextStyle priceUnconfirmed = MyFontStyle.sfUi.copyWith(
    color: AppColorsDark.textSecondary,
    fontSize: 42,
    fontWeight: FontWeight.bold,
    height: 1.0,
  );

  /// 円記号（¥）のスタイル - 色は動的に設定
  ///
  /// 【使用箇所】
  /// - ページ: register_page
  ///   - エリア: large_price_display.dart (大型金額表示)
  ///   - 詳細: 金額の前に表示される「¥」記号
  ///   - 備考: 支出/収入によって色が変わる
  static TextStyle yenSymbol(Color color) => MyFontStyle.sfUi.copyWith(
    color: color,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  // ==========================================================================
  // ピル・ボタン
  // ==========================================================================

  /// ピルのラベル（支出/収入）- 色は動的に設定
  ///
  /// 【使用箇所】
  /// - ページ: register_page
  ///   - エリア: transaction_type_pill.dart (取引種別ピル)
  ///   - 詳細: 「支出」「収入」の切り替えピルのテキスト
  ///   - 備考: 選択状態によって色が変わる
  static TextStyle pillLabel(Color color) => MyFontStyle.notoSans.copyWith(
    color: color,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );

  // ==========================================================================
  // カテゴリーエリア
  // ==========================================================================

  /// カテゴリーアイコン下のラベル
  ///
  /// 【使用箇所】
  /// - ページ: register_page
  ///   - エリア: category_area/icon_box/
  ///   - 詳細: none_icon_button.dart, selected_icon_button.dart, normal_icon_button.dart
  ///   - 備考: 「食費」「交通費」などのカテゴリー名表示
  static final TextStyle categoryLabel = MyFontStyle.notoSans.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColorsDark.text,
  );

  /// 「アイコンを並べ替える」リンク
  ///
  /// 【使用箇所】
  /// - ページ: register_page
  ///   - エリア: category_area/category_area.dart
  ///   - 詳細: カテゴリーエリア下部の並べ替えリンク
  static final TextStyle rearrangeLink = MyFontStyle.notoSans.copyWith(
    color: AppColorsDark.textSecondary,
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  // ==========================================================================
  // ピッカー・ダイアログ
  // ==========================================================================

  // ==========================================================================
  // アイコン並べ替えページ
  // ==========================================================================
  static final TextStyle iconRearrangeDescription = MyFontStyle.notoSans
      .copyWith(
        fontSize: 14,
        color: AppColorsDark.textSecondary,
        fontWeight: FontWeight.w500,
      );
}
