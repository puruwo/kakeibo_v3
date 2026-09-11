import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_type_scale.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// ============================================================================
/// アプリ全般で共通して使用する役割スタイル
///
/// - 値（family × size × weight）は AppTypeScale の段を参照し、ここでは色と height だけ付ける
/// - 色は AppColors（ライト／ダークのトークン）から取る。呼び出し側は `context.textStyles.<名前>` で
///   現在のテーマの色が入ったスタイルを受け取る（KP-013）。状態色を当てるときは
///   `.copyWith(color: context.colors.<token>)` のみ許可（寸法・ウェイトの上書きは禁止）
/// - 同じ役割の別名を作らない。値が同じでも役割が違えば別名でよい
/// - 運用ルールの正本: Vault「Kakeibo テキストスタイルルール」（ウェイトの目安もそちら。ここに複製しない）
/// - w300 は使わない（ダーク背景の小さな文字で細すぎる。ADR-017 #4 を KP-007 で改定）
/// ============================================================================
class AppTextStyles {
  /// [colors] は現在のテーマの色トークン。通常は `context.textStyles` 経由で受け取る
  const AppTextStyles(this.colors);

  /// 役割スタイルの色の出どころ（ライト／ダークで値が変わる）
  final AppColors colors;

  /// context 無しに使う固定インスタンス（テストの期待値・Painter への注入元）
  static const AppTextStyles light = AppTextStyles(AppColors.light);
  static const AppTextStyles dark = AppTextStyles(AppColors.dark);

  // ==========================================================================
  // ページヘッダー
  // ==========================================================================

  /// ページタイトル（AppBar）
  TextStyle get pageHeaderText =>
      AppTypeScale.noto18w500.copyWith(color: colors.text);

  /// 数字が主役のページタイトル（期間「2026年 8月」「2026年4月 - 2027年3月」・年月ピッカーの年／月度）
  TextStyle get pageHeaderNumeric =>
      AppTypeScale.sfUi18w500.copyWith(color: colors.text);

  /// ページヘッダーのサブテキスト（AppBar の2段目・補足情報）
  TextStyle get pageHeaderSubText =>
      AppTypeScale.noto12w400.copyWith(color: colors.textSecondary);

  /// 数字が主役のヘッダーサブテキスト（「2026年度」・年月ピッカーの見出し）
  TextStyle get pageHeaderSubNumeric =>
      AppTypeScale.sfUi12w400.copyWith(color: colors.textSecondary);

  /// ページ本文先頭に置く対象名（支払い履歴ページの固定費名など）
  TextStyle get pageSubjectTitle =>
      AppTypeScale.noto22w600.copyWith(color: colors.text);

  // ==========================================================================
  // ダイアログ・シート・設定
  // ==========================================================================

  /// ダイアログタイトル
  TextStyle get dialogTitle =>
      AppTypeScale.noto18w500.copyWith(color: colors.text);

  /// ダイアログ内文言
  TextStyle get dialogLabel =>
      AppTypeScale.noto13w400.copyWith(color: colors.text);

  /// ダイアログ内文言の強調（削除確認のタイトル）
  TextStyle get dialogLabelEmphasis =>
      AppTypeScale.noto13w600.copyWith(color: colors.text);

  /// メニュー（ActionSheet）の項目
  TextStyle get dialogList =>
      AppTypeScale.noto16w500.copyWith(color: colors.text);

  /// メニュー（ActionSheet）の強調項目（キャンセル・選択中の頻度）
  TextStyle get dialogListEmphasis =>
      AppTypeScale.noto16w600.copyWith(color: colors.text);

  /// ステッパー（集計期間設定ページ）の選択中の数値
  TextStyle get stepperValueLabel =>
      AppTypeScale.sfUi32w600.copyWith(color: colors.text);

  /// 設定ページ本文に置く独立した説明文・補助ラベル（13px。インセットグループ直下の補足は insetGroupNote）
  TextStyle get supportingText =>
      AppTypeScale.noto13w400.copyWith(color: colors.textSecondary);

  // ==========================================================================
  // タブ
  // ==========================================================================

