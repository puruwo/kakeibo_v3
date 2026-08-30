import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_type_scale.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// ============================================================================
/// アプリ全般で共通して使用する役割スタイル
///
/// - 値（family × size × weight）は AppTypeScale の段を参照し、ここでは色と height だけ付ける
/// - 色は static 定義のため AppColorsDark（ダーク固定の逃げ道）。呼び出し側で状態色を当てるときは
///   `.copyWith(color: context.colors.<token>)` のみ許可（寸法・ウェイトの上書きは禁止）
/// - 同じ役割の別名を作らない。値が同じでも役割が違えば別名でよい
/// - 運用ルールの正本: Vault「Kakeibo テキストスタイルルール」
/// ウェイト階層（ADR-017 #4 を KP-007 で改定）: 主要金額 w700 ／ 見出し・行金額・ボタン・選択中 w600 ／
/// 標準ラベル・値 w500 ／ 説明文・補助文字・非選択 w400。w300 はダーク背景の小さな文字で細すぎるため使わない
/// ============================================================================
class AppTextStyles {
  AppTextStyles._();

  // ==========================================================================
  // ページヘッダー
  // ==========================================================================

  /// ページタイトル（AppBar）
  static final TextStyle pageHeaderText = AppTypeScale.noto18w500.copyWith(
    color: AppColorsDark.text,
  );

  /// 数字が主役のページタイトル（期間「2026年 8月」「2026年4月 - 2027年3月」・年月ピッカーの年／月度）
  static final TextStyle pageHeaderNumeric = AppTypeScale.sfUi18w500.copyWith(
    color: AppColorsDark.text,
  );

  /// ページヘッダーのサブテキスト（AppBar の2段目・補足情報）
  static final TextStyle pageHeaderSubText = AppTypeScale.noto12w400.copyWith(
    color: AppColorsDark.textSecondary,
  );

  /// 数字が主役のヘッダーサブテキスト（「2026年度」・年月ピッカーの見出し）
  static final TextStyle pageHeaderSubNumeric = AppTypeScale.sfUi12w400
      .copyWith(color: AppColorsDark.textSecondary);

  /// ページ本文先頭に置く対象名（支払い履歴ページの固定費名など）
  static final TextStyle pageSubjectTitle = AppTypeScale.noto22w600.copyWith(
    color: AppColorsDark.text,
  );

  // ==========================================================================
  // ダイアログ・シート・設定
  // ==========================================================================

  /// ダイアログタイトル
  static final TextStyle dialogTitle = AppTypeScale.noto18w500.copyWith(
    color: AppColorsDark.text,
  );

  /// ダイアログ内文言
  static final TextStyle dialogLabel = AppTypeScale.noto13w400.copyWith(
    color: AppColorsDark.text,
  );

  /// ダイアログ内文言の強調（削除確認のタイトル）
  static final TextStyle dialogLabelEmphasis = AppTypeScale.noto13w600.copyWith(
    color: AppColorsDark.text,
  );

  /// メニュー（ActionSheet）の項目
  static final TextStyle dialogList = AppTypeScale.noto16w500.copyWith(
    color: AppColorsDark.text,
  );

  /// メニュー（ActionSheet）の強調項目（キャンセル・選択中の頻度）
  static final TextStyle dialogListEmphasis = AppTypeScale.noto16w600.copyWith(
    color: AppColorsDark.text,
  );

  /// ステッパー（集計期間設定ページ）の選択中の数値
  static final TextStyle stepperValueLabel = AppTypeScale.sfUi32w600.copyWith(
    color: AppColorsDark.text,
  );

  /// 設定ページの説明文・補助ラベル（読ませる補助文）
  static final TextStyle supportingText = AppTypeScale.noto13w400.copyWith(
    color: AppColorsDark.textSecondary,
  );

  // ==========================================================================
  // タブ
  // ==========================================================================

  /// 選択中タブラベル（AppTab）
  static final TextStyle selectedLabelStyle = AppTypeScale.noto14w600.copyWith(
    color: AppColorsDark.primary,
  );

  /// 非選択タブラベル（AppTab）
  static final TextStyle unselectedLabelStyle = AppTypeScale.noto14w400
      .copyWith(color: AppColorsDark.textSecondary);

