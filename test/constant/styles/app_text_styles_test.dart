// テキストスタイルの3層構造（KP-007・Vault「Kakeibo テキストスタイルルール」§3）の固定テスト
//
// MyFontStyle（family）→ AppTypeScale（段）→ 役割スタイル（AppTextStyles 等）の値が
// 規約どおりに組み立てられていることを確認する。
// 役割スタイルは AppColors を受け取るインスタンス（KP-013）なので、context 無しの検証には
// 固定インスタンス AppTextStyles.light / dark を使う。
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/constant/font_style.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/constant/styles/app_type_scale.dart';
import 'package:kakeibo/constant/styles/calendar_styles.dart';
import 'package:kakeibo/constant/styles/graph_text_styles.dart';
import 'package:kakeibo/constant/styles/register_page_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';

void main() {
  group('MyFontStyle', () {
    test('sfUi は和文を同梱 Noto にフォールバックする（論点5・決定E）', () {
      expect(MyFontStyle.sfUi.fontFamily, 'sf_ui');
      expect(MyFontStyle.sfUi.fontFamilyFallback, ['noto_sans']);
    });

    test('notoSans は noto_sans', () {
      expect(MyFontStyle.notoSans.fontFamily, 'noto_sans');
    });
  });

  group('AppTypeScale', () {
    test('段は family × size × weight だけを持ち、色は持たない', () {
      expect(AppTypeScale.noto14w500.fontFamily, 'noto_sans');
      expect(AppTypeScale.noto14w500.fontSize, 14);
      expect(AppTypeScale.noto14w500.fontWeight, FontWeight.w500);
      expect(AppTypeScale.noto14w500.color, isNull);

      expect(AppTypeScale.sfUi17w600.fontFamily, 'sf_ui');
      expect(AppTypeScale.sfUi17w600.fontSize, 17);
      expect(AppTypeScale.sfUi17w600.fontWeight, FontWeight.w600);
      expect(AppTypeScale.sfUi17w600.color, isNull);
    });

    test('sfUi の段もフォールバックを引き継ぐ', () {
      expect(AppTypeScale.sfUi11w400.fontFamilyFallback, ['noto_sans']);
    });
  });

  group('役割スタイル', () {
    test('段の値に色を付けただけである（listTilePrimaryTitle）', () {
      // ライト／ダークのどちらのインスタンスでも段は同じで、色だけがそのモードのトークンになる
      final cases = [
        (AppTextStyles.light, AppColors.light),
        (AppTextStyles.dark, AppColors.dark),
      ];
      for (final (styles, colors) in cases) {
        final style = styles.listTilePrimaryTitle;
        expect(style.fontFamily, AppTypeScale.noto14w500.fontFamily);
        expect(style.fontSize, AppTypeScale.noto14w500.fontSize);
        expect(style.fontWeight, AppTypeScale.noto14w500.fontWeight);
        expect(style.color, colors.text);
      }
    });

    test('ライトとダークで変わるのは色だけ（KP-013）', () {
      final light = AppTextStyles.light.pageHeaderText;
      final dark = AppTextStyles.dark.pageHeaderText;
      expect(light.fontFamily, dark.fontFamily);
      expect(light.fontSize, dark.fontSize);
      expect(light.fontWeight, dark.fontWeight);
      expect(light.color, AppColors.light.text);
      expect(dark.color, AppColors.dark.text);
      expect(light.color, isNot(dark.color));
    });

    test('画面専用クラスも同じ型で色を受け取る（KP-013）', () {
      expect(RegisterPageStyles.dark.priceInput.color, AppColors.dark.text);
      expect(RegisterPageStyles.light.priceInput.color, AppColors.light.text);
      expect(
        CalendarStyles.light.calendarDateLabel.color,
        AppColors.light.textSecondary,
      );
      expect(
        GraphTextStyles.light.graphLabel.color,
        AppColors.light.textSecondary,
      );
    });

    test('数字が主役の兄弟スタイルは sf_ui（論点11）', () {
      final numeric = <String, TextStyle>{
        'pageHeaderNumeric': AppTextStyles.light.pageHeaderNumeric,
        'pageHeaderSubNumeric': AppTextStyles.light.pageHeaderSubNumeric,
        'appCardSectionNumeric': AppTextStyles.light.appCardSectionNumeric,
        'insetGroupHeaderNumeric': AppTextStyles.light.insetGroupHeaderNumeric,
        'insetGroupValueNumeric': AppTextStyles.light.insetGroupValueNumeric,
        'listCardSecondaryNumeric':
            AppTextStyles.light.listCardSecondaryNumeric,
        'numericCaption': AppTextStyles.light.numericCaption,
        'insetGroupHistoryDate': AppTextStyles.light.insetGroupHistoryDate,
        'graphMiniLabel': GraphTextStyles.light.graphMiniLabel,
      };
      numeric.forEach((name, style) {
        expect(style.fontFamily, 'sf_ui', reason: name);
      });
    });

    test('数字版と和文版はサイズ・ウェイトが同じで family だけ違う', () {
      final styles = AppTextStyles.light;
      expect(styles.pageHeaderNumeric.fontSize, styles.pageHeaderText.fontSize);
      expect(
        styles.pageHeaderNumeric.fontWeight,
        styles.pageHeaderText.fontWeight,
      );
      expect(
        styles.insetGroupValueNumeric.fontSize,
        styles.insetGroupValue.fontSize,
      );
      expect(
        styles.listCardSecondaryNumeric.fontWeight,
        styles.listCardSecondaryTitle.fontWeight,
      );
    });

    test('和文が主役の見出しは noto（listCardSectionTitle・graphMiniTextLabel）', () {
      expect(AppTextStyles.light.listCardSectionTitle.fontFamily, 'noto_sans');
      expect(GraphTextStyles.light.graphMiniTextLabel.fontFamily, 'noto_sans');
      // 日付見出しは数字が主役なので sfUi のまま
      expect(AppTextStyles.light.listTileSectionTitle.fontFamily, 'sf_ui');
    });

    test('補助文字に w300 を使わない（論点12・ADR-017 #4 の改定）', () {
      final styles = AppTextStyles.light;
      final formerlyThin = <String, TextStyle>{
        'pageHeaderSubText': styles.pageHeaderSubText,
        'unselectedLabelStyle': styles.unselectedLabelStyle,
        'listTileSecondaryTitle': styles.listTileSecondaryTitle,
        'listTileTertiaryTitle': styles.listTileTertiaryTitle,
        'listTileLegendTitle': styles.listTileLegendTitle,
        'insetGroupNote': styles.insetGroupNote,
      };
      formerlyThin.forEach((name, style) {
        expect(style.fontWeight, FontWeight.w400, reason: name);
      });
    });

    test('読ませる説明文は 12px（insetGroupNote・pageHeaderSubText）', () {
      expect(AppTextStyles.light.insetGroupNote.fontSize, 12);
      expect(AppTextStyles.light.pageHeaderSubText.fontSize, 12);
    });

    test('強調スタイルは呼び出し側の fontWeight 上書きを置き換える', () {
      final styles = AppTextStyles.light;
      expect(styles.dialogListEmphasis.fontWeight, FontWeight.w600);
      expect(styles.dialogListEmphasis.fontSize, styles.dialogList.fontSize);
      expect(styles.dialogLabelEmphasis.fontWeight, FontWeight.w600);
      expect(
        RegisterPageStyles.light.categoryLabelSelected.fontWeight,
        FontWeight.w700,
      );
      expect(
        RegisterPageStyles.light.categoryLabelUnselected.fontWeight,
        FontWeight.w400,
      );
      expect(
        GraphTextStyles.light.graphMiniLabelEmphasis.fontWeight,
        FontWeight.w700,
      );
    });

    test('yenSymbol は定義側で行高を詰める（呼び出し側の copyWith を廃止）', () {
      expect(RegisterPageStyles.yenSymbol(AppColors.dark.expense).height, 1.0);
      expect(
        RegisterPageStyles.yenSymbol(AppColors.dark.expense).color,
        AppColors.dark.expense,
      );
    });

    test('popupMenuItemLabel は色を省略すると現在のテーマの text になる', () {
      expect(
        AppTextStyles.light.popupMenuItemLabel().color,
        AppColors.light.text,
      );
      expect(
        AppTextStyles.dark.popupMenuItemLabel(isSelected: true).fontWeight,
        FontWeight.w700,
      );
    });
  });

  // 役割スタイルを列挙するテストは追加漏れを検知できないため、定義ソースに対する不変条件で補う。
  // flutter test はパッケージルートを cwd にして走るので相対パスで読める
  group('定義ソースの不変条件', () {
    test('AppTypeScale に w300 の段が無い（論点12）', () {
      final source = File(
        'lib/constant/styles/app_type_scale.dart',
      ).readAsStringSync();
      expect(source, isNot(contains('w300')));
    });

    test('Numeric サフィックスの役割スタイルはすべて sfUi の段を参照する（論点11）', () {
      // 役割スタイルは `TextStyle get xxxNumeric => AppTypeScale.…` の getter 書式（KP-013）
      final pattern = RegExp(
        r'TextStyle\s+get\s+(\w+Numeric)\s*=>\s*AppTypeScale\.(\w+)',
      );
      var count = 0;
      final files = Directory(
        'lib/constant/styles',
      ).listSync().whereType<File>();
      for (final file in files) {
        for (final match in pattern.allMatches(file.readAsStringSync())) {
          count++;
          expect(
            match.group(2),
            startsWith('sfUi'),
            reason: '${match.group(1)} (${file.path})',
          );
        }
      }
      // 正規表現が定義の書式とずれて空振りしていないことも確認する
      expect(count, greaterThan(0));
    });

    test('役割スタイルの定義に静的なダーク値（AppColorsDark）を残さない（KP-013）', () {
      final files = Directory(
        'lib/constant/styles',
      ).listSync().whereType<File>();
      for (final file in files) {
        expect(
          file.readAsStringSync(),
          isNot(contains('AppColorsDark')),
          reason: file.path,
        );
      }
    });
  });
}
