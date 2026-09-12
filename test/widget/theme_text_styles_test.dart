// 役割テキストスタイルの色がテーマに追従すること（KP-013・案C）の Widget 結合テスト
//
// - context.textStyles / registerStyles / calendarStyles / graphStyles がライトではライトの色、
//   ダークではダークの色を返す
// - MyIcon.next の色もテーマに追従する
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/constant/styles/calendar_styles.dart';
import 'package:kakeibo/constant/styles/graph_text_styles.dart';
import 'package:kakeibo/constant/styles/register_page_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';

import '../helper/widget_test_helper.dart';

void main() {
  /// 画面の代わりに context を捕まえるだけの Widget を描く
  Future<BuildContext> pumpProbe(
    WidgetTester tester, {
    required ThemeMode themeMode,
  }) async {
    late BuildContext captured;
    await pumpApp(
      tester,
      home: Builder(
        builder: (context) {
          captured = context;
          return const SizedBox.shrink();
        },
      ),
      themeMode: themeMode,
    );
    return captured;
  }

  for (final (mode, colors) in [
    (ThemeMode.light, AppColors.light),
    (ThemeMode.dark, AppColors.dark),
  ]) {
    testWidgets('$mode: 役割スタイルの色がそのモードのトークンになる', (tester) async {
      final context = await pumpProbe(tester, themeMode: mode);

      // 共通
      expect(context.textStyles.pageHeaderText.color, colors.text);
      expect(
        context.textStyles.listTileSecondaryTitle.color,
        colors.textSecondary,
      );
      expect(
        context.textStyles.insetGroupPlaceholder.color,
        colors.textTertiary,
      );
      expect(context.textStyles.textButtonTextStyle.color, colors.primary);
      // 画面専用
      expect(context.registerStyles.priceInput.color, colors.text);
      expect(
        context.calendarStyles.calendarDateLabel.color,
        colors.textSecondary,
      );
      expect(
        context.calendarStyles.calendarWeekdaySunday.color,
        colors.expense,
      );
      expect(context.graphStyles.graphMiniLabelEmphasis.color, colors.text);
      // 段（family / size / weight）はモードで変わらない
      expect(
        context.textStyles.pageHeaderText.fontSize,
        AppTextStyles.light.pageHeaderText.fontSize,
      );
      expect(
        context.graphStyles.graphLabel.fontFamily,
        GraphTextStyles.light.graphLabel.fontFamily,
      );
      expect(
        context.calendarStyles.calendarDateLabel.fontWeight,
        CalendarStyles.light.calendarDateLabel.fontWeight,
      );
      expect(
        context.registerStyles.priceInput.fontSize,
        RegisterPageStyles.light.priceInput.fontSize,
      );
    });

    testWidgets('$mode: MyIcon.next の色は textTertiary', (tester) async {
      final context = await pumpProbe(tester, themeMode: mode);
      expect(MyIcon.next(context).color, colors.textTertiary);
    });
  }
}
