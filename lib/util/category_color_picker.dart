import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';

/// 新規カテゴリーの既定色を選ぶ（KP-012 D-07）
///
/// スウォッチの並び順で、既存カテゴリーがまだ使っていない先頭の色を返す。
/// 全色が使用済みならスウォッチの先頭色を返す（旧仕様の固定既定色と同じ挙動に退避）。
class CategoryColorPicker {
  CategoryColorPicker._();

  /// [swatches] の順に走査し、[usedColorCodes]（6桁HEX。大文字小文字は問わない）に
  /// 含まれない最初の色を返す。
  static Color firstUnused({
    required List<Color> swatches,
    required Iterable<String> usedColorCodes,
  }) {
    final used = usedColorCodes.map((code) => code.toUpperCase()).toSet();
    for (final color in swatches) {
      if (!used.contains(ColorCode.toHex(color))) {
        return color;
      }
    }
    return swatches.first;
  }
}
