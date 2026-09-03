// 一覧行カード（lib/view/component/app_list_card.dart）の副ラベルの数字版切り替え（KP-007）
//
// subtitleLeadingNumeric が true のとき、日付「8月25日」などの副ラベルを sfUi 系の役割スタイルで描く。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/view/component/app_list_card.dart';

import '../helper/widget_test_helper.dart';

void main() {
  Future<Text> pumpAndFindSubtitle(
    WidgetTester tester, {
    required bool numeric,
  }) async {
    await pumpApp(
      tester,
      home: Scaffold(
        body: AppListCard(
          primaryTitle: '食費',
          subtitleLeading: '8月25日',
          subtitleLeadingNumeric: numeric,
          priceLabel: '¥ 1,000',
          isIncome: false,
        ),
      ),
    );
    await tester.pump();
    return tester.widget<Text>(find.text('8月25日'));
  }

  testWidgets(
    'subtitleLeadingNumeric: true なら副ラベルは sf_ui（listCardSecondaryNumeric）',
    (tester) async {
      final text = await pumpAndFindSubtitle(tester, numeric: true);
      expect(text.style, AppTextStyles.listCardSecondaryNumeric);
      expect(text.style!.fontFamily, 'sf_ui');
    },
  );

  testWidgets('既定（false）なら副ラベルは noto（listCardSecondaryTitle）', (tester) async {
    final text = await pumpAndFindSubtitle(tester, numeric: false);
    expect(text.style, AppTextStyles.listCardSecondaryTitle);
    expect(text.style!.fontFamily, 'noto_sans');
  });
}
