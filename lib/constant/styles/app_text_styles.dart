import 'package:flutter/material.dart';
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
  static final TextStyle pageHeaderText = MyFontStyle.notoSans.copyWith(
    color: MyColors.white,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  /// ページヘッダーのサブテキスト用スタイル（補足情報）
  static final TextStyle pageHeaderSubText = MyFontStyle.notoSans.copyWith(
    color: MyColors.secondaryLabel,
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  // ==========================================================================
  // ダイアログ
  // ==========================================================================

  /// ダイアログタイトル用スタイル
  static final TextStyle dialogTitle = MyFontStyle.notoSans.copyWith(
    fontSize: 18,
    color: MyColors.white,
    fontWeight: FontWeight.w500,
  );

  /// ダイアログ内文言用スタイル
  static final TextStyle dialogLabel = MyFontStyle.notoSans.copyWith(
    fontSize: 13,
    color: MyColors.white,
    fontWeight: FontWeight.w400,
  );

  /// メニューダイアログ内リスト項目用スタイル
  static final TextStyle dialogList = MyFontStyle.notoSans.copyWith(
    fontSize: 16,
    color: MyColors.white,
    fontWeight: FontWeight.w500,
  );

  // ==========================================================================
  // タブ
  // ==========================================================================

  /// 選択中タブラベル用スタイル
  ///
  /// 【使用箇所】
  /// - ファイル: app_component.dart (AppTab共通コンポーネント)
  ///   - エリア: TabBar
  ///   - 詳細: 選択されているタブのテキストスタイル
  static final TextStyle selectedLabelStyle = MyFontStyle.notoSans.copyWith(
    fontSize: 14,
    color: MyColors.themeColor,
    fontWeight: FontWeight.w600,
  );

  /// 非選択タブラベル用スタイル
  ///
  /// 【使用箇所】
  /// - ファイル: app_component.dart (AppTab共通コンポーネント)
  ///   - エリア: TabBar
  ///   - 詳細: 選択されていないタブのテキストスタイル
  static final TextStyle unselectedLabelStyle = MyFontStyle.notoSans.copyWith(
    fontSize: 14,
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w300,
  );

  // ==========================================================================
  // ボタン
  // ==========================================================================

  /// メインボタン用テキストスタイル
  ///
  /// 【使用箇所】
  /// - 現在未使用（将来の拡張用、MainButtonコンポーネント内で使用予定）
  static final TextStyle mainButtonText = MyFontStyle.notoSans.copyWith(
    fontSize: 14,
    color: MyColors.label,
    fontWeight: FontWeight.w600,
  );

  /// サブボタン用テキストスタイル
  static final TextStyle subButtonText = MyFontStyle.notoSans.copyWith(
    color: MyColors.themeColor,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  /// 一行ボタン用のテキスト
  ///
  static final TextStyle oneLineButtonText = MyFontStyle.notoSans.copyWith(
    fontSize: 13,
    color: MyColors.label,
    fontWeight: FontWeight.w500,
  );

  /// 一行ボタン用のサブテキスト
  ///
  static final TextStyle oneLineButtonSubText = MyFontStyle.notoSans.copyWith(
    fontSize: 14,
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w400,
  );

  // ==========================================================================
  // リスト共通
  // ==========================================================================

  /// 空のリスト用メッセージスタイル
  ///
  /// 【使用箇所】
  /// - ページ: 各リストページ
  ///   - エリア: メインコンテンツ
  ///   - 詳細: データがない場合の表示
  static final TextStyle listEmptyMessage = MyFontStyle.notoSans.copyWith(
    fontSize: 16,
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w400,
  );

  /// エラーメッセージスタイル
  ///
  /// 【使用箇所】
  /// - ページ: 各ページ
  ///   - エリア: メインコンテンツ
  ///   - 詳細: エラー発生時の表示
  static final TextStyle errorMessage = MyFontStyle.notoSans.copyWith(
    fontSize: 16,
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w400,
  );

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
  static final TextStyle secondaryButtonText = MyFontStyle.notoSans.copyWith(
    fontSize: 14,
    color: MyColors.label,
    fontWeight: FontWeight.w600,
  );

  /// 白文字ボタン用テキストスタイル
  ///
  /// 【使用箇所】
  /// - 現在未使用（将来の拡張用）
  static final TextStyle whiteButtonText = MyFontStyle.notoSans.copyWith(
    fontSize: 17,
    color: MyColors.white,
    fontWeight: FontWeight.w600,
  );

  // ==========================================================================
  // サブヘッダー系
  // ==========================================================================

  /// カードヘッダー用スタイル
  static final TextStyle appCardSectionTitle = MyFontStyle.notoSans.copyWith(
    fontSize: 16,
    color: MyColors.label,
    fontWeight: FontWeight.w600,
  );

  /// リストカードのヘッダー
  static final TextStyle listCardSectionTitle = MyFontStyle.sfUi.copyWith(
    fontSize: 14,
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w600,
  );

  /// リストタイルのセクションヘッダー
  static final TextStyle listTileSectionTitle = MyFontStyle.sfUi.copyWith(
    fontSize: 13,
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w500,
  );

  // ==========================================================================
  // リストタイル（汎用）
  // ==========================================================================

  /// リストタイルのメインタイトル用スタイル
  static final TextStyle listTilePrimaryTitle = MyFontStyle.notoSans.copyWith(
    fontSize: 14,
    color: MyColors.label,
    fontWeight: FontWeight.w500,
  );

  /// カードのサブタイトル用スタイル
  static final TextStyle listTileSecondaryTitle = MyFontStyle.notoSans.copyWith(
    fontSize: 13,
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w400,
  );

  /// カードのサブタイトル用スタイル
  static final TextStyle listTileTirtiaryTitle = MyFontStyle.notoSans.copyWith(
    fontSize: 11,
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w400,
  );

  /// カード内金額表示用スタイル
  static final TextStyle listTilePriceLabel = MyFontStyle.sfUi.copyWith(
    fontSize: 17,
    color: MyColors.label,
    fontWeight: FontWeight.w500,
  );

  /// カード内金額表示用Secondaryスタイル
  static final TextStyle listTileSubPriceLabel = MyFontStyle.sfUi.copyWith(
    fontSize: 15,
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w400,
  );

  /// 入力フィールド用スタイル
  static final TextStyle listTileInputPriceLabel = MyFontStyle.sfUi.copyWith(
    fontSize: 19,
    color: MyColors.label,
    fontWeight: FontWeight.w500,
  );

  /// 入力フィールドのヒントテキスト
  static final TextStyle listTileTextFieldHint = MyFontStyle.notoSans.copyWith(
    fontSize: 15,
    color: MyColors.tirtiaryLabel,
    fontWeight: FontWeight.w600,
  );

  /// カード内未確定金額用スタイル
  static final TextStyle listTileUnconfirmedPriceLabel = MyFontStyle.notoSans
      .copyWith(
        fontSize: 15,
        color: MyColors.label,
        fontWeight: FontWeight.w500,
      );

  /// 金額単位表示「円」
  static final TextStyle listTileYenLabel = MyFontStyle.notoSans.copyWith(
    fontSize: 12,
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w500,
  );

  /// カードの凡例タイトル用
  static final TextStyle listTileLegendTitle = MyFontStyle.notoSans.copyWith(
    fontSize: 14,
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w400,
  );

  // ==========================================================================
  // リストカード内スタイル
  // ==========================================================================

  /// リストカード内タイトルラベルスタイル
  static final TextStyle listCardTitleLabel = MyFontStyle.notoSans.copyWith(
    color: MyColors.label,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  /// リストカード内タイトルラベルスタイル
  static final TextStyle listCardUnconfirmedPriceLabel = MyFontStyle.notoSans
      .copyWith(
        fontSize: 14,
        color: MyColors.label,
        fontWeight: FontWeight.w700,
      );

  static final TextStyle listCardSecondaryTitle = MyFontStyle.notoSans.copyWith(
    fontSize: 12,
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle listCardMinusLabel = MyFontStyle.sfUi.copyWith(
    fontSize: 16,
    color: MyColors.pink,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle listCardPlusLabel = MyFontStyle.sfUi.copyWith(
    fontSize: 16,
    color: MyColors.incomeEmerald,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle listCardPriceLabel = MyFontStyle.sfUi.copyWith(
    fontSize: 17,
    color: MyColors.label,
    fontWeight: FontWeight.w600,
  );

  // ==========================================================================
  // アプリカード（収入グラフエリアなど）
  // ページヘッダー（固定費ページなど）
  // ==========================================================================

  /// Primary=========

  /// アプリカードのタイトルラベル用スタイル
  static final TextStyle appCardTitleLabel = MyFontStyle.notoSans.copyWith(
    fontSize: 14,
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w500,
  );

  /// アプリカードの金額表示用スタイル
  static final TextStyle appCardPriceLabel = MyFontStyle.sfUi.copyWith(
    fontSize: 20,
    color: MyColors.white,
    fontWeight: FontWeight.w600,
  );

  /// アプリカードの金額単位（円）用スタイル
  static final TextStyle appCardPriceUnit = MyFontStyle.notoSans.copyWith(
    fontSize: 13,
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w500,
  );

  /// Secondary=========

  /// アプリカードのセカンダリタイトルラベル用スタイル
  static final TextStyle appCardSecondaryTitleLabel = MyFontStyle.notoSans
      .copyWith(
        fontSize: 14,
        color: MyColors.white,
        fontWeight: FontWeight.w500,
      );

  /// アプリカードのセカンダリ金額ラベル用スタイル
  static final TextStyle appCardSecondaryPriceLabel = MyFontStyle.sfUi.copyWith(
    fontSize: 16,
    color: MyColors.white,
    fontWeight: FontWeight.w500,
  );

  /// アプリカードのセカンダリ金額単位（円）用スタイル
  static final TextStyle appCardSecondaryPriceUnit = MyFontStyle.notoSans
      .copyWith(
        fontSize: 10,
        color: MyColors.secondaryLabel,
        fontWeight: FontWeight.w500,
      );

  /// Tertiary=========

  /// アプリカードのTertiaryタイトルラベル用スタイル
  static final TextStyle appCardTertiaryTitleLabel = MyFontStyle.notoSans
      .copyWith(
        fontSize: 13,
        color: MyColors.secondaryLabel,
        fontWeight: FontWeight.w500,
      );

  /// アプリカードのTertiary金額ラベル用スタイル
  static final TextStyle appCardTertiaryPriceLabel = MyFontStyle.sfUi.copyWith(
    fontSize: 14,
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w500,
  );

  /// アプリカードのTertiary金額単位（円）用スタイル
  static final TextStyle appCardTertiaryPriceUnit = MyFontStyle.notoSans
      .copyWith(
        fontSize: 11,
        color: MyColors.secondaryLabel,
        fontWeight: FontWeight.w500,
      );

  /// OptionalSecondary=========

  /// アプリカードのセカンダリ金額ラベル用スタイル
  static final TextStyle appCardOptionalSecondaryPriceLabel = MyFontStyle.sfUi
      .copyWith(
        fontSize: 18,
        color: MyColors.white,
        fontWeight: FontWeight.w500,
      );

  // ==========================================================================
  // その他
  // ==========================================================================

  /// アプリカードのグラフラベル用スタイル
  ///
  /// 【使用箇所】
  /// - ファイル: income_graph_area.dart
  ///   - エリア: 円グラフ内ラベル
  ///   - 詳細: カテゴリー名と割合表示
  static final TextStyle appCardGraphLabel = MyFontStyle.notoSans.copyWith(
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
  static TextStyle popupMenuItemLabel({
    Color? textColor,
    bool isSelected = false,
  }) {
    return MyFontStyle.notoSans.copyWith(
      fontSize: 14,
      color: textColor ?? MyColors.label,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    );
  }

  // ==========================================================================
  // テキストボタン ("さらに表示する"など)
  // ==========================================================================
  static final TextStyle textButtonTextStyle = MyFontStyle.notoSans.copyWith(
    fontSize: 12,
    color: MyColors.themeColor,
    fontWeight: FontWeight.w500,
  );

  // ==========================================================================
  // ボトムナビゲーションバー
  // ==========================================================================

  /// グロナビ選択中ラベル（白・視認性確保）
  static final TextStyle bottomNavSelectedLabel = MyFontStyle.notoSans.copyWith(
    fontSize: 11,
    color: MyColors.white,
    fontWeight: FontWeight.w600,
  );

  /// グロナビ非選択ラベル
  static final TextStyle bottomNavUnselectedLabel = MyFontStyle.notoSans.copyWith(
    fontSize: 11,
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w500,
  );
}
