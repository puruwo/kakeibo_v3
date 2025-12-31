import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakeibo/constant/colors.dart';

/// ============================================================================
/// アプリ全般で共通して使用するTextStyleを定義
/// ============================================================================
class AppTextStyles {
  // ==========================================================================
  // ページヘッダー
  // ==========================================================================

  /// ページタイトル用のスタイル
  ///
  /// 【使用箇所】
  /// - ページ: year_page.dart (年間ページ)
  ///   - エリア: AppBarのタイトル
  ///   - 詳細: 「2024」などの年表示
  ///
  /// - ページ: monthly_page.dart (月間ページ)
  ///   - エリア: AppBarのタイトル
  ///   - 詳細: 月の表示タイトル
  ///
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: AppBarのタイトル
  ///   - 詳細: 履歴ページのタイトル
  ///
  /// - ページ: category_setting_page.dart (カテゴリー設定ページ)
  ///   - エリア: AppBarのタイトル
  ///   - 詳細: 「カテゴリー設定」タイトル
  ///
  /// - ページ: category_expense_history_page.dart (カテゴリー別支出履歴)
  ///   - エリア: AppBarのタイトル
  ///   - 詳細: カテゴリー名表示
  ///
  /// - ページ: small_category_expanded_history_page.dart (小カテゴリー詳細)
  ///   - エリア: AppBarのタイトル
  ///   - 詳細: 小カテゴリー名表示
  ///
  /// - ページ: budget_setting_page.dart (予算設定ページ)
  ///   - エリア: AppBarのタイトル
  ///   - 詳細: 「予算設定」タイトル
  ///
  /// - ページ: category_detail_edit_page.dart (カテゴリー詳細編集)
  ///   - エリア: AppBarのタイトル
  ///   - 詳細: カテゴリー編集タイトル
  ///
  /// - ページ: monthly_plan_home_page.dart (月間計画ホーム)
  ///   - エリア: AppBarのタイトル
  ///   - 詳細: 「月間計画」タイトル
  ///
  /// - ページ: bonus_home_page.dart (ボーナスホーム)
  ///   - エリア: AppBarのタイトル
  ///   - 詳細: 「ボーナス」タイトル
  static TextStyle pageHeaderText = GoogleFonts.notoSans(
      fontSize: 19, color: MyColors.white, fontWeight: FontWeight.w400);

  // ==========================================================================
  // ダイアログ
  // ==========================================================================

  /// ダイアログタイトル用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: payment_frequency_picker.dart (支払い頻度ピッカー)
  ///   - エリア: ダイアログヘッダー
  ///   - 詳細: 「支払い頻度を設定」タイトル
  static TextStyle dialogTitle = GoogleFonts.notoSans(
      fontSize: 18, color: MyColors.white, fontWeight: FontWeight.w600);

  /// ダイアログ内ラベル用スタイル
  ///
  /// 【使用箇所】
  /// - 現在未使用（将来の拡張用）
  static TextStyle dialogLabel = GoogleFonts.notoSans(
      fontSize: 14, color: MyColors.white, fontWeight: FontWeight.w300);

  /// ダイアログ内リスト項目用スタイル
  ///
  /// 【使用箇所】
  /// - 現在未使用（将来の拡張用）
  static TextStyle dialogList = GoogleFonts.notoSans(
      fontSize: 18, color: MyColors.white, fontWeight: FontWeight.w300);

  // ==========================================================================
  // タブ
  // ==========================================================================

  /// 選択中タブラベル用スタイル
  ///
  /// 【使用箇所】
  /// - ファイル: app_component.dart (AppTab共通コンポーネント)
  ///   - エリア: TabBar
  ///   - 詳細: 選択されているタブのテキストスタイル
  static TextStyle selectedLabelStyle = GoogleFonts.notoSans(
      fontSize: 14, color: MyColors.themeColor, fontWeight: FontWeight.w600);

  /// 非選択タブラベル用スタイル
  ///
  /// 【使用箇所】
  /// - ファイル: app_component.dart (AppTab共通コンポーネント)
  ///   - エリア: TabBar
  ///   - 詳細: 選択されていないタブのテキストスタイル
  static TextStyle unselectedLabelStyle = GoogleFonts.notoSans(
      fontSize: 14,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w300);

  // ==========================================================================
  // ボタン
  // ==========================================================================

  /// メインボタン用テキストスタイル
  ///
  /// 【使用箇所】
  /// - 現在未使用（将来の拡張用、MainButtonコンポーネント内で使用予定）
  static TextStyle mainButtonText = GoogleFonts.notoSans(
      fontSize: 14, color: MyColors.label, fontWeight: FontWeight.w600);

  // ==========================================================================
  // リスト共通
  // ==========================================================================

  /// 空のリスト用メッセージスタイル
  ///
  /// 【使用箇所】
  /// - ページ: 各リストページ
  ///   - エリア: メインコンテンツ
  ///   - 詳細: データがない場合の表示
  static TextStyle listEmptyMessage = GoogleFonts.notoSans(
      fontSize: 16,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w400);

