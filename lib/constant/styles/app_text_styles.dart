import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/font_style.dart';

/// ============================================================================
/// アプリ全般で共通して使用するTextStyleを定義
/// ============================================================================
class AppTextStyles {
  // ==========================================================================
  // ページヘッダー
  // ==========================================================================

  /// ページタイトル用のスタイル
  static TextStyle pageHeaderText = const TextStyle(
    color: MyColors.white,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    fontFamily: 'noto_sans',
  );

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

  /// 一行ボタン用のテキスト
  ///
  static TextStyle oneLineButtonText = GoogleFonts.notoSans(
      fontSize: 14, color: MyColors.label, fontWeight: FontWeight.w400);

  /// 一行ボタン用のサブテキスト
  ///
  static TextStyle oneLineButtonSubText = GoogleFonts.notoSans(
      fontSize: 14,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w400);

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
  // セクションタイトル
  // ==========================================================================

  /// カードセクションタイトル用スタイル
  static TextStyle cardSectionTitle = const TextStyle(
    color: MyColors.label,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: 'noto_sans',
  );

  /// 固定費一覧ションサブタイトル用スタイル(他に利用するなら名前を変更)
  static TextStyle fixedCostSectionSubTitle = const TextStyle(
    color: MyColors.label,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: 'noto_sans',
  );

  // ==========================================================================
  // リストタイル（汎用）
  // ==========================================================================

  /// リストタイルのメインタイトル用スタイル
  static TextStyle listTilePrimaryTitle = MyFontStyle.notoSans.copyWith(
      fontSize: 16, color: MyColors.label, fontWeight: FontWeight.w300);

  /// カードのサブタイトル用スタイル
  static TextStyle listTileSecondaryTitle = MyFontStyle.notoSans.copyWith(
      fontSize: 12,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w300);

  /// マイナス金額ラベル用スタイル（ミントブルー）
  static TextStyle listTileMinusLabel = MyFontStyle.sfUi.copyWith(
      fontSize: 16, color: MyColors.mintBlue, fontWeight: FontWeight.w600);

  /// プラス金額ラベル用スタイル（ピンク）
  static TextStyle listTilePlusLabel = MyFontStyle.sfUi.copyWith(
      fontSize: 16, color: MyColors.pink, fontWeight: FontWeight.w600);

  /// カード内金額表示用スタイル
  static TextStyle listTilePriceLabel = MyFontStyle.sfUi.copyWith(
      fontSize: 19, color: MyColors.label, fontWeight: FontWeight.w600);

  // ==========================================================================
  // リストカード内スタイル
  // ==========================================================================

  /// リストカード内タイトルラベルスタイル
  ///
  static TextStyle listCardTitleLabel = MyFontStyle.notoSans.copyWith(
    color: MyColors.label,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static TextStyle listCardSecondaryTitle = MyFontStyle.notoSans.copyWith(
      fontSize: 12,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w300);

  static TextStyle listCardMinusLabel = MyFontStyle.sfUi.copyWith(
      fontSize: 16, color: MyColors.pink, fontWeight: FontWeight.w600);

  static TextStyle listCardPlusLabel = MyFontStyle.sfUi.copyWith(
      fontSize: 16, color: MyColors.mintBlue, fontWeight: FontWeight.w600);

  static TextStyle listCardPriceLabel = MyFontStyle.sfUi.copyWith(
      fontSize: 19, color: MyColors.label, fontWeight: FontWeight.w600);

  // ==========================================================================
  // アプリカード（収入グラフエリアなど）
  // ==========================================================================

  /// Primary=========

  /// アプリカードのタイトルラベル用スタイル
  static TextStyle appCardTitleLabel = GoogleFonts.notoSans(
    fontSize: 14,
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w500,
  );

  /// アプリカードの金額表示用スタイル
  static TextStyle appCardPriceLabel = GoogleFonts.notoSans(
    fontSize: 20,
    color: MyColors.white,
    fontWeight: FontWeight.w600,
  );

  /// アプリカードの金額単位（円）用スタイル
  static TextStyle appCardPriceUnit = GoogleFonts.notoSans(
    fontSize: 16,
    color: MyColors.white,
    fontWeight: FontWeight.w600,
  );

  /// Secondary=========

  /// アプリカードのセカンダリタイトルラベル用スタイル
  static TextStyle appCardSecondaryTitleLabel = GoogleFonts.notoSans(
    fontSize: 14,
    color: MyColors.white,
    fontWeight: FontWeight.w500,
  );

  /// アプリカードのセカンダリ金額ラベル用スタイル
  static TextStyle appCardSecondaryPriceLabel = GoogleFonts.notoSans(
    fontSize: 16,
    color: MyColors.white,
    fontWeight: FontWeight.w500,
  );

  /// アプリカードのセカンダリ金額単位（円）用スタイル
  static TextStyle appCardSecondaryPriceUnit = GoogleFonts.notoSans(
    fontSize: 12,
    color: MyColors.white,
    fontWeight: FontWeight.w500,
  );

  /// Tertiary=========

  /// アプリカードのTertiaryタイトルラベル用スタイル
  static TextStyle appCardTertiaryTitleLabel = GoogleFonts.notoSans(
      fontSize: 13,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w400);

  /// アプリカードのTertiary金額ラベル用スタイル
  static TextStyle appCardTertiaryPriceLabel = GoogleFonts.notoSans(
      fontSize: 14,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w400);

  /// アプリカードのTertiary金額単位（円）用スタイル
  static TextStyle appCardTertiaryPriceUnit = GoogleFonts.notoSans(
      fontSize: 11,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w400);

  /// OptionalSecondary=========

  /// アプリカードのセカンダリ金額ラベル用スタイル
  static TextStyle appCardOptionalSecondaryPriceLabel = GoogleFonts.notoSans(
      fontSize: 18, color: MyColors.white, fontWeight: FontWeight.w400);

  /// アプリカードのセカンダリ金額単位（円）用スタイル
  static TextStyle appCardOptionalSecondaryPriceUnit = GoogleFonts.notoSans(
      fontSize: 14, color: MyColors.white, fontWeight: FontWeight.w400);

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

  // ==========================================================================
  // テキストボタン ("さらに表示する"など)
  // ==========================================================================
  static TextStyle textButtonTextStyle =
      const TextStyle(color: MyColors.themeColor, fontSize: 14);
}
