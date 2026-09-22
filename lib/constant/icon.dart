import 'package:flutter/material.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// UI アイコンの意味名台帳（KP-023）。
///
/// 画面から `Icons.*` を直書きせず、必ずここの意味名を経由する。
/// 採用スタイルは Material Icons の **Rounded** 系に統一する
/// （正本: Vault「Kakeibo アイコン一覧」）。
/// 同じ意味に複数のアイコンを使わない（戻る・閉じる・削除・完了などは1つに固定）。
class AppIcons {
  AppIcons._();

  // --- ナビゲーション ---
  /// AppBar の戻る（全画面共通）
  static const IconData back = Icons.arrow_back_ios_new_rounded;

  /// モーダル・シートを閉じる
  static const IconData close = Icons.close_rounded;

  /// 行末の「次へ」シェブロン（一覧カード・`AppInsetRow` の右端）。期間送りには使わない（→ [periodNext]）
  static const IconData next = Icons.arrow_forward_ios_rounded;

  /// 期間送り（前の月・年へ）: 期間ヘッダー（全体・月間分析・履歴）・期間ピッカー。行末の「次へ」には使わない（→ [next]）
  static const IconData periodPrev = Icons.chevron_left_rounded;

  /// 期間送り（次の月・年へ）: 期間ヘッダー（全体・月間分析・履歴）・期間ピッカー。行末の「次へ」には使わない（→ [next]）
  static const IconData periodNext = Icons.chevron_right_rounded;

  /// 展開（ピル・行のプルダウン・アコーディオン）
  static const IconData expand = Icons.keyboard_arrow_down_rounded;

  // --- グロナビ ---
  static const IconData navHome = Icons.home_rounded;
  static const IconData navAnalysis = Icons.bar_chart_rounded;
  static const IconData navCouple = Icons.people_rounded;
  static const IconData navCalendar = Icons.calendar_month_rounded;

  // --- 操作 ---
  static const IconData add = Icons.add_rounded;
  static const IconData remove = Icons.remove_rounded;
  static const IconData edit = Icons.edit_rounded;
  static const IconData delete = Icons.delete_rounded;

  /// 一覧から複数選択してまとめて削除する導線（長押しメニュー「まとめて削除」。KP-031）
  static const IconData bulkSelect = Icons.checklist_rounded;

  /// 編集中リストの行頭に置く削除（カテゴリー設定の丸マイナス。KP-024）
  static const IconData deleteRow = Icons.remove_circle_rounded;

  /// 完了・保存・適用・チェック（チェックボックスを含む）
  static const IconData done = Icons.done_rounded;
  static const IconData settings = Icons.settings_rounded;
  static const IconData filter = Icons.filter_alt_rounded;
  static const IconData list = Icons.format_list_bulleted_rounded;
  static const IconData dragHandle = Icons.drag_handle_rounded;

  // --- ステータス ---
  static const IconData success = Icons.check_circle_rounded;
  static const IconData error = Icons.error_rounded;
  static const IconData info = Icons.info_rounded;
  static const IconData lock = Icons.lock_rounded;

  // --- 入力行の行頭（意味アイコン） ---
  /// 名前・名称
  static const IconData rename = Icons.drive_file_rename_outline_rounded;
  static const IconData calendar = Icons.calendar_today_rounded;
  static const IconData memo = Icons.notes_rounded;
  static const IconData budget = Icons.account_balance_wallet_rounded;
  static const IconData fixedCost = Icons.autorenew_rounded;
  static const IconData repeat = Icons.repeat_rounded;
  static const IconData variable = Icons.trending_up_rounded;
  static const IconData payments = Icons.payments_rounded;
  static const IconData iconGrid = Icons.grid_view_rounded;
  static const IconData palette = Icons.palette_rounded;
  static const IconData accountType = Icons.sell_rounded;

  // --- 空状態・誘導 ---
  static const IconData savings = Icons.savings_rounded;
  static const IconData chart = Icons.show_chart_rounded;
  static const IconData receipt = Icons.receipt_long_rounded;

  /// 色玉（カテゴリー色の丸）
  static const IconData dot = Icons.circle;
}

class MyIcon {
  MyIcon._();

  /// 行末の「次へ」シェブロン（一覧カード・カテゴリータイルの右端）
  ///
  /// 色は現在のテーマの `textTertiary`（AppInsetRow の右矢印と同じ。KP-013）
  static Icon next(BuildContext context) => Icon(
    AppIcons.next,
    color: context.colors.textTertiary,
    size: 15,
  );
}
