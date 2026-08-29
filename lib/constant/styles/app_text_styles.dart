import 'package:flutter/material.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/constant/font_style.dart';

/// ============================================================================
/// アプリ全般で共通して使用するTextStyleを定義
/// ウェイト階層（ADR-017 #4）: 主要金額 w700 ／ 行金額・主要ラベル w500〜w600 ／ 補助文字 w300
/// ============================================================================
class AppTextStyles {
  // ==========================================================================
  // ページヘッダー
  // ==========================================================================

  /// ページタイトル用のスタイル
  static final TextStyle pageHeaderText = MyFontStyle.notoSans.copyWith(
    color: AppColorsDark.text,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  /// ページヘッダーのサブテキスト用スタイル（補足情報）
  static final TextStyle pageHeaderSubText = MyFontStyle.notoSans.copyWith(
    color: AppColorsDark.textSecondary,
    fontSize: 11,
    fontWeight: FontWeight.w300,
  );

  /// ページ本文先頭に置く対象名（支払い履歴ページの固定費名など）
  static final TextStyle pageSubjectTitle = MyFontStyle.notoSans.copyWith(
    color: AppColorsDark.text,
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  // ==========================================================================
  // ダイアログ
  // ==========================================================================

  /// ダイアログタイトル用スタイル
  static final TextStyle dialogTitle = MyFontStyle.notoSans.copyWith(
    fontSize: 18,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w500,
  );

  /// ステッパー（集計期間設定ページ）の選択中の数値用スタイル
  static final TextStyle stepperValueLabel = MyFontStyle.sfUi.copyWith(
    fontSize: 32,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w600,
  );

  /// ダイアログ内文言用スタイル
  static final TextStyle dialogLabel = MyFontStyle.notoSans.copyWith(
    fontSize: 13,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w400,
  );

  /// メニューダイアログ内リスト項目用スタイル
  static final TextStyle dialogList = MyFontStyle.notoSans.copyWith(
    fontSize: 16,
    color: AppColorsDark.text,
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
    color: AppColorsDark.primary,
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
    color: AppColorsDark.textSecondary,
    fontWeight: FontWeight.w300,
  );

  // ==========================================================================
  // ボタン
  // ==========================================================================

  /// ボタン用テキストスタイル
  ///
  /// 【使用箇所】
  /// - MainButton/SubButton（Primary/Secondary/Destructive）のラベル、
  ///   ダイアログのキャンセルボタン等、ボタンラベル全般
  static final TextStyle mainButtonText = MyFontStyle.notoSans.copyWith(
    fontSize: 14,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w600,
  );

  /// 一行ボタン用のテキスト
  ///
  static final TextStyle oneLineButtonText = MyFontStyle.notoSans.copyWith(
    fontSize: 13,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w500,
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
    color: AppColorsDark.textSecondary,
    fontWeight: FontWeight.w400,
  );

  /// エラーメッセージスタイル
  ///
  /// [listEmptyMessage]（空状態）とは意味的に分離し、ADR-018の失敗トーストと同じ
  /// danger色で「異常」を伝える（空状態は情報が無いだけなのでtextSecondaryのまま）。
  ///
  /// 【使用箇所】
  /// - ページ: 各ページ
  ///   - エリア: メインコンテンツ
  ///   - 詳細: エラー発生時の表示（AppErrorState）
  static final TextStyle errorMessage = MyFontStyle.notoSans.copyWith(
    fontSize: 16,
    color: AppColorsDark.danger,
    fontWeight: FontWeight.w400,
  );

  /// 白文字ボタン用テキストスタイル
  ///
  /// 【使用箇所】
  /// - 現在未使用（将来の拡張用）
  static final TextStyle whiteButtonText = MyFontStyle.notoSans.copyWith(
    fontSize: 17,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w600,
  );

  // ==========================================================================
  // サブヘッダー系
  // ==========================================================================

  /// カードヘッダー用スタイル
  static final TextStyle appCardSectionTitle = MyFontStyle.notoSans.copyWith(
    fontSize: 16,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w600,
  );

  /// リストカードのヘッダー
  static final TextStyle listCardSectionTitle = MyFontStyle.sfUi.copyWith(
    fontSize: 14,
    color: AppColorsDark.textSecondary,
    fontWeight: FontWeight.w600,
  );

  /// リストタイルのセクションヘッダー
  static final TextStyle listTileSectionTitle = MyFontStyle.sfUi.copyWith(
    fontSize: 13,
    color: AppColorsDark.textSecondary,
    fontWeight: FontWeight.w500,
  );

  // ==========================================================================
  // リストタイル（汎用）
  // ==========================================================================

  /// リストタイル・リストカードのメインタイトル用スタイル
  static final TextStyle listTilePrimaryTitle = MyFontStyle.notoSans.copyWith(
    fontSize: 14,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w500,
  );

  /// リストタイルのサブタイトル用スタイル
  static final TextStyle listTileSecondaryTitle = MyFontStyle.notoSans.copyWith(
    fontSize: 13,
    color: AppColorsDark.textSecondary,
    fontWeight: FontWeight.w300,
  );

  /// リストタイルの第三階層ラベル用スタイル
  static final TextStyle listTileTirtiaryTitle = MyFontStyle.notoSans.copyWith(
    fontSize: 11,
    color: AppColorsDark.textSecondary,
    fontWeight: FontWeight.w300,
  );

  /// リスト行の金額表示用スタイル（履歴タイル・リストカードの行金額）
  static final TextStyle listTilePriceLabel = MyFontStyle.sfUi.copyWith(
    fontSize: 17,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w600,
  );

  /// カード内金額表示用Secondaryスタイル
  static final TextStyle listTileSubPriceLabel = MyFontStyle.sfUi.copyWith(
    fontSize: 15,
    color: AppColorsDark.textSecondary,
    fontWeight: FontWeight.w400,
  );

  /// 入力フィールド用スタイル
  static final TextStyle listTileInputPriceLabel = MyFontStyle.sfUi.copyWith(
    fontSize: 19,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w500,
  );

  /// 入力フィールドのヒントテキスト
  static final TextStyle listTileTextFieldHint = MyFontStyle.notoSans.copyWith(
    fontSize: 15,
    color: AppColorsDark.textTertiary,
    fontWeight: FontWeight.w600,
  );

  /// カード内未確定金額用スタイル
  static final TextStyle listTileUnconfirmedPriceLabel = MyFontStyle.notoSans
      .copyWith(
        fontSize: 15,
        color: AppColorsDark.text,
        fontWeight: FontWeight.w500,
      );

  /// リスト行の凡例・補足テキスト用（列見出しラベル・ナビゲーション行の件数表示等）
  static final TextStyle listTileLegendTitle = MyFontStyle.notoSans.copyWith(
    fontSize: 14,
    color: AppColorsDark.textSecondary,
    fontWeight: FontWeight.w300,
  );

  // ==========================================================================
  // リストカード内スタイル
  // ==========================================================================

  /// リストカード内未確定金額ラベルスタイル
  static final TextStyle listCardUnconfirmedPriceLabel = MyFontStyle.notoSans
      .copyWith(
        fontSize: 14,
        color: AppColorsDark.text,
        fontWeight: FontWeight.w700,
      );

  /// 予算行に併記する固定費見込みラベル（「固定費 ¥1,980」）
  static final TextStyle budgetFixedCostForecastLabel = MyFontStyle.notoSans
      .copyWith(
        fontSize: 11,
        color: AppColorsDark.textSecondary,
        fontWeight: FontWeight.w400,
      );

  /// チップ（「固定費」等）のラベル用スタイル
  static final TextStyle chipLabel = MyFontStyle.notoSans.copyWith(
    fontSize: 10,
    color: AppColorsDark.textSecondary,
    fontWeight: FontWeight.w400,
    // チップの塗り内で文字を垂直中央に置く（フォント既定の行高だと下寄りに見える）
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// チップの強調ラベル（固定費一覧の「変動」チップ）
  static final TextStyle chipLabelAccent = MyFontStyle.notoSans.copyWith(
    fontSize: 10,
    color: AppColorsDark.primary,
    fontWeight: FontWeight.w500,
    // チップの塗り内で文字を垂直中央に置く（フォント既定の行高だと下寄りに見える）
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static final TextStyle listCardSecondaryTitle = MyFontStyle.notoSans.copyWith(
    fontSize: 12,
    color: AppColorsDark.textSecondary,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle listCardMinusLabel = MyFontStyle.sfUi.copyWith(
    fontSize: 16,
    color: AppColorsDark.expense,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle listCardPlusLabel = MyFontStyle.sfUi.copyWith(
    fontSize: 16,
    color: AppColorsDark.income,
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
    color: AppColorsDark.textSecondary,
    fontWeight: FontWeight.w500,
  );

  /// アプリカードのメインタイトルラベル用スタイル
  /// （収支カードの総支出/総収入など、白・強調）
  ///
  /// height/leadingDistribution で行ボックス内のグリフを上下中央に寄せ、
  /// 隣接するシェブロンアイコンと縦位置が揃うようにする
  static final TextStyle appCardPrimaryTitleLabel = MyFontStyle.notoSans
      .copyWith(
        fontSize: 16,
        color: AppColorsDark.text,
        fontWeight: FontWeight.w600,
        height: 1.0,
        leadingDistribution: TextLeadingDistribution.even,
      );

  /// アプリカードの金額表示用スタイル
  static final TextStyle appCardPriceLabel = MyFontStyle.sfUi.copyWith(
    fontSize: 20,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w700,
  );

  /// 帯付きサマリーカードの帯に置く合計金額用スタイル（収入一覧・支出一覧とそのカテゴリー明細）
  static final TextStyle summaryHeroPriceLabel = MyFontStyle.sfUi.copyWith(
    fontSize: 22,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w700,
  );

  /// Secondary=========

  /// アプリカードのセカンダリ金額ラベル用スタイル
  static final TextStyle appCardSecondaryPriceLabel = MyFontStyle.sfUi.copyWith(
    fontSize: 16,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w500,
  );

  /// Tertiary=========

  /// アプリカードのTertiaryタイトルラベル用スタイル
  static final TextStyle appCardTertiaryTitleLabel = MyFontStyle.notoSans
      .copyWith(
        fontSize: 13,
        color: AppColorsDark.textSecondary,
        fontWeight: FontWeight.w500,
      );

  /// アプリカードのTertiary金額ラベル用スタイル
  static final TextStyle appCardTertiaryPriceLabel = MyFontStyle.sfUi.copyWith(
    fontSize: 14,
    color: AppColorsDark.textSecondary,
    fontWeight: FontWeight.w500,
  );

  /// アプリカードのTertiary金額単位（円）用スタイル
  static final TextStyle appCardTertiaryPriceUnit = MyFontStyle.notoSans
      .copyWith(
        fontSize: 11,
        color: AppColorsDark.textSecondary,
        fontWeight: FontWeight.w500,
      );

  /// OptionalSecondary=========

  /// アプリカードのセカンダリ金額ラベル用スタイル
  static final TextStyle appCardOptionalSecondaryPriceLabel = MyFontStyle.sfUi
      .copyWith(
        fontSize: 18,
        color: AppColorsDark.text,
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
    color: AppColorsDark.text,
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
      color: textColor ?? AppColorsDark.text,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    );
  }

  // ==========================================================================
  // テキストボタン ("さらに表示する"など)
  // ==========================================================================
  static final TextStyle textButtonTextStyle = MyFontStyle.notoSans.copyWith(
    fontSize: 12,
    color: AppColorsDark.primary,
    fontWeight: FontWeight.w500,
  );

  // ==========================================================================
  // ボトムナビゲーションバー
  // ==========================================================================

  /// グロナビ選択中ラベル（白・視認性確保）
  static final TextStyle bottomNavSelectedLabel = MyFontStyle.notoSans.copyWith(
    fontSize: 11,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w600,
  );

  /// グロナビ非選択ラベル
  static final TextStyle bottomNavUnselectedLabel = MyFontStyle.notoSans.copyWith(
    fontSize: 11,
    color: AppColorsDark.textSecondary,
    fontWeight: FontWeight.w500,
  );

  // ==========================================================================
  // インセットグループ（AppInsetGroup / AppInsetRow）
  // ==========================================================================

  /// インセットグループの見出し（「固定費」「設定」など）
  static final TextStyle insetGroupHeader = MyFontStyle.notoSans.copyWith(
    fontSize: 13,
    color: AppColorsDark.textSecondary,
    fontWeight: FontWeight.w500,
  );

  /// インセットグループ内の行ラベル（「拠出元」「頻度」など）
  static final TextStyle insetGroupLabel = MyFontStyle.notoSans.copyWith(
    fontSize: 14,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w500,
  );

  /// インセットグループ内の行の値（右寄せの選択値・入力値）
  static final TextStyle insetGroupValue = MyFontStyle.notoSans.copyWith(
    fontSize: 15,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w500,
  );

  /// インセットグループ内の行の値のプレースホルダー（未入力時）
  static final TextStyle insetGroupPlaceholder = MyFontStyle.notoSans.copyWith(
    fontSize: 15,
    color: AppColorsDark.textTertiary,
    fontWeight: FontWeight.w500,
  );

  /// インセットグループの下に添える補足文（操作の結果を説明する1〜2行）
  static final TextStyle insetGroupNote = MyFontStyle.notoSans.copyWith(
    fontSize: 11,
    color: AppColorsDark.textSecondary,
    fontWeight: FontWeight.w300,
  );

  /// インセットグループ内の支払い履歴行の日付
  static final TextStyle insetGroupHistoryDate = MyFontStyle.notoSans.copyWith(
    fontSize: 13,
    color: AppColorsDark.textSecondary,
    fontWeight: FontWeight.w400,
  );

  /// インセットグループ内の支払い履歴行の金額
  static final TextStyle insetGroupHistoryPrice = MyFontStyle.sfUi.copyWith(
    fontSize: 15,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w500,
  );

  /// インセットグループ末尾のリンク行（「すべての支払いを見る」）
  static final TextStyle insetGroupLinkRow = MyFontStyle.notoSans.copyWith(
    fontSize: 12,
    color: AppColorsDark.primary,
    fontWeight: FontWeight.w500,
  );

  // ==========================================================================
  // ボトムシート（予想額の入力シートなど）
  // ==========================================================================

  /// ボトムシートの見出し（「予想額」など）
  static final TextStyle sheetTitle = MyFontStyle.notoSans.copyWith(
    fontSize: 16,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w600,
  );

  /// ボトムシートの金額入力（大きい数値）
  static final TextStyle sheetPriceInput = MyFontStyle.sfUi.copyWith(
    fontSize: 40,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w700,
    height: 1.0,
  );

  /// ボトムシートの金額入力に添える円記号
  static final TextStyle sheetPriceYenSymbol = MyFontStyle.sfUi.copyWith(
    fontSize: 28,
    color: AppColorsDark.textSecondary,
    fontWeight: FontWeight.w700,
    height: 1.0,
  );

  // ==========================================================================
  // セグメンテッドコントロール（AppSegmentedControl）
  // ==========================================================================

  /// 未選択セグメントのラベル
  static final TextStyle segmentedLabel = MyFontStyle.notoSans.copyWith(
    fontSize: 14,
    color: AppColorsDark.textSecondary,
    fontWeight: FontWeight.w400,
  );

  /// 選択中セグメントのラベル
  static final TextStyle segmentedSelectedLabel = MyFontStyle.notoSans.copyWith(
    fontSize: 14,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w600,
  );
}