  /// 選択中タブラベル（AppTab）
  TextStyle get selectedLabelStyle =>
      AppTypeScale.noto14w600.copyWith(color: colors.primary);

  /// 非選択タブラベル（AppTab）
  TextStyle get unselectedLabelStyle =>
      AppTypeScale.noto14w400.copyWith(color: colors.textSecondary);

  // ==========================================================================
  // ボタン・リンク
  // ==========================================================================

  /// ボタンラベル全般（MainButton / FAB・ダイアログのキャンセル等）
  TextStyle get mainButtonText =>
      AppTypeScale.noto14w600.copyWith(color: colors.text);

  /// 設定トップのメニュー行
  TextStyle get oneLineButtonText =>
      AppTypeScale.noto13w500.copyWith(color: colors.text);

  /// テキストボタン・リンク行（「さらに表示する」「すべての支払いを見る」等）
  TextStyle get textButtonTextStyle =>
      AppTypeScale.noto12w500.copyWith(color: colors.primary);

  // ==========================================================================
  // 状態メッセージ
  // ==========================================================================

  /// 空状態（AppEmptyState・プレーンテキストバー）
  TextStyle get listEmptyMessage =>
      AppTypeScale.noto16w400.copyWith(color: colors.textSecondary);

  /// エラー表示（AppErrorState）。空状態とは danger 色で意味的に分ける（ADR-018）
  TextStyle get errorMessage =>
      AppTypeScale.noto16w400.copyWith(color: colors.danger);

  /// スナックバーの文言（成功／失敗は呼び出し側で色を当てる）
  TextStyle get snackBarMessage =>
      AppTypeScale.noto14w400.copyWith(color: colors.text);

  // ==========================================================================
  // セクション見出し
  // ==========================================================================

  /// セクション見出し（AppContentsHeader 既定）
  TextStyle get appCardSectionTitle =>
      AppTypeScale.noto16w600.copyWith(color: colors.text);

  /// 数字が主役のセクション見出し（月別アコーディオンの「8月」「2027年1月」）
  TextStyle get appCardSectionNumeric =>
      AppTypeScale.sfUi16w600.copyWith(color: colors.text);

  /// リストカード見出し（AppContentsHeader.listCardSectionTitle・フィルター名。和文が主役）
  TextStyle get listCardSectionTitle =>
      AppTypeScale.noto14w600.copyWith(color: colors.textSecondary);

  /// 履歴一覧の日付見出し（yyyy年M月d日(E)）
  TextStyle get listTileSectionTitle =>
      AppTypeScale.sfUi13w500.copyWith(color: colors.textSecondary);

  // ==========================================================================
  // リストタイル
  // ==========================================================================

  /// 行・リストカードの主ラベル
  TextStyle get listTilePrimaryTitle =>
      AppTypeScale.noto14w500.copyWith(color: colors.text);

  /// 行の副ラベル
  TextStyle get listTileSecondaryTitle =>
      AppTypeScale.noto13w400.copyWith(color: colors.textSecondary);

  /// 行の第三階層ラベル（履歴タイルの小カテゴリー名・メモ等）
  TextStyle get listTileTertiaryTitle =>
      AppTypeScale.noto11w400.copyWith(color: colors.textSecondary);

  /// 行の金額（履歴タイル・リストカードの行金額）
  TextStyle get listTilePriceLabel =>
      AppTypeScale.sfUi17w600.copyWith(color: colors.text);

  /// 行の副金額
  TextStyle get listTileSubPriceLabel =>
      AppTypeScale.sfUi15w400.copyWith(color: colors.textSecondary);

  /// 行内の金額入力フィールド
  TextStyle get listTileInputPriceLabel =>
      AppTypeScale.sfUi19w500.copyWith(color: colors.text);

  /// 入力フィールドのヒントテキスト
  TextStyle get listTileTextFieldHint =>
      AppTypeScale.noto15w600.copyWith(color: colors.textTertiary);

  /// 未確定の金額欄（「---」「未入力」）
  TextStyle get listTileUnconfirmedPriceLabel =>
      AppTypeScale.noto15w500.copyWith(color: colors.text);

  /// 凡例・列見出しなどの補足テキスト
  TextStyle get listTileLegendTitle =>
      AppTypeScale.noto14w400.copyWith(color: colors.textSecondary);

