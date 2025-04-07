import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';

class MyFonts {

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

  
}
