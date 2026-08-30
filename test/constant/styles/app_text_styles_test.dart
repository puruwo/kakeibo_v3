// テキストスタイルの3層構造（KP-007・Vault「Kakeibo テキストスタイルルール」§3）の固定テスト
//
// MyFontStyle（family）→ AppTypeScale（段）→ 役割スタイル（AppTextStyles 等）の値が
// 規約どおりに組み立てられていることを確認する。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/constant/font_style.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/constant/styles/app_type_scale.dart';
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
      final style = AppTextStyles.listTilePrimaryTitle;
      expect(style.fontFamily, AppTypeScale.noto14w500.fontFamily);
      expect(style.fontSize, AppTypeScale.noto14w500.fontSize);
      expect(style.fontWeight, AppTypeScale.noto14w500.fontWeight);
      expect(style.color, AppColorsDark.text);
    });

    test('数字が主役の兄弟スタイルは sf_ui（論点11）', () {
      final numeric = <String, TextStyle>{
        'pageHeaderNumeric': AppTextStyles.pageHeaderNumeric,
        'pageHeaderSubNumeric': AppTextStyles.pageHeaderSubNumeric,
        'appCardSectionNumeric': AppTextStyles.appCardSectionNumeric,
        'insetGroupHeaderNumeric': AppTextStyles.insetGroupHeaderNumeric,
        'insetGroupValueNumeric': AppTextStyles.insetGroupValueNumeric,
        'listCardSecondaryNumeric': AppTextStyles.listCardSecondaryNumeric,
        'numericCaption': AppTextStyles.numericCaption,
        'insetGroupHistoryDate': AppTextStyles.insetGroupHistoryDate,
        'graphMiniLabel': GraphTextStyles.graphMiniLabel,
      };
      numeric.forEach((name, style) {
        expect(style.fontFamily, 'sf_ui', reason: name);
      });
    });

    test('数字版と和文版はサイズ・ウェイトが同じで family だけ違う', () {
      expect(
        AppTextStyles.pageHeaderNumeric.fontSize,
        AppTextStyles.pageHeaderText.fontSize,
      );
      expect(
        AppTextStyles.pageHeaderNumeric.fontWeight,
        AppTextStyles.pageHeaderText.fontWeight,
      );
      expect(
        AppTextStyles.insetGroupValueNumeric.fontSize,
        AppTextStyles.insetGroupValue.fontSize,
      );
      expect(
        AppTextStyles.listCardSecondaryNumeric.fontWeight,
        AppTextStyles.listCardSecondaryTitle.fontWeight,
      );
    });

    test('和文が主役の見出しは noto（listCardSectionTitle・graphMiniTextLabel）', () {
      expect(AppTextStyles.listCardSectionTitle.fontFamily, 'noto_sans');
      expect(GraphTextStyles.graphMiniTextLabel.fontFamily, 'noto_sans');
      // 日付見出しは数字が主役なので sfUi のまま
      expect(AppTextStyles.listTileSectionTitle.fontFamily, 'sf_ui');
    });

    test('補助文字に w300 を使わない（論点12・ADR-017 #4 の改定）', () {
      final formerlyThin = <String, TextStyle>{
        'pageHeaderSubText': AppTextStyles.pageHeaderSubText,
        'unselectedLabelStyle': AppTextStyles.unselectedLabelStyle,
        'listTileSecondaryTitle': AppTextStyles.listTileSecondaryTitle,
        'listTileTertiaryTitle': AppTextStyles.listTileTertiaryTitle,
        'listTileLegendTitle': AppTextStyles.listTileLegendTitle,
        'insetGroupNote': AppTextStyles.insetGroupNote,
      };
      formerlyThin.forEach((name, style) {
        expect(style.fontWeight, FontWeight.w400, reason: name);
      });
    });

    test('読ませる説明文は 12px（insetGroupNote・pageHeaderSubText）', () {
      expect(AppTextStyles.insetGroupNote.fontSize, 12);
      expect(AppTextStyles.pageHeaderSubText.fontSize, 12);
    });

    test('強調スタイルは呼び出し側の fontWeight 上書きを置き換える', () {
      expect(AppTextStyles.dialogListEmphasis.fontWeight, FontWeight.w600);
      expect(
        AppTextStyles.dialogListEmphasis.fontSize,
        AppTextStyles.dialogList.fontSize,
      );
      expect(AppTextStyles.dialogLabelEmphasis.fontWeight, FontWeight.w600);
      expect(
        RegisterPageStyles.categoryLabelSelected.fontWeight,
        FontWeight.w700,
      );
      expect(
        RegisterPageStyles.categoryLabelUnselected.fontWeight,
        FontWeight.w400,
      );
      expect(
        GraphTextStyles.graphMiniLabelEmphasis.fontWeight,
        FontWeight.w700,
      );
    });

    test('yenSymbol は定義側で行高を詰める（呼び出し側の copyWith を廃止）', () {
      expect(RegisterPageStyles.yenSymbol(AppColorsDark.expense).height, 1.0);
      expect(
        RegisterPageStyles.yenSymbol(AppColorsDark.expense).color,
        AppColorsDark.expense,
      );
    });
  });
}