  // ==========================================================================
  // リストカード
  // ==========================================================================

  /// リストカードの未確定ラベル
  TextStyle get listCardUnconfirmedPriceLabel =>
      AppTypeScale.noto14w700.copyWith(color: colors.text);

  /// 小さな数値キャプション（「固定費 ¥1,980」「利用 35%」「次回 7/25」「月平均 ¥…」）。見出し行の件数は listCardSecondaryNumeric
  TextStyle get numericCaption =>
      AppTypeScale.sfUi11w400.copyWith(color: colors.textSecondary);

  /// チップ（「固定費」等）のラベル。塗り内で文字を垂直中央に置くため行高を詰める
  TextStyle get chipLabel => AppTypeScale.noto10w400.copyWith(
    color: colors.textSecondary,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// チップの強調ラベル（固定費一覧の「変動」チップ）
  TextStyle get chipLabelAccent => AppTypeScale.noto10w500.copyWith(
    color: colors.primary,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// リストカードの副ラベル・フィルターチップ
  TextStyle get listCardSecondaryTitle =>
      AppTypeScale.noto12w500.copyWith(color: colors.textSecondary);

  /// 数字が主役のリストカード副ラベル（日付「8月25日」・件数「12件」・割合「35%」・小計）
  TextStyle get listCardSecondaryNumeric =>
      AppTypeScale.sfUi12w500.copyWith(color: colors.textSecondary);

  /// 選択中のフィルターチップのラベル（色は呼び出し側で塗りに合わせて当てる）
  TextStyle get filterChipSelectedLabel =>
      AppTypeScale.noto12w600.copyWith(color: colors.text);

  /// 支出の符号色つき金額
  TextStyle get listCardMinusLabel =>
      AppTypeScale.sfUi16w600.copyWith(color: colors.expense);

  /// 収入の符号色つき金額
  TextStyle get listCardPlusLabel =>
      AppTypeScale.sfUi16w600.copyWith(color: colors.income);

  // ==========================================================================
  // アプリカード（収支カード・グラフカード等）
  // ==========================================================================

  /// カードのタイトル
  TextStyle get appCardTitleLabel =>
      AppTypeScale.noto14w500.copyWith(color: colors.textSecondary);

  /// 収支カードの「総支出」「総収入」。隣接するシェブロンと縦位置を揃えるため行高を詰める
  TextStyle get appCardPrimaryTitleLabel => AppTypeScale.noto16w600.copyWith(
    color: colors.text,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// カードの主金額
  TextStyle get appCardPriceLabel =>
      AppTypeScale.sfUi20w700.copyWith(color: colors.text);

  /// 帯付きサマリーカードの帯に置く合計金額（収入一覧・支出一覧）
  TextStyle get summaryHeroPriceLabel =>
      AppTypeScale.sfUi22w700.copyWith(color: colors.text);

  /// カードの副金額
  TextStyle get appCardSecondaryPriceLabel =>
      AppTypeScale.sfUi16w500.copyWith(color: colors.text);

  /// カード内の第三階層タイトル
  TextStyle get appCardTertiaryTitleLabel =>
      AppTypeScale.noto13w500.copyWith(color: colors.textSecondary);

  /// カード内の第三階層金額・件数
  TextStyle get appCardTertiaryPriceLabel =>
      AppTypeScale.sfUi14w500.copyWith(color: colors.textSecondary);

  /// 金額に添える単位「円」（和文なので noto）
  TextStyle get appCardTertiaryPriceUnit =>
      AppTypeScale.noto11w500.copyWith(color: colors.textSecondary);

  /// カードの任意副金額
  TextStyle get appCardOptionalSecondaryPriceLabel =>
      AppTypeScale.sfUi18w500.copyWith(color: colors.text);

  /// 円グラフ内ラベル（カテゴリー名と割合）
  TextStyle get appCardGraphLabel =>
      AppTypeScale.noto11w600.copyWith(color: colors.text);

  /// ポップアップメニュー項目（選択中は太字）
  TextStyle popupMenuItemLabel({Color? textColor, bool isSelected = false}) {
    final base = isSelected ? AppTypeScale.noto14w700 : AppTypeScale.noto14w400;
    return base.copyWith(color: textColor ?? colors.text);
  }

  // ==========================================================================
  // ボトムナビゲーションバー
  // ==========================================================================

  /// グロナビ選択中ラベル
  TextStyle get bottomNavSelectedLabel =>
      AppTypeScale.noto11w600.copyWith(color: colors.text);

  /// グロナビ非選択ラベル
  TextStyle get bottomNavUnselectedLabel =>
      AppTypeScale.noto11w500.copyWith(color: colors.textSecondary);

  // ==========================================================================
  // インセットグループ（AppInsetGroup / AppInsetRow）
  // ==========================================================================

  /// インセットグループの見出し（「固定費」「設定」など）
  TextStyle get insetGroupHeader =>
      AppTypeScale.noto13w500.copyWith(color: colors.textSecondary);

  /// 数字が主役のインセットグループ見出し（支払い履歴の「2026年」と年合計）
  TextStyle get insetGroupHeaderNumeric =>
      AppTypeScale.sfUi13w500.copyWith(color: colors.textSecondary);

  /// インセット行のラベル（「拠出元」「頻度」など）
  TextStyle get insetGroupLabel =>
      AppTypeScale.noto14w500.copyWith(color: colors.text);

  /// インセット行の値（右寄せの選択値・入力値）
  TextStyle get insetGroupValue =>
      AppTypeScale.noto15w500.copyWith(color: colors.text);

  /// 数字が主役のインセット行の値（金額の表示・入力、次回支払日）。AppInsetRow.numericValue で切り替える
  TextStyle get insetGroupValueNumeric =>
      AppTypeScale.sfUi15w500.copyWith(color: colors.text);

  /// インセット行の値のプレースホルダー（未入力時）
  TextStyle get insetGroupPlaceholder =>
      AppTypeScale.noto15w500.copyWith(color: colors.textTertiary);

  /// インセットグループの直下に添える補足文（操作の結果を説明する1〜2行。読ませる文なので 12px w400。
  /// ページ本文の独立した説明文は supportingText）
  TextStyle get insetGroupNote =>
      AppTypeScale.noto12w400.copyWith(color: colors.textSecondary);

  /// 支払い履歴行の日付（「7/25」。数字が主役なので sfUi）
  TextStyle get insetGroupHistoryDate =>
      AppTypeScale.sfUi13w400.copyWith(color: colors.textSecondary);

  /// 支払い履歴行の金額
  TextStyle get insetGroupHistoryPrice =>
      AppTypeScale.sfUi15w500.copyWith(color: colors.text);

  // ==========================================================================
  // ボトムシート（予想額の入力シートなど）
  // ==========================================================================

  /// ボトムシートの見出し（「予想額」など）
  TextStyle get sheetTitle =>
      AppTypeScale.noto16w600.copyWith(color: colors.text);

  /// ボトムシートの文字入力（小カテゴリー名など。金額は sheetPriceInput）
  TextStyle get sheetTextInput =>
      AppTypeScale.noto15w500.copyWith(color: colors.text);

  /// ボトムシートの金額入力（大きい数値）
  TextStyle get sheetPriceInput =>
      AppTypeScale.sfUi40w700.copyWith(color: colors.text, height: 1.0);

  /// ボトムシートの金額入力に添える円記号
  TextStyle get sheetPriceYenSymbol => AppTypeScale.sfUi28w700.copyWith(
    color: colors.textSecondary,
    height: 1.0,
  );

  // ==========================================================================
  // セグメンテッドコントロール（AppSegmentedControl）
  // ==========================================================================

  /// 未選択セグメントのラベル
  TextStyle get segmentedLabel =>
      AppTypeScale.noto14w400.copyWith(color: colors.textSecondary);

  /// 選択中セグメントのラベル
  TextStyle get segmentedSelectedLabel =>
      AppTypeScale.noto14w600.copyWith(color: colors.text);
}

/// BuildContext から現在のテーマのアプリ全般の役割スタイルを取る（KP-013）
extension AppTextStylesX on BuildContext {
  AppTextStyles get textStyles => AppTextStyles(colors);
}
