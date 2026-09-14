import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/theme/app_theme.dart';

void main() {
  // light / dark の両方について、ThemeData がトークン（AppColors）を反映していることを確かめる。
  // 差があってよいのはトークン由来の値だけで、構成（AppBar 透明・スプラッシュ無し等）は共通
  final cases =
      <
        ({
          String name,
          ThemeData theme,
          AppColors colors,
          Brightness brightness,
        })
      >[
        (
          name: 'light',
          theme: AppTheme.light(),
          colors: AppColors.light,
          brightness: Brightness.light,
        ),
        (
          name: 'dark',
          theme: AppTheme.dark(),
          colors: AppColors.dark,
          brightness: Brightness.dark,
        ),
      ];

  for (final c in cases) {
    group('AppTheme.${c.name}', () {
      test('明度と AppColors 拡張がモードと一致する', () {
        expect(c.theme.brightness, c.brightness);
        expect(c.theme.extension<AppColors>(), same(c.colors));
      });

      test('Material 既定色（seed 紫）ではなくトークンで描く', () {
        expect(c.theme.colorScheme.primary, c.colors.primary);
        expect(c.theme.colorScheme.onPrimary, c.colors.onPrimary);
        expect(c.theme.colorScheme.surface, c.colors.surface);
        expect(c.theme.colorScheme.error, c.colors.danger);
        // 主要タブ・設定画面の地。サブページは部品側で surfaceElevated を明示する（T3）
        expect(c.theme.scaffoldBackgroundColor, c.colors.surface);
        expect(c.theme.dividerTheme.color, c.colors.separator);
        expect(c.theme.progressIndicatorTheme.color, c.colors.primary);
        expect(c.theme.textSelectionTheme.cursorColor, c.colors.primary);
        expect(c.theme.textTheme.bodyMedium?.color, c.colors.text);
      });

      test('AppBar は透明で、ステータスバーの文字色はモードに追従する', () {
        expect(c.theme.appBarTheme.backgroundColor, Colors.transparent);
        expect(c.theme.appBarTheme.elevation, 0);
        expect(c.theme.appBarTheme.scrolledUnderElevation, 0);
        expect(c.theme.appBarTheme.titleTextStyle?.color, c.colors.text);
        // ダーク地では白文字（Brightness.light）、ライト地では黒文字（Brightness.dark）
        expect(
          c.theme.appBarTheme.systemOverlayStyle?.statusBarIconBrightness,
          c.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        );
      });

      test('押下表現はスプラッシュ無し・ハイライトのみ（AppInkWell と同じ）', () {
        expect(c.theme.splashColor, Colors.transparent);
        expect(c.theme.splashFactory, NoSplash.splashFactory);
        expect(c.theme.highlightColor, c.colors.pressedOverlay);
      });

      test('ボトムシートの暗幕は scrim（期間ピッカーと同じ色）', () {
        expect(c.theme.bottomSheetTheme.modalBarrierColor, c.colors.scrim);
      });

      test('スイッチは枠線なし・つまみ onPrimary・トラックは primary / icon', () {
        final switchTheme = c.theme.switchTheme;
        expect(
          switchTheme.trackOutlineColor?.resolve(const {}),
          Colors.transparent,
        );
        expect(switchTheme.thumbColor?.resolve(const {}), c.colors.onPrimary);
        expect(
          switchTheme.trackColor?.resolve(const {WidgetState.selected}),
          c.colors.primary,
        );
        expect(switchTheme.trackColor?.resolve(const {}), c.colors.icon);
      });

      test('フォントは noto_sans', () {
        expect(c.theme.textTheme.bodyMedium?.fontFamily, 'noto_sans');
      });
    });
  }
}
