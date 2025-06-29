import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';

class MyFonts {
  // Common
  static TextStyle pageHeaderText = GoogleFonts.notoSans(
      fontSize: 19, color: MyColors.white, fontWeight: FontWeight.w400);

  // Monthly Page
  static TextStyle thirdPageSubheading = GoogleFonts.notoSans(
      fontSize: 18, color: MyColors.label, fontWeight: FontWeight.w600);

  static const thirdPageTextButton =
      TextStyle(color: MyColors.themeColor, fontSize: 14);

  // MonthlyPlanArea BonusPlaaArea YearlyBalanceArea
  static TextStyle topCardTitleLabel = GoogleFonts.notoSans(
      fontSize: 16,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w400);
      
  static TextStyle topCardSubTitleLabel = GoogleFonts.notoSans(
      fontSize: 14,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w400);

  static TextStyle topCardPriceLabel = const TextStyle(
    color: MyColors.label,
    fontSize: 26,
    fontFamily: 'sf_ui',
    fontWeight: FontWeight.w600,
  );

  static TextStyle topCardSubPriceLabel = const TextStyle(
    color: MyColors.label,
    fontSize: 19,
    fontFamily: 'sf_ui',
    fontWeight: FontWeight.w600,
  );

  static TextStyle topCardYenLabel = GoogleFonts.notoSans(
      fontSize: 16, color: MyColors.label, fontWeight: FontWeight.w600);

  static TextStyle topCardSubYenLabel = GoogleFonts.notoSans(
      fontSize: 14, color: MyColors.label, fontWeight: FontWeight.w300);

  // Calndar Page
  static TextStyle calendarDateBoxLarge = const TextStyle(
    color: MyColors.white,
    fontSize: 12,
    fontFamily: 'sf_ui',
  );

  static TextStyle calendarDateBoxSmall = const TextStyle(
    color: MyColors.white,
    fontSize: 11,
    fontFamily: 'sf_ui',
  );

  // ecpense history
  static TextStyle expenseHistoryDateHeaderLabel = const TextStyle(
    color: MyColors.secondaryLabel,
    fontSize: 14,
  );

  // Register Page
  static TextStyle regesterHeaderLabel = GoogleFonts.notoSans(
      fontSize: 19, color: MyColors.white, fontWeight: FontWeight.w400);

  static TextStyle placeHolder = GoogleFonts.notoSans(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: MyColors.secondaryLabel,
  );

  static TextStyle inputExpenseText = const TextStyle(
    fontSize: 25.0,
    fontWeight: FontWeight.w500,
    color: MyColors.label,
    fontFamily: 'sf_ui',
  );

  static TextStyle inputText = GoogleFonts.notoSans(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: MyColors.label,
  );

  // Dialog
  static TextStyle dialogTitle = GoogleFonts.notoSans(
      fontSize: 18, color: MyColors.white, fontWeight: FontWeight.w400);

  static TextStyle dialogList = GoogleFonts.notoSans(
      fontSize: 18, color: MyColors.white, fontWeight: FontWeight.w300);

  //BudgetSettingPage
  static TextStyle categoryTitle = GoogleFonts.notoSans(
      fontSize: 18, color: MyColors.label, fontWeight: FontWeight.w400);

  static TextStyle subPrice = const TextStyle(
      fontFamily: 'sf_ui',
      fontSize: 16,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w300);

  static TextStyle yenText = GoogleFonts.notoSans(
      fontSize: 14,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w300);

  static TextStyle textField = const TextStyle(
      fontFamily: 'sf_ui',
      fontWeight: FontWeight.w600,
      color: MyColors.white,
      fontSize: 20);

  // innerTab
  static TextStyle selectedLabelStyle = GoogleFonts.notoSans(
      fontSize: 14, color: MyColors.themeColor, fontWeight: FontWeight.w600);

  static TextStyle unselectedLabelStyle = GoogleFonts.notoSans(
      fontSize: 14,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w300);

  //button
  static TextStyle mainButtonText = GoogleFonts.notoSans(
      fontSize: 14, color: MyColors.label, fontWeight: FontWeight.w600);

  static TextStyle secondaryButtonText = GoogleFonts.notoSans(
      fontSize: 14, color: MyColors.label, fontWeight: FontWeight.w600);

  // Card
  static TextStyle cardPrimaryTitle = GoogleFonts.notoSans(
      fontSize: 16, color: MyColors.label, fontWeight: FontWeight.w300);

  static TextStyle cardSecondaryTitle = GoogleFonts.notoSans(
      fontSize: 12,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w300);

  static TextStyle cardMinusLabel = const TextStyle(
      fontFamily: 'sf_ui',
      fontSize: 16,
      color: MyColors.mintBlue,
      fontWeight: FontWeight.w600);

  static TextStyle cardPlusLabel = const TextStyle(
      fontFamily: 'sf_ui',
      fontSize: 16,
      color: MyColors.pink,
      fontWeight: FontWeight.w600);

  static TextStyle cardPriceLabel = const TextStyle(
      fontFamily: 'sf_ui',
      fontSize: 19,
      color: MyColors.label,
      fontWeight: FontWeight.w600);

  // CategoryEditPage
  static TextStyle newCategoryAdd = GoogleFonts.notoSans(
      fontSize: 17,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w400);

  /// ================CategoryExpenseHistoryPage================
  /// カテゴリー別利用状況ページ

  // カテゴリー・項目タイトル表示
  static TextStyle categoryExpenseHistoryPageCategoryName =
      GoogleFonts.notoSans(
          fontSize: 16, color: MyColors.label, fontWeight: FontWeight.w400);

  // 件数表示
  static TextStyle categoryExpenseHistoryPageRecordCount = GoogleFonts.notoSans(
      fontSize: 14,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w300);

  // 金額表示
  static TextStyle categoryExpenseHistoryPagePrice = const TextStyle(
      fontFamily: 'sf_ui',
      fontSize: 19,
      color: MyColors.label,
      fontWeight: FontWeight.w300);

  // 予算表示
  static TextStyle categoryExpenseHistoryPageBudgetPrice = const TextStyle(
      fontFamily: 'sf_ui',
      fontSize: 14,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w300);

  // 円
  static TextStyle categoryExpenseHistoryPageYen = GoogleFonts.notoSans(
    fontSize: 11,
    color: MyColors.secondaryLabel,
    fontWeight: FontWeight.w400,
  );

  // 日本語サブテキスト
  static TextStyle categoryExpenseHistoryPageSubText = GoogleFonts.notoSans(
      fontSize: 13,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w400);

  /// ================================================
  /// 
  /// ================AnnualBalanceChartPage================
  /// 年間収支グラフページ
  
  // 縦軸ラベル
  static TextStyle annualBalanceChartPageVerticalLabel = GoogleFonts.notoSans(
      fontSize: 12, color: MyColors.secondaryLabel, fontWeight: FontWeight.w300);

  // 月ラベル
  static TextStyle annualBalanceChartPageMonthLabel = GoogleFonts.notoSans(
      fontSize: 15, color: MyColors.label, fontWeight: FontWeight.w300);
}
