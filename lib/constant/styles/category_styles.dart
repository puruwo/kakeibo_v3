import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakeibo/constant/colors.dart';

/// ============================================================================
/// カテゴリー関連ページで使用するTextStyleを定義
/// - CategoryEditPage（カテゴリー編集ページ）
/// - CategoryExpenseHistoryPage（カテゴリー別支出履歴ページ）
/// ============================================================================
class CategoryStyles {
  // ==========================================================================
  // カテゴリー編集ページ（CategoryEditPage）
  // ==========================================================================

  /// 新規カテゴリー追加リンク用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: category_edit_page/big_category_detail_edit_page
  ///   - エリア: small_category_edit_area.dart (小カテゴリー編集エリア)
  ///   - 詳細: 「+ 新しいカテゴリーを追加」リンク
  ///
  /// - ページ: category_edit_page/big_category_setting_page
  ///   - エリア: big_category_list_area.dart (大カテゴリーリストエリア)
  ///   - 詳細: 「+ 新しいカテゴリーを追加」リンク
  ///   - 備考: 支出カテゴリー・収入カテゴリーの両方で使用
  static TextStyle newCategoryAdd = GoogleFonts.notoSans(
      fontSize: 17,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w400);

  // ==========================================================================
  // カテゴリー別支出履歴ページ（CategoryExpenseHistoryPage）
  // ==========================================================================

  /// カテゴリー・項目タイトル表示用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: category_expense_history_page.dart (カテゴリー別支出履歴)
  ///   - エリア: expanded_category_sum_tile.dart (展開可能カテゴリーサマリータイル)
  ///   - 詳細: 小カテゴリー名表示
  static TextStyle categoryExpenseHistoryPageCategoryName =
      GoogleFonts.notoSans(
          fontSize: 16, color: MyColors.label, fontWeight: FontWeight.w400);

  /// 件数表示用スタイル
  ///
  /// 【使用箇所】
  /// - 現在未使用（将来の拡張用）
  ///   - 想定: カテゴリー別の取引件数表示
  static TextStyle categoryExpenseHistoryPageRecordCount = GoogleFonts.notoSans(
      fontSize: 14,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w300);

  /// 金額表示用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: category_expense_history_page.dart (カテゴリー別支出履歴)
  ///   - エリア: expanded_category_sum_tile.dart (展開可能カテゴリーサマリータイル)
  ///   - 詳細: カテゴリー別合計金額表示
  static const TextStyle categoryExpenseHistoryPagePrice = TextStyle(
      fontFamily: 'sf_ui',
      fontSize: 19,
      color: MyColors.label,
      fontWeight: FontWeight.w300);

  /// 予算表示用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: category_expense_history_page.dart (カテゴリー別支出履歴)
  ///   - エリア: expanded_category_sum_tile.dart
  ///   - 詳細: 「/予算 10,000」などの予算金額表示
  static const TextStyle categoryExpenseHistoryPageBudgetPrice = TextStyle(
      fontFamily: 'sf_ui',
      fontSize: 14,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w300);

  /// 「円」表示用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: category_expense_history_page.dart (カテゴリー別支出履歴)
  ///   - エリア: expanded_category_sum_tile.dart
  ///   - 詳細: 金額・予算の後の「円」表示
  static TextStyle categoryExpenseHistoryPageYen = GoogleFonts.notoSans(
    fontSize: 11,
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w400,
  );

  /// サブテキスト用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: category_expense_history_page.dart (カテゴリー別支出履歴)
  ///   - エリア: expanded_category_sum_tile.dart
  ///   - 詳細: 「/予算」などのラベルテキスト
  static TextStyle categoryExpenseHistoryPageSubText = GoogleFonts.notoSans(
      fontSize: 13,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w400);

  /// リスト一覧のヘッダーラベル（表示/項目/並べ替えなど）
  ///
  /// 【使用箇所】
  /// - ページ: category_edit_page/
  ///   - エリア: small_category_edit_area.dart
  ///   - エリア: big_category_edit_area.dart
  ///   - エリア: big_category_list_area.dart
  ///   - 詳細: リスト上部の各列の見出し
  static TextStyle listHeaderLabel = GoogleFonts.notoSans(
      fontSize: 16,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w400);

  /// 編集リストの親タイトル（大カテゴリー名など）
  ///
  /// 【使用箇所】
  /// - ページ: category_edit_page/
  ///   - エリア: small_category_edit_area.dart
  ///   - エリア: big_category_edit_area.dart
  ///   - エリア: big_category_list_area.dart
  ///   - 詳細: リストアイテムのメインテキスト
  static TextStyle editListTitle = GoogleFonts.notoSans(
      fontSize: 18, color: MyColors.label, fontWeight: FontWeight.w400);

  /// 編集リストのサブタイトル（小カテゴリー列挙など）
  ///
  /// 【使用箇所】
  /// - ページ: category_edit_page/
  ///   - エリア: big_category_edit_area.dart
  ///   - エリア: big_category_list_area.dart
  ///   - 詳細: 大カテゴリーの下に表示される小カテゴリー一覧など
  static TextStyle editListSubTitle = GoogleFonts.notoSans(
      fontSize: 14,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w300);

  /// カテゴリー名入力フィールドのスタイル
  ///
  /// 【使用箇所】
  /// - ページ: category_edit_page/big_category_detail_edit_page
  ///   - エリア: cotegory_appearance_edit_area.dart
  ///   - エリア: fixed_cost_category_appearance_edit_area.dart
  ///   - 詳細: カテゴリー名入力テキストフィールド
  static const TextStyle categoryEditNameInput =
      TextStyle(fontSize: 20, color: MyColors.label);

  /// カテゴリー名入力フィールドのヒントスタイル
  ///
  /// 【使用箇所】
  /// - ページ: category_edit_page/big_category_detail_edit_page
  ///   - エリア: cotegory_appearance_edit_area.dart
  ///   - エリア: fixed_cost_category_appearance_edit_area.dart
  ///   - 詳細: カテゴリー名入力テキストフィールドのヒント
  static const TextStyle categoryEditNameHint =
      TextStyle(fontSize: 16, color: MyColors.secondaryLabel);

  /// カテゴリーカラー選択ラベルのスタイル
  ///
  /// 【使用箇所】
  /// - ページ: category_edit_page/big_category_detail_edit_page
  ///   - エリア: cotegory_appearance_edit_area.dart
  ///   - エリア: fixed_cost_category_appearance_edit_area.dart
  ///   - 詳細: 「カテゴリーカラー」ラベル
  static const TextStyle categoryEditColorLabel =
      TextStyle(fontSize: 14, color: MyColors.label);
}
