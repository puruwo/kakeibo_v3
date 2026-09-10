// CategoryColorPicker（新規カテゴリーの既定色選定）のロジックUT（KP-012 D-07）
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/theme/category_palette.dart';
import 'package:kakeibo/util/category_color_picker.dart';

void main() {
  group('CategoryColorPicker.firstUnused', () {
    test('使用済みの色が無ければスウォッチの先頭色を返す', () {
      final color = CategoryColorPicker.firstUnused(
        swatches: CategoryPalette.expenseSwatches,
        usedColorCodes: const [],
      );
      expect(color, CategoryPalette.expense1);
    });

    test('先頭から使用済みの色を飛ばし、最初の未使用色を返す', () {
      final color = CategoryColorPicker.firstUnused(
        swatches: CategoryPalette.expenseSwatches,
        usedColorCodes: [
          CategoryPalette.expense1Hex,
          CategoryPalette.expense2Hex,
          CategoryPalette.expense4Hex, // 3 は空いている
        ],
      );
      expect(color, CategoryPalette.expense3);
    });

    test('使用済みの色コードは大文字小文字を区別しない', () {
      final color = CategoryColorPicker.firstUnused(
        swatches: CategoryPalette.expenseSwatches,
        usedColorCodes: [CategoryPalette.expense1Hex.toLowerCase()],
      );
      expect(color, CategoryPalette.expense2);
    });

    test('既定12カテゴリーが全て使う色を除くと、残りの先頭（brown）を返す', () {
      // シード（sql_on_create）の割当: 1,2,6,7,9,10,3,8,11,5,4,gray
      final color = CategoryColorPicker.firstUnused(
        swatches: CategoryPalette.expenseSwatches,
        usedColorCodes: [
          CategoryPalette.expense1Hex,
          CategoryPalette.expense2Hex,
          CategoryPalette.expense6Hex,
          CategoryPalette.expense7Hex,
          CategoryPalette.expense9Hex,
          CategoryPalette.expense10Hex,
          CategoryPalette.expense3Hex,
          CategoryPalette.expense8Hex,
          CategoryPalette.expense11Hex,
          CategoryPalette.expense5Hex,
          CategoryPalette.expense4Hex,
          CategoryPalette.grayHex,
        ],
      );
      expect(color, CategoryPalette.expense12);
    });

    test('全色が使用済みならスウォッチの先頭色に退避する', () {
      final color = CategoryColorPicker.firstUnused(
        swatches: CategoryPalette.incomeSwatches,
        usedColorCodes: [
          CategoryPalette.income1Hex,
          CategoryPalette.income2Hex,
          CategoryPalette.income3Hex,
          CategoryPalette.income4Hex,
        ],
      );
      expect(color, CategoryPalette.income1);
    });

    test('パレット外の色コードが混ざっていても無視して選ぶ', () {
      final color = CategoryColorPicker.firstUnused(
        swatches: CategoryPalette.incomeSwatches,
        usedColorCodes: ['FF7171', CategoryPalette.income1Hex],
      );
      expect(color, CategoryPalette.income2);
    });

    test('スウォッチは Color と 6桁HEX が対応している（変換の前提）', () {
      // firstUnused は Color → HEX 変換で比較するため、パレットの両表現が一致していること
      final swatches = CategoryPalette.expenseSwatches;
      final hexes = [
        CategoryPalette.expense1Hex,
        CategoryPalette.expense2Hex,
        CategoryPalette.expense3Hex,
        CategoryPalette.expense4Hex,
        CategoryPalette.expense5Hex,
        CategoryPalette.expense6Hex,
        CategoryPalette.expense7Hex,
        CategoryPalette.expense8Hex,
        CategoryPalette.expense9Hex,
        CategoryPalette.expense10Hex,
        CategoryPalette.expense11Hex,
        CategoryPalette.expense12Hex,
        CategoryPalette.grayHex,
      ];
      expect(swatches, hasLength(13));
      for (var i = 0; i < swatches.length; i++) {
        expect(Color(int.parse('FF${hexes[i]}', radix: 16)), swatches[i]);
      }
    });
  });
}