  // ==========================================================================
  // ボタン・リンク
  // ==========================================================================

  /// ボタンラベル全般（MainButton / FAB・ダイアログのキャンセル等）
  static final TextStyle mainButtonText = AppTypeScale.noto14w600.copyWith(
    color: AppColorsDark.text,
  );

  /// 設定トップのメニュー行
  static final TextStyle oneLineButtonText = AppTypeScale.noto13w500.copyWith(
    color: AppColorsDark.text,
  );

  /// テキストボタン・リンク行（「さらに表示する」「すべての支払いを見る」等）
  static final TextStyle textButtonTextStyle = AppTypeScale.noto12w500.copyWith(
    color: AppColorsDark.primary,
  );

  // ==========================================================================
  // 状態メッセージ
  // ==========================================================================

  /// 空状態（AppEmptyState・プレーンテキストバー）
  static final TextStyle listEmptyMessage = AppTypeScale.noto16w400.copyWith(
    color: AppColorsDark.textSecondary,
  );

  /// エラー表示（AppErrorState）。空状態とは danger 色で意味的に分ける（ADR-018）
  static final TextStyle errorMessage = AppTypeScale.noto16w400.copyWith(
    color: AppColorsDark.danger,
  );

  /// スナックバーの文言（成功／失敗は呼び出し側で色を当てる）
  static final TextStyle snackBarMessage = AppTypeScale.noto14w400.copyWith(
    color: AppColorsDark.text,
  );

  // ==========================================================================
  // セクション見出し
  // ==========================================================================

  /// セクション見出し（AppContentsHeader 既定）
  static final TextStyle appCardSectionTitle = AppTypeScale.noto16w600.copyWith(
    color: AppColorsDark.text,
  );

  /// 数字が主役のセクション見出し（月別アコーディオンの「8月」「2027年1月」）
  static final TextStyle appCardSectionNumeric = AppTypeScale.sfUi16w600
      .copyWith(color: AppColorsDark.text);

  /// リストカード見出し（AppContentsHeader.listCardSectionTitle・フィルター名。和文が主役）
  static final TextStyle listCardSectionTitle = AppTypeScale.noto14w600
      .copyWith(color: AppColorsDark.textSecondary);

  /// 履歴一覧の日付見出し（yyyy年M月d日(E)）
  static final TextStyle listTileSectionTitle = AppTypeScale.sfUi13w500
      .copyWith(color: AppColorsDark.textSecondary);

  // ==========================================================================
  // リストタイル
  // ==========================================================================

  /// 行・リストカードの主ラベル
  static final TextStyle listTilePrimaryTitle = AppTypeScale.noto14w500
      .copyWith(color: AppColorsDark.text);

  /// 行の副ラベル
  static final TextStyle listTileSecondaryTitle = AppTypeScale.noto13w400
      .copyWith(color: AppColorsDark.textSecondary);

  /// 行の第三階層ラベル（履歴タイルの小カテゴリー名・メモ等）
  static final TextStyle listTileTertiaryTitle = AppTypeScale.noto11w400
      .copyWith(color: AppColorsDark.textSecondary);

  /// 行の金額（履歴タイル・リストカードの行金額）
  static final TextStyle listTilePriceLabel = AppTypeScale.sfUi17w600.copyWith(
    color: AppColorsDark.text,
  );

  /// 行の副金額
  static final TextStyle listTileSubPriceLabel = AppTypeScale.sfUi15w400
      .copyWith(color: AppColorsDark.textSecondary);

  /// 行内の金額入力フィールド
  static final TextStyle listTileInputPriceLabel = AppTypeScale.sfUi19w500
      .copyWith(color: AppColorsDark.text);

  /// 入力フィールドのヒントテキスト
  static final TextStyle listTileTextFieldHint = AppTypeScale.noto15w600
      .copyWith(color: AppColorsDark.textTertiary);

  /// 未確定の金額欄（「---」「未入力」）
  static final TextStyle listTileUnconfirmedPriceLabel = AppTypeScale.noto15w500
      .copyWith(color: AppColorsDark.text);

  /// 凡例・列見出しなどの補足テキスト
  static final TextStyle listTileLegendTitle = AppTypeScale.noto14w400.copyWith(
    color: AppColorsDark.textSecondary,
  );

