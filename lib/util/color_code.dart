import 'package:flutter/material.dart';

/// カテゴリー等の色コード（6桁HEX文字列）と [Color] の相互変換ユーティリティ。
///
/// 旧 `MyColors` のインスタンスメソッド
/// `getColorFromHex` / `getColorCodeFromColor` / `getHexFromColor` を
/// ロジック不変のまま static メソッドへ移設したもの。
class ColorCode {
  ColorCode._();

  /// 6桁HEX(alpha無し) を不透明 [Color] に変換する（'FF'+code で 0xFFRRGGBB）。
  static Color toColor(String colorCode) {
    final intValue = int.parse('FF$colorCode', radix: 16);
    return Color(intValue);
  }

  /// [Color] を 6桁HEX 文字列（小文字）に変換する。
  static String fromColor(Color color) {
    return color.red.toRadixString(16).padLeft(2, '0') +
        color.green.toRadixString(16).padLeft(2, '0') +
        color.blue.toRadixString(16).padLeft(2, '0');
  }

  /// [Color] を 6桁HEX 文字列（大文字）に変換する。
  static String toHex(Color color) {
    return color.red.toRadixString(16).padLeft(2, '0').toUpperCase() +
        color.green.toRadixString(16).padLeft(2, '0').toUpperCase() +
        color.blue.toRadixString(16).padLeft(2, '0').toUpperCase();
  }
}
