import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/font_style.dart';

/// ============================================================================
/// 月間ページ・年間ページで使用するTextStyleを定義
/// ============================================================================
class MonthlyPageStyles {
  // ==========================================================================
  // サードページ（リスト表示画面）の見出し
  // ==========================================================================

  /// セクション見出し用スタイル
  ///
  /// 【使用箇所】
  /// - ページ: year_page.dart (年間ページ)
  ///   - エリア: メインコンテンツ
  ///   - 詳細: 「年間収支」「ボーナス」「固定費」などのセクション見出し
  ///
  /// - ページ: monthly_page.dart (月間ページ)
  ///   - エリア: メインコンテンツ
  ///   - 詳細: 「カテゴリー別支出」「固定費」などのセクション見出し
  static final TextStyle thirdPageSubheading = MyFontStyle.notoSans.copyWith(
      fontSize: 18, color: MyColors.label, fontWeight: FontWeight.w600);

  // ==========================================================================
  // トップカード（サマリーカード）
  // ==========================================================================

  /// トップカードのタイトルラベル（プライマリ）
  ///
  /// 【使用箇所】
  /// - ページ: year_page.dart (年間ページ)
  ///   - エリア: yearly_balance_area.dart (年間収支エリア)
  ///   - 詳細: 「今年の残高」ラベル
  ///
  /// - ページ: year_page.dart (年間ページ)
  ///   - エリア: bonus_plan_area.dart (ボーナス計画エリア)
  ///   - 詳細: 「ボーナス残高」「総収入」「総支出」ラベル
  ///
  /// - ページ: monthly_page.dart (月間ページ)
  ///   - エリア: monthly_plan_graph_area.dart, monthly_income_graph_area.dart
  ///   - 詳細: 「支出」「収入」ラベル
  ///
  /// - ページ: monthly_page.dart (月間ページ)
  ///   - エリア: monthly_fixed_cost_summary_area.dart
  ///   - 詳細: 「固定費合計」ラベル
  static final TextStyle topCardTitleLabel = MyFontStyle.notoSans.copyWith(
      fontSize: 16,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w400);

  /// トップカードのサブタイトルラベル（セカンダリ）
  ///
  /// 【使用箇所】
  /// - ページ: year_page.dart (年間ページ)
  ///   - エリア: yearly_balance_area.dart (年間収支エリア)
  ///   - 詳細: 「収入」「支出」の内訳ラベル
  static final TextStyle topCardSubTitleLabel = MyFontStyle.notoSans.copyWith(
      fontSize: 14,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w400);

  /// トップカードのターシャリタイトルラベル（確定/未確定など）
  ///
  /// 【使用箇所】
  /// - ページ: monthly_page.dart (月間ページ)
  ///   - エリア: monthly_fixed_cost_summary_area.dart
  ///   - 詳細: 「確定」「未確定」ラベル
  static final TextStyle topCardTirtiaryTitleLabel =
      MyFontStyle.notoSans.copyWith(
          fontSize: 14,
          color: MyColors.secondaryLabel,
          fontWeight: FontWeight.w400);

  // ==========================================================================
  // トップカードの金額表示
  // ==========================================================================

  /// トップカードの金額ラベル（プライマリ - 大きい）
  ///
  /// 【使用箇所】
  /// - ページ: year_page.dart (年間ページ)
  ///   - エリア: yearly_balance_area.dart, bonus_plan_area.dart
  ///   - 詳細: メインの残高/合計金額表示
  ///
  /// - ページ: monthly_page.dart (月間ページ)
  ///   - エリア: monthly_fixed_cost_summary_area.dart
  ///   - 詳細: 固定費合計金額表示
  static final TextStyle topCardPriceLabel = MyFontStyle.sfUi.copyWith(
    color: MyColors.label,
    fontSize: 26,
    fontWeight: FontWeight.w600,
  );

