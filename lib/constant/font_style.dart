import 'package:flutter/material.dart';

class MyFontStyle {
  /// noto sans 日本語・英数併用
  static TextStyle get notoSans => const TextStyle(
        fontFamily: 'noto_sans',
      );

  /// sf ui 英数のみ
  static TextStyle get sfUi => const TextStyle(
        fontFamily: 'sf_ui',
      );
}
