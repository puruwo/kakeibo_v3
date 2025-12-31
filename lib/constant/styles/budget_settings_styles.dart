import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakeibo/constant/colors.dart';

/// ============================================================================
/// 予算設定ページ（budget_setting_page）で使用するTextStyleを定義
/// ============================================================================
class BudgetSettingsStyles {
  // ==========================================================================
  // カテゴリータイル
  // ==========================================================================

  /// カテゴリータイトル用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: budget_setting_page.dart (予算設定ページ)
  ///   - エリア: budget_category_tile.dart (予算カテゴリータイル)
  ///   - 詳細: 「食費」「交通費」などのカテゴリー名表示
  static TextStyle categoryTitle = GoogleFonts.notoSans(
      fontSize: 18, color: MyColors.label, fontWeight: FontWeight.w400);

  /// サブ価格表示用スタイル（過去の平均など）
  ///
  /// 【使用箇所】
  /// - ページ: budget_setting_page.dart (予算設定ページ)
  ///   - エリア: budget_category_tile.dart (予算カテゴリータイル)
  ///   - 詳細: 過去3ヶ月平均などの参考金額表示
  static const TextStyle subPrice = TextStyle(
      fontFamily: 'sf_ui',
      fontSize: 16,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w300);

  /// 「円」テキスト用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: budget_setting_page.dart (予算設定ページ)
  ///   - エリア: budget_category_tile.dart (予算カテゴリータイル)
  ///   - 詳細: 予算金額の後の「円」表示
  ///   - 備考: 参考金額横、入力フィールド横の両方で使用
  static TextStyle yenText = GoogleFonts.notoSans(
      fontSize: 14, color: MyColors.tirtiaryLabel, fontWeight: FontWeight.w300);

  /// テキストフィールド（予算入力）用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: budget_setting_page.dart (予算設定ページ)
  ///   - エリア: budget_category_tile.dart (予算カテゴリータイル)
  ///   - 詳細: 予算金額の入力フィールド
  static const TextStyle textField = TextStyle(
      fontFamily: 'sf_ui',
      fontWeight: FontWeight.w600,
      color: MyColors.white,
      fontSize: 20);

  /// 入力フィールドのヒントテキスト
  ///
  /// 【使用箇所】
  /// - ページ: budget_setting_page.dart (予算設定ページ)
  ///   - エリア: budget_category_tile.dart (予算カテゴリータイル)
  ///   - 詳細: 「金額を入力」などのプレースホルダー
  static const TextStyle textFieldHint = TextStyle(
    fontSize: 16,
    color: MyColors.tirtiaryLabel,
  );

  /// 一覧のヘッダーラベル（カテゴリー/先月の支出/今月の予算）
  ///
  /// 【使用箇所】
  /// - ページ: budget_setting_page.dart (予算設定ページ)
  ///   - エリア: budget_setting_page.dart / budget_cotegory_area.dart
  ///   - 詳細: リスト上部の各列の見出し
  static TextStyle columnHeaderLabel = GoogleFonts.notoSans(
      fontSize: 16,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w400);
}
