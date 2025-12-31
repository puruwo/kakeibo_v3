import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';

/// ============================================================================
/// 履歴リストエリアで使用するTextStyleを定義
/// ============================================================================
class HistoryListStyles {
  // ==========================================================================
  // 履歴リストヘッダー
  // ==========================================================================

  /// 日付ヘッダーラベル
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: expence_history_list_area.dart (履歴リストエリア)
  ///   - 詳細: 「12月25日（水）」などの日付グループヘッダー表示
  ///
  /// - ページ: category_expense_history_page.dart (カテゴリー別支出履歴)
  ///   - エリア: category_expence_history_list_area.dart
  ///   - 詳細: 日付グループヘッダー表示
  static const TextStyle expenseHistoryDateHeaderLabel = TextStyle(
    color: MyColors.secondaryLabel,
    fontSize: 14,
  );

  // ==========================================================================
  // 履歴タイル内の共通スタイル
  // ==========================================================================

  /// 大カテゴリー名ラベル
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: tiles/expense_item_tile.dart (支出タイル)
  ///   - 詳細: 「食費」「交通費」などの大カテゴリー名表示
  ///
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: tiles/income_item_tile.dart (収入タイル)
  ///   - 詳細: 「給与」「副業」などの収入カテゴリー名表示
  ///
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: tiles/confirmed_fixed_cost_item_tile.dart (確定固定費タイル)
  ///   - 詳細: 固定費名表示
  ///
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: tiles/unconfirmed_fixed_cost_item_tile.dart (未確定固定費タイル)
  ///   - 詳細: 固定費名表示
  static const TextStyle historyTileBigCategoryLabel = TextStyle(
    fontSize: 15,
    color: MyColors.label,
  );

  /// サブラベル（小カテゴリー/メモ/固定費ラベル）
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: tiles/expense_item_tile.dart (支出タイル)
  ///   - 詳細: 小カテゴリー名やメモ表示
  ///
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: tiles/income_item_tile.dart (収入タイル)
  ///   - 詳細: 小カテゴリー名やメモ表示
  ///
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: tiles/confirmed_fixed_cost_item_tile.dart
  ///   - 詳細: 「固定費」ラベル表示
  ///
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: tiles/unconfirmed_fixed_cost_item_tile.dart
  ///   - 詳細: 「固定費（未確定）」ラベル表示
  static const TextStyle historyTileSubLabel = TextStyle(
    fontSize: 12,
    color: MyColors.secondaryLabel,
  );

  // ==========================================================================
  // 履歴タイル内の金額表示
  // ==========================================================================

  /// 金額ラベル（デフォルト - 支出用）
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: tiles/expense_item_tile.dart (支出タイル)
  ///   - 詳細: 「¥1,234」などの支出金額表示
  ///
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: tiles/confirmed_fixed_cost_item_tile.dart
  ///   - 詳細: 固定費金額表示
  static const TextStyle historyTilePriceLabel = TextStyle(
    fontSize: 19,
    color: MyColors.label,
  );

  /// 金額ラベル（収入用 - 緑色）
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: tiles/income_item_tile.dart (収入タイル)
  ///   - 詳細: 「¥50,000」などの収入金額表示
  static const TextStyle historyTileIncomePriceLabel = TextStyle(
    fontSize: 19,
    color: MyColors.systemGreen,
  );

  /// 収入金額の「+」記号
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: tiles/income_item_tile.dart (収入タイル)
  ///   - 詳細: 収入金額の前に表示される「+」記号
  static const TextStyle historyTileIncomePlusLabel = TextStyle(
    fontSize: 15,
    color: MyColors.systemGreen,
  );

  // ==========================================================================
  // 履歴エリアのエンプティステート
  // ==========================================================================

  /// 「記録がありません」メッセージ
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: expence_history_list_area.dart (履歴リストエリア)
  ///   - 詳細: データがない場合の「この日の記録はありません」メッセージ
  static const TextStyle historyEmptyMessage = TextStyle(
    color: MyColors.secondaryLabel,
    fontSize: 16,
  );

  /// 未入力ラベル（赤字）
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart
  ///   - エリア: tiles/unconfirmed_fixed_cost_tile.dart
  ///   - 詳細: 「未入力」ラベル
  static const TextStyle historyTileUnconfirmedLabel = TextStyle(
    fontSize: 15,
    color: MyColors.red,
  );

  /// 金額ラベル（色指定可能）
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart
  ///   - エリア: tiles/unconfirmed_fixed_cost_item_tile.dart
  ///   - 詳細: 未確定固定費の金額表示（条件により色変化）
  static TextStyle historyTilePriceLabelWithColor(Color color) => TextStyle(
        fontSize: 19,
        color: color,
      );
}
