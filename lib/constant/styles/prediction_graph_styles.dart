import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';

/// ============================================================================
/// 予測グラフ（prediction_graph）で使用するTextStyleを定義
/// ============================================================================
class PredictionGraphStyles {
  PredictionGraphStyles._();

  // ==========================================================================
  // グラフ本体のラベル
  // ==========================================================================

  /// グラフ軸ラベル用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: monthly_page/prediction_graph_area/prediction_graph.dart
  ///   - エリア: グラフ本体
  ///   - 詳細: 以下のラベルで使用
  ///     - 行476: 収入ラインの「収入」ラベル
  ///     - 行507: 予算ラインの「予算」ラベル
  ///     - 行710: 予測ラインの「予測」ラベル
  ///     - 行767: 日別支出バーの「日別」ラベル
  static const graphLabel = TextStyle(
    fontSize: 12,
    color: MyColors.secondaryLabel,
    fontFamily: 'sf_ui',
  );

  /// グラフ金額ラベル用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: monthly_page/prediction_graph_area/prediction_graph.dart
  ///   - エリア: グラフ本体
  ///   - 詳細: 以下の金額表示で使用
  ///     - 行661: Y軸の金額目盛り（「¥10,000」など）
  ///     - 行714: 予測ラインの金額表示
  ///     - 行771: 日別支出バーの金額表示
  ///     - 行847: X軸の日付表示（「1」「15」「30」など）
  static const graphPriceLabel = TextStyle(
    fontSize: 14,
    color: MyColors.secondaryLabel,
    fontFamily: 'sf_ui',
  );

  // ==========================================================================
  // グラフエリアのメッセージ
  // ==========================================================================

  /// 空状態・エラーメッセージ用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: monthly_page/prediction_graph_area/prediction_graph.dart
  ///   - エリア: グラフエリア全体
  ///   - 詳細: 以下のメッセージ表示で使用
  ///     - 行38: 「予測グラフは来月から表示されます」（月初表示）
  ///     - 行48: 「この月の支出はありません」（空データ状態）
  static const message = TextStyle(
    color: MyColors.secondaryLabel,
    fontSize: 16,
  );

  // ==========================================================================
  // ツールチップ
  // ==========================================================================

  /// ツールチップ日付用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: monthly_page/prediction_graph_area/prediction_graph.dart
  ///   - エリア: タップ時のツールチップ
  ///   - 詳細: 行258 - 「12/29」などの日付表示
  static const tooltipDate = TextStyle(
    fontSize: 14,
    color: MyColors.label,
  );

  /// ツールチップ累計金額用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: monthly_page/prediction_graph_area/prediction_graph.dart
  ///   - エリア: タップ時のツールチップ
  ///   - 詳細:
  ///     - 行271: 累計金額表示（「¥12,345」）
  ///     - 行286: 固定費金額表示
  static const tooltipSubtitle = TextStyle(
    fontSize: 14,
    color: MyColors.label,
  );

  /// ツールチップカテゴリー金額用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: monthly_page/prediction_graph_area/prediction_graph.dart
  ///   - エリア: タップ時のツールチップ
  ///   - 詳細: 行348 - カテゴリー別の金額表示（「¥1,234」）
  static const tooltipCategory = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: MyColors.label,
  );

  /// ツールチップ補助ラベル用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: monthly_page/prediction_graph_area/prediction_graph.dart
  ///   - エリア: タップ時のツールチップ
  ///   - 詳細:
  ///     - 行267: 「累計」ラベル
  ///     - 行286: 「固定費」ラベル
  ///   - 備考: 金額の上に表示される小さなラベル
  static const tooltipCumulativeLabel = TextStyle(
    fontSize: 10,
    color: MyColors.secondaryLabel,
  );
}
