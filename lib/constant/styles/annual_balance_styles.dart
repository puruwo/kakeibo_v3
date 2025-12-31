import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakeibo/constant/colors.dart';

/// ============================================================================
/// 年間収支グラフページ（annual_balance_chart）で使用するTextStyleを定義
/// ============================================================================
class AnnualBalanceStyles {
  // ==========================================================================
  // グラフ軸ラベル
  // ==========================================================================

  /// 縦軸（Y軸）金額ラベル用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: year_page/annual_balance_chart/annual_balance_chart.dart
  ///   - エリア: 棒グラフの左側縦軸
  ///   - 詳細: 「10万」「20万」などの金額目盛り表示
  ///   - 使用箇所:
  ///     - 行239: グラフ左側の縦軸ラベル
  ///     - 行320, 362, 373, 383: 収入・支出グラフの軸ラベル
  static TextStyle annualBalanceChartPageVerticalLabel = GoogleFonts.notoSans(
      fontSize: 12,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w300);

  /// 月（X軸）ラベル用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: year_page/annual_balance_chart/annual_balance_chart.dart
  ///   - エリア: 棒グラフの下部横軸
  ///   - 詳細: 「1月」「2月」...「12月」の月名表示
  ///   - 使用箇所:
  ///     - 行455: 最初の月ラベル
  ///     - 行465, 474: その他の月ラベル
  static TextStyle annualBalanceChartPageMonthLabel = GoogleFonts.notoSans(
      fontSize: 15, color: MyColors.label, fontWeight: FontWeight.w300);

  /// グラフメッセージ（予算未設定/エラーなど）
  ///
  /// 【使用箇所】
  /// - ページ: year_page/bonus_plan_area/bonus_plan_bar_graph.dart
  /// - ページ: year_page/yearly_balance_area/yearly_balance_bar_graph.dart
  ///   - 詳細: 「予算が設定されていません」「予期せぬエラー」の表示
  static const TextStyle barGraphMessage = TextStyle(
    color: MyColors.secondaryLabel,
    fontSize: 16,
  );
}
