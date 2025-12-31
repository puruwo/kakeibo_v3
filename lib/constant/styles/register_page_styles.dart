import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakeibo/constant/colors.dart';

/// ============================================================================
/// 登録ページ（register_page）で使用するTextStyleを定義
/// ============================================================================
class RegisterPageStyles {
  // ==========================================================================
  // ページヘッダー
  // ==========================================================================

  /// 登録ページのヘッダーラベル
  ///
  /// 【使用箇所】
  /// - ページ: register_page_base.dart (登録ページベース)
  ///   - エリア: AppBar
  ///   - 詳細: 「支出を登録」「収入を登録」などのタイトル表示
  static TextStyle regesterHeaderLabel = GoogleFonts.notoSans(
      fontSize: 19, color: MyColors.white, fontWeight: FontWeight.w400);

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
  ///   - エリア: price_type_switch_area.dart (価格タイプ切替エリア)
  ///   - 詳細: 「金額を入力」などのプレースホルダー
  static TextStyle placeHolder = GoogleFonts.notoSans(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: MyColors.secondaryLabel,
  );

  /// 支出金額入力スタイル（ダイアログ用）
  ///
  /// 【使用箇所】
  /// - ページ: monthly_fixed_cost_page (月間固定費ページ)
  ///   - エリア: price_input_dialog.dart (金額入力ダイアログ)
  ///   - 詳細: 固定費の金額入力フィールド
  static TextStyle inputExpenseText = const TextStyle(
    fontSize: 25.0,
    fontWeight: FontWeight.w500,
    color: MyColors.label,
    fontFamily: 'sf_ui',
    height: 1.0,
  );

  /// 一般入力テキスト用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: register_page
  ///   - エリア: memo_input_field.dart (メモ入力フィールド)
  ///   - 詳細: メモの入力テキスト表示
  ///
  /// - ページ: category_edit_page (カテゴリー編集ページ)
  ///   - エリア: new_small_category_input_name_dialog.dart
  ///   - 詳細: 小カテゴリー名入力フィールド
  static TextStyle inputText = GoogleFonts.notoSans(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: MyColors.label,
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
  static const TextStyle priceInput = TextStyle(
    color: MyColors.white,
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
  static const TextStyle priceUnconfirmed = TextStyle(
    color: MyColors.secondaryLabel,
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
  static TextStyle yenSymbol(Color color) => TextStyle(
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
  static TextStyle pillLabel(Color color) => TextStyle(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.0,
      );

  /// 日付ボタンのテキスト（2/29）
  ///
  /// 【使用箇所】
  /// - ページ: register_page
  ///   - エリア: date_input_field.dart (日付入力フィールド)
  ///   - 詳細: 選択された日付表示
  ///
  /// - ページ: register_page
  ///   - エリア: initial_payment_date_input_field.dart (初回支払い日入力)
  ///   - 詳細: 固定費の初回支払い日表示
  static const TextStyle dateButton = TextStyle(
    color: MyColors.white,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  /// 予算ラベル（予算）
  ///
  /// 【使用箇所】
  /// - ページ: register_page
  ///   - エリア: budget_row.dart (予算行)
  ///   - 詳細: 「予算」ラベル
  ///
  /// - ページ: register_page
  ///   - エリア: payment_frequency_input_field.dart
  ///   - 詳細: 「支払い頻度」ラベル
  ///
  /// - ページ: register_page
  ///   - エリア: initial_payment_date_input_field.dart
  ///   - 詳細: 「初回支払い日」ラベル
  static const TextStyle budgetLabel = TextStyle(
    color: MyColors.secondaryLabel,
    fontSize: 15,
  );

  /// 予算選択値（生活収支）
  ///
  /// 【使用箇所】
  /// - ページ: register_page
  ///   - エリア: budget_row.dart (予算行)
  ///   - 詳細: 「生活収支」「ボーナス」などの選択値表示
  ///
  /// - ページ: register_page
  ///   - エリア: payment_frequency_input_field.dart
  ///   - 詳細: 「1ヶ月に1回」などの頻度表示
  static const TextStyle budgetValue = TextStyle(
    color: MyColors.white,
    fontSize: 15,
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
  static const TextStyle categoryLabel = TextStyle(
    fontSize: 13,
    color: MyColors.white,
  );

  /// 「アイコンを並べ替える」リンク
  ///
  /// 【使用箇所】
  /// - ページ: register_page
  ///   - エリア: category_area/category_area.dart
  ///   - 詳細: カテゴリーエリア下部の並べ替えリンク
  static const TextStyle rearrangeLink = TextStyle(
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  // ==========================================================================
  // ピッカー・ダイアログ
  // ==========================================================================

  /// ドロップダウンの大きいテキスト（数字）
  ///
  /// 【使用箇所】
  /// - ページ: register_page
  ///   - エリア: payment_frequency_picker.dart (支払い頻度ピッカー)
  ///   - 詳細: 「1」「2」...などの間隔数字表示
  static const TextStyle pickerLargeNumber = TextStyle(
    fontSize: 24,
    color: MyColors.label,
    fontWeight: FontWeight.bold,
  );

  /// ドロップダウンの中サイズテキスト（単位）
  ///
  /// 【使用箇所】
  /// - ページ: register_page
  ///   - エリア: payment_frequency_picker.dart (支払い頻度ピッカー)
  ///   - 詳細: 「ヶ月」「年」などの単位表示
  static const TextStyle pickerMediumText = TextStyle(
    fontSize: 20,
    color: MyColors.label,
    fontWeight: FontWeight.bold,
  );
}