  /// エラーメッセージスタイル
  ///
  /// 【使用箇所】
  /// - ページ: 各ページ
  ///   - エリア: メインコンテンツ
  ///   - 詳細: エラー発生時の表示
  static TextStyle errorMessage = GoogleFonts.notoSans(
      fontSize: 16, color: MyColors.red, fontWeight: FontWeight.w400);

  /// セカンダリボタン用テキストスタイル
  ///
  /// 【使用箇所】
  /// - ファイル: new_small_category_input_name_dialog.dart
  ///   - エリア: ダイアログ内キャンセルボタン
  ///   - 詳細: 「キャンセル」ボタンテキスト
  ///
  /// - ファイル: price_input_dialog.dart (固定費金額入力ダイアログ)
  ///   - エリア: ダイアログ内キャンセルボタン
  ///   - 詳細: 「キャンセル」ボタンテキスト
  ///
  /// - ファイル: payment_frequency_picker.dart
  ///   - エリア: ダイアログ内キャンセルボタン
  ///   - 詳細: 「キャンセル」ボタンテキスト
  static TextStyle secondaryButtonText = GoogleFonts.notoSans(
      fontSize: 14, color: MyColors.label, fontWeight: FontWeight.w600);

  /// 白文字ボタン用テキストスタイル
  ///
  /// 【使用箇所】
  /// - 現在未使用（将来の拡張用）
  static TextStyle whiteButtonText = GoogleFonts.notoSans(
      fontSize: 17, color: MyColors.white, fontWeight: FontWeight.w600);

  // ==========================================================================
  // カード（汎用）
  // ==========================================================================

  /// カードのメインタイトル用スタイル
  ///
  /// 【使用箇所】
  /// - ファイル: bonus_income_history_tile.dart (ボーナス収入履歴タイル)
  ///   - エリア: タイル内タイトル
  ///   - 詳細: カテゴリー名表示
  ///
  /// - ファイル: bonus_expense_history_tile.dart (ボーナス支出履歴タイル)
  ///   - エリア: タイル内タイトル
  ///   - 詳細: カテゴリー名表示
  ///
  /// - ファイル: income_history_tile.dart (月間収入履歴タイル)
  ///   - エリア: タイル内タイトル
  ///   - 詳細: カテゴリー名表示
  ///
  /// - ファイル: confirmed_fixed_cost_tile.dart (確定固定費タイル)
  ///   - エリア: タイル内タイトル
  ///   - 詳細: 固定費名表示
  ///
  /// - ファイル: unconfirmed_fixed_cost_tile.dart (未確定固定費タイル)
  ///   - エリア: タイル内タイトル
  ///   - 詳細: 固定費名表示
  ///
  /// - ファイル: yearly_income_card.dart (年間収入カード)
  ///   - エリア: カード内タイトル
  ///   - 詳細: 収入カテゴリー名表示
  static TextStyle cardPrimaryTitle = GoogleFonts.notoSans(
      fontSize: 16, color: MyColors.label, fontWeight: FontWeight.w300);

  /// カードのサブタイトル用スタイル
  ///
  /// 【使用箇所】
  /// - ファイル: fixed_cost_item_tile.dart (固定費一覧タイル)
  ///   - エリア: タイル内サブタイトル
  ///   - 詳細: 支払い頻度、次回支払い日など
  ///
  /// - ファイル: bonus_income_history_tile.dart
  ///   - エリア: タイル内日付表示
  ///   - 詳細: 登録日時
  ///
  /// - ファイル: bonus_expense_history_tile.dart
  ///   - エリア: タイル内日付表示
  ///   - 詳細: 登録日時
  ///
  /// - ファイル: income_history_tile.dart
  ///   - エリア: タイル内日付表示
  ///   - 詳細: 登録日時
  ///
  /// - ファイル: confirmed_fixed_cost_tile.dart / unconfirmed_fixed_cost_tile.dart
  ///   - エリア: タイル内サブテキスト
  ///   - 詳細: 確認状態や支払い情報
  ///
  /// - ファイル: yearly_income_card.dart
  ///   - エリア: カード内サブテキスト
  ///   - 詳細: 日付や備考
  static TextStyle cardSecondaryTitle = GoogleFonts.notoSans(
      fontSize: 12,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w300);

  /// マイナス金額ラベル用スタイル（ミントブルー）
  ///
  /// 【使用箇所】
  /// - ファイル: bonus_expense_history_tile.dart
  ///   - エリア: タイル内金額横のマイナスラベル
  ///   - 詳細: 「-」表示
  static TextStyle cardMinusLabel = const TextStyle(
      fontFamily: 'sf_ui',
      fontSize: 16,
      color: MyColors.mintBlue,
      fontWeight: FontWeight.w600);

  /// プラス金額ラベル用スタイル（ピンク）
  ///
  /// 【使用箇所】
  /// - ファイル: bonus_income_history_tile.dart (ボーナス収入履歴タイル)
  ///   - エリア: タイル内金額横のプラスラベル
  ///   - 詳細: 「+」表示
  ///
  /// - ファイル: income_history_tile.dart (月間収入履歴タイル)
  ///   - エリア: タイル内金額横のプラスラベル
  ///   - 詳細: 「+」表示
  ///
  /// - ファイル: yearly_income_card.dart
  ///   - エリア: カード内金額横のプラスラベル
  ///   - 詳細: 「+」表示
  static TextStyle cardPlusLabel = const TextStyle(
      fontFamily: 'sf_ui',
      fontSize: 16,
      color: MyColors.pink,
      fontWeight: FontWeight.w600);

