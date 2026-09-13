// 共通チップ（lib/view/component/app_chip_label.dart）の見た目（KP-019）
//
// アプリ内のチップを1つに統一した決定（案C: グレー＋中太字・外側余白なし）を固定する。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/component/app_chip_label.dart';

import '../helper/widget_test_helper.dart';

void main() {
  Future<void> pumpChip(WidgetTester tester, {required String label}) async {
    await pumpApp(
      tester,
      home: Scaffold(
        body: Center(child: AppChipLabel(label: label)),
      ),
    );
    await tester.pump();
  }

  Container chipContainer(WidgetTester tester) => tester.widget<Container>(
    find.descendant(
      of: find.byType(AppChipLabel),
      matching: find.byType(Container),
    ),
  );

  testWidgets('渡した文言を chipLabel で表示する', (tester) async {
    await pumpChip(tester, label: '変動');

    final context = tester.element(find.byType(AppChipLabel));
    final text = tester.widget<Text>(find.text('変動'));
    expect(text.style, context.textStyles.chipLabel);
  });

  testWidgets('地は fillTertiary・角丸4px・枠なし', (tester) async {
    await pumpChip(tester, label: '固定費');

    final context = tester.element(find.byType(AppChipLabel));
    final decoration = chipContainer(tester).decoration! as BoxDecoration;
    expect(decoration.color, context.colors.fillTertiary);
    expect(decoration.borderRadius, BorderRadius.circular(4));
    expect(decoration.border, isNull);
  });

  testWidgets('外側の余白を持たず、チップの幅は文言＋左右6px', (tester) async {
    await pumpChip(tester, label: '固定費');

    expect(chipContainer(tester).margin, isNull);
    final chipWidth = tester.getSize(find.byType(AppChipLabel)).width;
    final textWidth = tester.getSize(find.text('固定費')).width;
    expect(chipWidth, moreOrLessEquals(textWidth + 12));
  });

  test('chipLabel は noto 10 w500 textSecondary（案C）', () {
    for (final styles in [AppTextStyles.light, AppTextStyles.dark]) {
      final style = styles.chipLabel;
      expect(style.fontFamily, 'noto_sans');
      expect(style.fontSize, 10);
      expect(style.fontWeight, FontWeight.w500);
      expect(style.color, styles.colors.textSecondary);
    }
  });
}
