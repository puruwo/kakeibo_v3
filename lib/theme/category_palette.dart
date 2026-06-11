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

  // 支出カテゴリー（8色）
  static const Color expense1 = Color(0xFFFF7171);
  static const Color expense2 = Color(0xFFFB5B01);
  static const Color expense3 = Color(0xFF3DD8E0);
  static const Color expense4 = Color(0xFF4BA6FF);
  static const Color expense5 = Color(0xFFBB87FF);
  static const Color expense6 = Color(0xFFDF2828);
  static const Color expense7 = Color(0xFFFFC700);
  static const Color expense8 = Color(0xFFAC3E00);

  // 収入カテゴリー（4色）
  static const Color income1 = Color(0xFF21D19F);
  static const Color income2 = Color(0xFF10B981);
  static const Color income3 = Color(0xFF059669);
  static const Color income4 = Color(0xFF6EE7B7);

  // 固定費カテゴリー
  static const Color fixedCost = Color(0xFF8E8E93);

  // --- DB保存用 6桁HEX（alpha無し） ---
  static const String expense1Hex = 'FF7171';
  static const String expense2Hex = 'FB5B01';
  static const String expense3Hex = '3DD8E0';
  static const String expense4Hex = '4BA6FF';
  static const String expense5Hex = 'BB87FF';
  static const String expense6Hex = 'DF2828';
  static const String expense7Hex = 'FFC700';
  static const String expense8Hex = 'AC3E00';
  static const String income1Hex = '21D19F';
  static const String income2Hex = '10B981';
  static const String income3Hex = '059669';
  static const String income4Hex = '6EE7B7';
  static const String fixedCostHex = '8E8E93';

  /// 支出パレットのスウォッチ（表示順）。
  static const List<Color> expenseSwatches = [expense1, expense2, expense3, expense4, expense5, expense6, expense7, expense8];

  /// 収入パレットのスウォッチ（表示順）。
  static const List<Color> incomeSwatches = [income1, income2, income3, income4];
}