  /// トップカードのサブ金額ラベル（セカンダリ - 中）
  ///
  /// 【使用箇所】
  /// - ページ: year_page.dart (年間ページ)
  ///   - エリア: yearly_balance_area.dart
  ///   - 詳細: 収入/支出の内訳金額表示
  static final TextStyle topCardSubPriceLabel = MyFontStyle.sfUi.copyWith(
    color: MyColors.label,
    fontSize: 19,
    fontWeight: FontWeight.w600,
  );

  /// トップカードのターシャリ金額ラベル（小さい）
  ///
  /// 【使用箇所】
  /// - ページ: monthly_page.dart (月間ページ)
  ///   - エリア: monthly_fixed_cost_summary_area.dart
  ///   - 詳細: 確定/未確定の金額表示
  static final TextStyle topCardTirtiaryPriceLabel =
      MyFontStyle.notoSans.copyWith(
          fontSize: 14,
          color: MyColors.secondaryLabel,
          fontWeight: FontWeight.w400);

  // ==========================================================================
  // トップカードの「円」単位表示
  // ==========================================================================

  /// トップカードの「円」ラベル（プライマリ）
  ///
  /// 【使用箇所】
  /// - ページ: year_page.dart (年間ページ)
  ///   - エリア: yearly_balance_area.dart, bonus_plan_area.dart
  ///   - 詳細: メイン金額の後の「円」表示
  ///
  /// - ページ: monthly_page.dart (月間ページ)
  ///   - エリア: monthly_fixed_cost_summary_area.dart
  ///   - 詳細: 固定費合計の「円」表示
  static final TextStyle topCardYenLabel = MyFontStyle.notoSans.copyWith(
      fontSize: 16, color: MyColors.label, fontWeight: FontWeight.w600);

  /// トップカードのサブ「円」ラベル（セカンダリ）
  ///
  /// 【使用箇所】
  /// - ページ: year_page.dart (年間ページ)
  ///   - エリア: fixed_cost_button_area.dart, yearly_balance_area.dart
  ///   - 詳細: サブ金額の「円」表示
  ///
  /// - ページ: year_page.dart (年間ページ)
  ///   - エリア: annual_balance_chart.dart
  ///   - 詳細: 空データ時の「まだ記録がありません」メッセージ表示
  static final TextStyle topCardSubYenLabel = MyFontStyle.notoSans.copyWith(
      fontSize: 14, color: MyColors.label, fontWeight: FontWeight.w300);

  /// トップカードのターシャリ「円」ラベル（小さい）
  ///
  /// 【使用箇所】
  /// - ページ: monthly_page.dart (月間ページ)
  ///   - エリア: monthly_fixed_cost_summary_area.dart
  ///   - 詳細: 確定/未確定金額の「円」表示
  static final TextStyle topCardTirtiaryYenLabel = MyFontStyle.notoSans
      .copyWith(
          fontSize: 11,
          color: MyColors.secondaryLabel,
          fontWeight: FontWeight.w300);

  // ==========================================================================
  // 固定費ページ (MonthlyFixedCostPage)
  // ==========================================================================

