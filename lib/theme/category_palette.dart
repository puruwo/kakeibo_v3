// GENERATED CODE - DO NOT MODIFY BY HAND
// Source    : design-tokens/tokens.json (category セット)
// Generator : tool/generate_tokens.dart
//
// カテゴリーパレット（データ色）。UI用 Color と DB保存用6桁HEX(alpha無し)を併記。
// DB側は getColorFromHex が 'FF'+code する既存仕様に合わせ6桁のまま。
// ※ 消費側（dialog/seed/注入）の差し替えは別STEP。

import 'package:flutter/material.dart';

class CategoryPalette {
  CategoryPalette._();

  // 支出カテゴリー（12色）
  static const Color expense1 = Color(0xFFF45058);
  static const Color expense2 = Color(0xFFFD7920);
  static const Color expense3 = Color(0xFFFCAB00);
  static const Color expense4 = Color(0xFFBFAD00);
  static const Color expense5 = Color(0xFF08C2CA);
  static const Color expense6 = Color(0xFF63CBFE);
  static const Color expense7 = Color(0xFF0287F0);
  static const Color expense8 = Color(0xFF6D61EB);
  static const Color expense9 = Color(0xFFBA7AFB);
  static const Color expense10 = Color(0xFFDA51CC);
  static const Color expense11 = Color(0xFFFD84B1);
  static const Color expense12 = Color(0xFF94582A);

  // 収入カテゴリー（4色）
  static const Color income1 = Color(0xFF53E39C);
  static const Color income2 = Color(0xFF12C281);
  static const Color income3 = Color(0xFF059F6D);
  static const Color income4 = Color(0xFF067553);

  // グレー（支出パレット末尾。固定費由来カテゴリーの「その他」等に使う）
  static const Color gray = Color(0xFF8E8E93);

  // --- DB保存用 6桁HEX（alpha無し） ---
  static const String expense1Hex = 'F45058';
  static const String expense2Hex = 'FD7920';
  static const String expense3Hex = 'FCAB00';
  static const String expense4Hex = 'BFAD00';
  static const String expense5Hex = '08C2CA';
  static const String expense6Hex = '63CBFE';
  static const String expense7Hex = '0287F0';
  static const String expense8Hex = '6D61EB';
  static const String expense9Hex = 'BA7AFB';
  static const String expense10Hex = 'DA51CC';
  static const String expense11Hex = 'FD84B1';
  static const String expense12Hex = '94582A';
  static const String income1Hex = '53E39C';
  static const String income2Hex = '12C281';
  static const String income3Hex = '059F6D';
  static const String income4Hex = '067553';
  static const String grayHex = '8E8E93';

  /// 支出パレットのスウォッチ（表示順。末尾はグレー）。
  static const List<Color> expenseSwatches = [expense1, expense2, expense3, expense4, expense5, expense6, expense7, expense8, expense9, expense10, expense11, expense12, gray];

  /// 収入パレットのスウォッチ（表示順）。
  static const List<Color> incomeSwatches = [income1, income2, income3, income4];
}
