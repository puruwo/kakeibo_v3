import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';

class MyFonts {

  // Common
  static TextStyle pageHeaderText = GoogleFonts.notoSans(
                  fontSize: 19,
                  color: MyColors.white,
                  fontWeight: FontWeight.w400);

  // Third Page
  static TextStyle thirdPageSubheading = GoogleFonts.notoSans(
      fontSize: 18,
      color: MyColors.secondaryLabel,
      fontWeight: FontWeight.w600);

  static const thirdPageTextButton =
      TextStyle(color: MyColors.linkColor, fontSize: 14);

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

  // Rigister Page
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
}