  /// 固定費ページタイトル
  ///
  /// 【使用箇所】
  /// - ページ: monthly_fixed_cost_page.dart
  ///   - エリア: AppBar
  ///   - 詳細: AppBarの「固定費」タイトル
  static final TextStyle fixedCostPageTitle = MyFontStyle.notoSans.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  /// 固定費サマリーヘッダータイトル
  ///
  /// 【使用箇所】
  /// - ページ: fixed_cost_summary_header.dart
  ///   - エリア: ヘッダー
  ///   - 詳細: 「今月の支払い予定」
  static final TextStyle fixedCostSummaryHeaderTitle =
      MyFontStyle.notoSans.copyWith(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  /// 固定費サマリーヘッダー合計金額
  ///
  /// 【使用箇所】
  /// - ページ: fixed_cost_summary_header.dart
  ///   - エリア: ヘッダー
  ///   - 詳細: 支払い予定合計金額
  static final TextStyle fixedCostSummaryHeaderAmount =
      MyFontStyle.sfUi.copyWith(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  /// 固定費サマリー行ラベル（確定分）
  ///
  /// 【使用箇所】
  /// - ページ: fixed_cost_summary_header.dart
  ///   - エリア: 確定分行
  ///   - 詳細: 「確定分」ラベル
  static final TextStyle fixedCostSummaryConfirmedLabel =
      MyFontStyle.notoSans.copyWith(
    color: Colors.white70,
    fontSize: 16,
  );

  /// 固定費サマリー行ラベル（未確定分）
  ///
  /// 【使用箇所】
  /// - ページ: fixed_cost_summary_header.dart
  ///   - エリア: 未確定分行
  ///   - 詳細: 「未確定確定分(推定)」ラベル
  static final TextStyle fixedCostSummaryUnconfirmedLabel =
      MyFontStyle.notoSans.copyWith(
    color: Colors.white54,
    fontSize: 16,
  );

  /// 固定費サマリー行金額
  ///
  /// 【使用箇所】
  /// - ページ: fixed_cost_summary_header.dart
  ///   - エリア: 確定分/未確定分行
  ///   - 詳細: 各行の金額表示
  static final TextStyle fixedCostSummaryRowAmount = MyFontStyle.sfUi.copyWith(
    color: Colors.white,
    fontSize: 18,
  );

  /// 固定費リスト空メッセージ
  ///
  /// 【使用箇所】
  /// - ページ: fixed_cost_by_category_list_area.dart
  ///   - エリア: リスト
  ///   - 詳細: 「記録がまだありません」
  static final TextStyle fixedCostListEmptyMessage =
      MyFontStyle.notoSans.copyWith(
    color: MyColors.secondaryLabel,
    fontSize: 16,
  );

  /// 固定費カテゴリーリスト要素（金額）
  ///
  /// 【使用箇所】
  /// - ページ: monthly_fixed_cost_category_summary_list.dart
  ///   - エリア: リストアイテム
  ///   - 詳細: 合計金額
  static final TextStyle fixedCostCategoryListAmount = MyFontStyle.sfUi.copyWith(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // ==========================================================================
  // カテゴリータイル（支出バー）
  // ==========================================================================

  /// カテゴリータイルの予算ラベル（区切り）
  ///
  /// 【使用箇所】
  /// - ページ: monthly_page.dart
  ///   - エリア: price_label.dart
  ///   - 詳細: 「/」区切り
  static final TextStyle categoryTileBudgetSeparator =
      MyFontStyle.notoSans.copyWith(
          fontSize: 14,
          color: MyColors.secondaryLabel,
          fontWeight: FontWeight.w400);

  /// カテゴリータイルの予算テキストラベル
  ///
  /// 【使用箇所】
  /// - ページ: monthly_page.dart
  ///   - エリア: price_label.dart
  ///   - 詳細: 「予算」テキスト
  static final TextStyle categoryTileBudgetTextLabel =
      MyFontStyle.notoSans.copyWith(
          fontSize: 13,
          color: MyColors.secondaryLabel,
          fontWeight: FontWeight.w400);

  /// カテゴリータイルの予算金額ラベル
  ///
  /// 【使用箇所】
  /// - ページ: monthly_page.dart
  ///   - エリア: price_label.dart
  ///   - 詳細: 予算金額
  static final TextStyle categoryTileBudgetPriceLabel =
      MyFontStyle.notoSans.copyWith(
          fontSize: 14,
          color: MyColors.secondaryLabel,
          fontWeight: FontWeight.w400);

  /// カテゴリータイルの予算「円」ラベル
  ///
  /// 【使用箇所】
  /// - ページ: monthly_page.dart
  ///   - エリア: price_label.dart
  ///   - 詳細: 予算金額後の「円」
  static final TextStyle categoryTileBudgetYenLabel =
      MyFontStyle.notoSans.copyWith(
          fontSize: 11,
          color: MyColors.secondaryLabel,
          fontWeight: FontWeight.w400);

  /// カテゴリータイルのカテゴリー名ラベル
  ///
  /// 【使用箇所】
  /// - ページ: monthly_page.dart
  ///   - エリア: category_sum_text.dart
  ///   - 詳細: カテゴリー名
  static final TextStyle categoryTileCategoryNameLabel =
      MyFontStyle.notoSans.copyWith(
          fontSize: 16, color: MyColors.white, fontWeight: FontWeight.w300);

  /// 固定費チップラベル（未確定アイコン）
  ///
  /// 【使用箇所】
  /// - ページ: various
  ///   - エリア: unconfirmed_fixed_cost_chip_label.dart
  ///   - 詳細: 「変動あり」チップ
  static final TextStyle fixedCostChipLabel = MyFontStyle.notoSans.copyWith(
      fontSize: 10, color: MyColors.themeColor, fontWeight: FontWeight.w400);

  /// 固定費カテゴリーヘッダー（カテゴリー名）
  ///
  /// 【使用箇所】
  /// - ページ: fixed_cost_category_header.dart
  ///   - エリア: ヘッダー
  ///   - 詳細: カテゴリー名
  static final TextStyle fixedCostHeaderCategoryName =
      MyFontStyle.notoSans.copyWith(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  /// 月間プランエリアボタンラベル
  ///
  /// 【使用箇所】
  /// - ページ: monthly_plan_area.dart
  ///   - エリア: 予算・収入ボタン
  ///   - 詳細: ボタン内のテキスト
  static final TextStyle planAreaButtonLabel = MyFontStyle.notoSans.copyWith(
      color: MyColors.themeColor, fontSize: 15, fontWeight: FontWeight.w600);

  // ==========================================================================
  // カテゴリー別支出履歴ページ (CategoryExpenseHistoryPage)
  // ==========================================================================

  /// カテゴリー名（展開時）
  ///
  /// 【使用箇所】
  /// - ページ: expanded_category_sum_tile.dart
  ///   - 詳細: カテゴリー名、小カテゴリー名
  static final TextStyle categoryExpandedCategoryName =
      MyFontStyle.notoSans.copyWith(
          fontSize: 16, color: MyColors.label, fontWeight: FontWeight.normal);

  /// 支出金額（展開時）
  ///
  /// 【使用箇所】
  /// - ページ: expanded_category_sum_tile.dart
  ///   - 詳細: カテゴリーごとの支出金額
  static final TextStyle categoryExpandedPrice = MyFontStyle.notoSans.copyWith(
      fontSize: 18, color: MyColors.label, fontWeight: FontWeight.w600);

  /// 「円」ラベル（展開時）
  ///
  /// 【使用箇所】
  /// - ページ: expanded_category_sum_tile.dart
  ///   - 詳細: 支出金額の「円」
  static final TextStyle categoryExpandedYen = MyFontStyle.notoSans.copyWith(
      fontSize: 14, color: MyColors.label, fontWeight: FontWeight.normal);

  /// サブテキスト（展開時）
  ///
  /// 【使用箇所】
  /// - ページ: expanded_category_sum_tile.dart
  ///   - 詳細: 「/予算」などのテキスト
  static final TextStyle categoryExpandedSubText = MyFontStyle.notoSans
      .copyWith(
          fontSize: 12,
          color: MyColors.secondaryLabel,
          fontWeight: FontWeight.normal);

  /// 予算金額（展開時）
  ///
  /// 【使用箇所】
  /// - ページ: expanded_category_sum_tile.dart
  ///   - 詳細: 予算金額
  static final TextStyle categoryExpandedBudgetPrice = MyFontStyle.notoSans
      .copyWith(
          fontSize: 14,
          color: MyColors.secondaryLabel,
          fontWeight: FontWeight.normal);

  /// レコード件数（展開時）
  ///
  /// 【使用箇所】
  /// - ページ: expanded_category_sum_tile.dart
  ///   - 詳細: 「XX件」表示
  static final TextStyle categoryExpandedRecordCount = MyFontStyle.notoSans
      .copyWith(
          fontSize: 14,
          color: MyColors.secondaryLabel,
          fontWeight: FontWeight.normal);
}