  // ==========================================================================
  // リストカード
  // ==========================================================================

  /// リストカードの未確定ラベル
  static final TextStyle listCardUnconfirmedPriceLabel = AppTypeScale.noto14w700
      .copyWith(color: AppColorsDark.text);

  /// 小さな数値キャプション（「固定費 ¥1,980」「利用 35%」「次回 7/25」「月平均 ¥…」「3件」）
  static final TextStyle numericCaption = AppTypeScale.sfUi11w400.copyWith(
    color: AppColorsDark.textSecondary,
  );

  /// チップ（「固定費」等）のラベル。塗り内で文字を垂直中央に置くため行高を詰める
  static final TextStyle chipLabel = AppTypeScale.noto10w400.copyWith(
    color: AppColorsDark.textSecondary,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// チップの強調ラベル（固定費一覧の「変動」チップ）
  static final TextStyle chipLabelAccent = AppTypeScale.noto10w500.copyWith(
    color: AppColorsDark.primary,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// リストカードの副ラベル・フィルターチップ
  static final TextStyle listCardSecondaryTitle = AppTypeScale.noto12w500
      .copyWith(color: AppColorsDark.textSecondary);

  /// 数字が主役のリストカード副ラベル（日付「8月25日」・件数「12件」・割合「35%」・小計）
  static final TextStyle listCardSecondaryNumeric = AppTypeScale.sfUi12w500
      .copyWith(color: AppColorsDark.textSecondary);

  /// 選択中のフィルターチップのラベル（色は呼び出し側で塗りに合わせて当てる）
  static final TextStyle filterChipSelectedLabel = AppTypeScale.noto12w600
      .copyWith(color: AppColorsDark.text);

  /// 支出の符号色つき金額
  static final TextStyle listCardMinusLabel = AppTypeScale.sfUi16w600.copyWith(
    color: AppColorsDark.expense,
  );

  /// 収入の符号色つき金額
  static final TextStyle listCardPlusLabel = AppTypeScale.sfUi16w600.copyWith(
    color: AppColorsDark.income,
  );

  // ==========================================================================
  // アプリカード（収支カード・グラフカード等）
  // ==========================================================================

  /// カードのタイトル
  static final TextStyle appCardTitleLabel = AppTypeScale.noto14w500.copyWith(
    color: AppColorsDark.textSecondary,
  );

  /// 収支カードの「総支出」「総収入」。隣接するシェブロンと縦位置を揃えるため行高を詰める
  static final TextStyle appCardPrimaryTitleLabel = AppTypeScale.noto16w600
      .copyWith(
        color: AppColorsDark.text,
        height: 1.0,
        leadingDistribution: TextLeadingDistribution.even,
      );

  /// カードの主金額
  static final TextStyle appCardPriceLabel = AppTypeScale.sfUi20w700.copyWith(
    color: AppColorsDark.text,
  );

  /// 帯付きサマリーカードの帯に置く合計金額（収入一覧・支出一覧）
  static final TextStyle summaryHeroPriceLabel = AppTypeScale.sfUi22w700
      .copyWith(color: AppColorsDark.text);

  /// カードの副金額
  static final TextStyle appCardSecondaryPriceLabel = AppTypeScale.sfUi16w500
      .copyWith(color: AppColorsDark.text);

  /// カード内の第三階層タイトル
  static final TextStyle appCardTertiaryTitleLabel = AppTypeScale.noto13w500
      .copyWith(color: AppColorsDark.textSecondary);

  /// カード内の第三階層金額・件数
  static final TextStyle appCardTertiaryPriceLabel = AppTypeScale.sfUi14w500
      .copyWith(color: AppColorsDark.textSecondary);

  /// 金額に添える単位「円」（和文なので noto）
  static final TextStyle appCardTertiaryPriceUnit = AppTypeScale.noto11w500
      .copyWith(color: AppColorsDark.textSecondary);

  /// カードの任意副金額
  static final TextStyle appCardOptionalSecondaryPriceLabel = AppTypeScale
      .sfUi18w500
      .copyWith(color: AppColorsDark.text);

  /// 円グラフ内ラベル（カテゴリー名と割合）
  static final TextStyle appCardGraphLabel = AppTypeScale.noto11w600.copyWith(
    color: AppColorsDark.text,
  );

  /// ポップアップメニュー項目（選択中は太字）
  static TextStyle popupMenuItemLabel({
    Color? textColor,
    bool isSelected = false,
  }) {
    final base = isSelected ? AppTypeScale.noto14w700 : AppTypeScale.noto14w400;
    return base.copyWith(color: textColor ?? AppColorsDark.text);
  }

  // ==========================================================================
  // ボトムナビゲーションバー
  // ==========================================================================

  /// グロナビ選択中ラベル
  static final TextStyle bottomNavSelectedLabel = AppTypeScale.noto11w600
      .copyWith(color: AppColorsDark.text);

  /// グロナビ非選択ラベル
  static final TextStyle bottomNavUnselectedLabel = AppTypeScale.noto11w500
      .copyWith(color: AppColorsDark.textSecondary);

  // ==========================================================================
  // インセットグループ（AppInsetGroup / AppInsetRow）
  // ==========================================================================

  /// インセットグループの見出し（「固定費」「設定」など）
  static final TextStyle insetGroupHeader = AppTypeScale.noto13w500.copyWith(
    color: AppColorsDark.textSecondary,
  );

  /// 数字が主役のインセットグループ見出し（支払い履歴の「2026年」と年合計）
  static final TextStyle insetGroupHeaderNumeric = AppTypeScale.sfUi13w500
      .copyWith(color: AppColorsDark.textSecondary);

  /// インセット行のラベル（「拠出元」「頻度」など）
  static final TextStyle insetGroupLabel = AppTypeScale.noto14w500.copyWith(
    color: AppColorsDark.text,
  );

  /// インセット行の値（右寄せの選択値・入力値）
  static final TextStyle insetGroupValue = AppTypeScale.noto15w500.copyWith(
    color: AppColorsDark.text,
  );

  /// 数字が主役のインセット行の値（金額の表示・入力、次回支払日）。AppInsetRow.numericValue で切り替える
  static final TextStyle insetGroupValueNumeric = AppTypeScale.sfUi15w500
      .copyWith(color: AppColorsDark.text);

  /// インセット行の値のプレースホルダー（未入力時）
  static final TextStyle insetGroupPlaceholder = AppTypeScale.noto15w500
      .copyWith(color: AppColorsDark.textTertiary);

  /// インセットグループの下に添える補足文（操作の結果を説明する1〜2行。読ませる文なので 12px w400）
  static final TextStyle insetGroupNote = AppTypeScale.noto12w400.copyWith(
    color: AppColorsDark.textSecondary,
  );

  /// 支払い履歴行の日付（「7/25」。数字が主役なので sfUi）
  static final TextStyle insetGroupHistoryDate = AppTypeScale.sfUi13w400
      .copyWith(color: AppColorsDark.textSecondary);

  /// 支払い履歴行の金額
  static final TextStyle insetGroupHistoryPrice = AppTypeScale.sfUi15w500
      .copyWith(color: AppColorsDark.text);

  // ==========================================================================
  // ボトムシート（予想額の入力シートなど）
  // ==========================================================================

  /// ボトムシートの見出し（「予想額」など）
  static final TextStyle sheetTitle = AppTypeScale.noto16w600.copyWith(
    color: AppColorsDark.text,
  );

  /// ボトムシートの金額入力（大きい数値）
  static final TextStyle sheetPriceInput = AppTypeScale.sfUi40w700.copyWith(
    color: AppColorsDark.text,
    height: 1.0,
  );

  /// ボトムシートの金額入力に添える円記号
  static final TextStyle sheetPriceYenSymbol = AppTypeScale.sfUi28w700.copyWith(
    color: AppColorsDark.textSecondary,
    height: 1.0,
  );

  // ==========================================================================
  // セグメンテッドコントロール（AppSegmentedControl）
  // ==========================================================================

  /// 未選択セグメントのラベル
  static final TextStyle segmentedLabel = AppTypeScale.noto14w400.copyWith(
    color: AppColorsDark.textSecondary,
  );

  /// 選択中セグメントのラベル
  static final TextStyle segmentedSelectedLabel = AppTypeScale.noto14w600
      .copyWith(color: AppColorsDark.text);
}
