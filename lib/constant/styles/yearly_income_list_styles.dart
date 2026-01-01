import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakeibo/constant/colors.dart';

/// ============================================================================
/// 収入一覧ページ（yearly_income_list_page）で使用するTextStyleを定義
/// ============================================================================
class YearlyIncomeListStyles {
  // ==========================================================================
  // リストエリア関連
  // ==========================================================================

  /// 月グループヘッダー
  ///
  /// 【使用箇所】
  /// - ページ: yearly_income_list_page.dart
  ///   - エリア: yearly_income_list_area.dart
  ///   - 詳細: 「2024年12月」などの月見出し
  static TextStyle listMonthHeader = GoogleFonts.notoSans(
    fontSize: 14,
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w600,
  );

  // ==========================================================================
  // メッセージ・エラー関連
  // ==========================================================================

  /// データなしメッセージ
  ///
  /// 【使用箇所】
  /// - ページ: yearly_income_list_page.dart
  ///   - エリア: income_graph_area.dart / yearly_income_list_area.dart
  ///   - 詳細: データがない場合のメッセージ
  static TextStyle noDataMessage = GoogleFonts.notoSans(
    fontSize: 16,
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w400,
  );

  /// エラーメッセージ（赤文字）
  ///
  /// 【使用箇所】
  /// - ページ: yearly_income_list_page.dart
  ///   - エリア: income_graph_area.dart / yearly_income_list_area.dart
  ///   - 詳細: 読み込みエラー時のメッセージ
  static TextStyle errorMessage = GoogleFonts.notoSans(
    fontSize: 16,
    color: MyColors.red,
    fontWeight: FontWeight.w400,
  );
}