  /// カード内金額表示用スタイル
  ///
  /// 【使用箇所】
  /// - ファイル: fixed_cost_item_tile.dart
  ///   - エリア: タイル内金額
  ///   - 詳細: 固定費金額表示
  ///
  /// - ファイル: bonus_income_history_tile.dart / bonus_expense_history_tile.dart
  ///   - エリア: タイル内金額
  ///   - 詳細: ボーナス金額表示
  ///
  /// - ファイル: income_history_tile.dart
  ///   - エリア: タイル内金額
  ///   - 詳細: 収入金額表示
  ///
  /// - ファイル: confirmed_fixed_cost_tile.dart / unconfirmed_fixed_cost_tile.dart
  ///   - エリア: タイル内金額
  ///   - 詳細: 固定費金額表示
  ///
  /// - ファイル: yearly_income_card.dart
  ///   - エリア: カード内金額
  ///   - 詳細: 年間収入金額表示
  static TextStyle cardPriceLabel = const TextStyle(
      fontFamily: 'sf_ui',
      fontSize: 19,
      color: MyColors.label,
      fontWeight: FontWeight.w600);

  // ==========================================================================
  // アプリカード（収入グラフエリアなど）
  // ==========================================================================

  /// アプリカードのタイトルラベル用スタイル
  ///
  /// 【使用箇所】
  /// - ファイル: income_graph_area.dart (年間収入グラフエリア)
  ///   - エリア: グラフ上部タイトル
  ///   - 詳細: 「総収入」ラベル
  static TextStyle appCardTitleLabel = GoogleFonts.notoSans(
    fontSize: 14,
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w500,
  );

  /// アプリカードの金額表示用スタイル
  ///
  /// 【使用箇所】
  /// - ファイル: income_graph_area.dart
  ///   - エリア: グラフ上部金額
  ///   - 詳細: 総収入金額表示
  static TextStyle appCardPriceLabel = GoogleFonts.notoSans(
    fontSize: 20,
    color: MyColors.white,
    fontWeight: FontWeight.w600,
  );

  /// アプリカードの金額単位（円）用スタイル
  ///
  /// 【使用箇所】
  /// - ファイル: income_graph_area.dart
  ///   - エリア: グラフ上部金額単位
  ///   - 詳細: 「円」表示
  static TextStyle appCardPriceUnit = GoogleFonts.notoSans(
    fontSize: 16,
    color: MyColors.white,
    fontWeight: FontWeight.w600,
  );

  /// アプリカードのグラフラベル用スタイル
  ///
  /// 【使用箇所】
  /// - ファイル: income_graph_area.dart
  ///   - エリア: 円グラフ内ラベル
  ///   - 詳細: カテゴリー名と割合表示
  static TextStyle appCardGraphLabel = GoogleFonts.notoSans(
    fontSize: 11,
    color: MyColors.white,
    fontWeight: FontWeight.w600,
  );

  /// アプリカードのセカンダリタイトルラベル用スタイル
  ///
  /// 【使用箇所】
  /// - ファイル: income_graph_area.dart
  ///   - エリア: カテゴリー別リスト
  ///   - 詳細: カテゴリー名表示
  static TextStyle appCardSecondaryTitleLabel = GoogleFonts.notoSans(
    fontSize: 14,
    color: MyColors.white,
    fontWeight: FontWeight.w500,
  );

  /// アプリカードのセカンダリ金額ラベル用スタイル
  ///
  /// 【使用箇所】
  /// - ファイル: income_graph_area.dart
  ///   - エリア: カテゴリー別リスト
  ///   - 詳細: カテゴリー別金額表示
  static TextStyle appCardSecondaryPriceLabel = GoogleFonts.notoSans(
    fontSize: 16,
    color: MyColors.white,
    fontWeight: FontWeight.w500,
  );

  /// アプリカードのセカンダリ金額単位（円）用スタイル
  ///
  /// 【使用箇所】
  /// - ファイル: income_graph_area.dart
  ///   - エリア: カテゴリー別リスト
  ///   - 詳細: 「円」表示
  static TextStyle appCardSecondaryPriceUnit = GoogleFonts.notoSans(
    fontSize: 12,
    color: MyColors.white,
    fontWeight: FontWeight.w500,
  );

  /// ポップアップメニューアイテムのラベルスタイル
  ///
  /// 【使用箇所】
  /// - ファイル: checkable_popup_menu_item.dart
  ///   - エリア: メニューアイテム
  ///   - 詳細: 選択状態に応じて太字になるスタイル
  static TextStyle popupMenuItemLabel(
      {Color? textColor, bool isSelected = false}) {
    return GoogleFonts.notoSans(
      color: textColor ?? MyColors.white,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    );
  }
}
