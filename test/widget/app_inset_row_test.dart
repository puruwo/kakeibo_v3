// インセット行（lib/view/component/app_inset_group.dart）の値の数字版切り替え（KP-007）
//
// numericValue が true のとき、金額・日付などの値を sfUi 系の役割スタイル（insetGroupValueNumeric）で描く。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/view/component/app_inset_group.dart';

import '../helper/widget_test_helper.dart';

void main() {
  testWidgets('display 行: numericValue で値のスタイルが切り替わる', (tester) async {
    await pumpApp(
      tester,
      home: Scaffold(
        body: AppInsetGroup(
          header: '設定',
          children: const [
            AppInsetRow.display(
              label: '金額',
              value: '¥ 12,345',
              numericValue: true,
            ),
            AppInsetRow.display(label: '頻度', value: '1ヶ月に1回'),
          ],
        ),
      ),
    );
    await tester.pump();

    final price = tester.widget<Text>(find.text('¥ 12,345'));
    expect(price.style, AppTextStyles.insetGroupValueNumeric);
    expect(price.style!.fontFamily, 'sf_ui');

    final frequency = tester.widget<Text>(find.text('1ヶ月に1回'));
    expect(frequency.style, AppTextStyles.insetGroupValue);
    expect(frequency.style!.fontFamily, 'noto_sans');
  });

  testWidgets('display 行: valueColor は数字版でも色だけ上書きされる', (tester) async {
    await pumpApp(
      tester,
      home: Scaffold(
        body: AppInsetGroup(
          children: const [
            AppInsetRow.display(
              label: '次回支払日',
              value: '9月25日（金）',
              valueColor: Colors.green,
              numericValue: true,
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    final text = tester.widget<Text>(find.text('9月25日（金）'));
    expect(text.style!.fontFamily, 'sf_ui');
    expect(text.style!.color, Colors.green);
    expect(text.style!.fontSize, AppTextStyles.insetGroupValueNumeric.fontSize);
  });

  testWidgets('textField 行: numericValue で入力文字のスタイルが切り替わる', (tester) async {
    final controller = TextEditingController(text: '12000');
    addTearDown(controller.dispose);

    await pumpApp(
      tester,
      home: Scaffold(
        body: AppInsetGroup(
          children: [
            AppInsetRow.textField(
              label: '金額',
              controller: controller,
              numericValue: true,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    // TextFormField は style をテーマ既定とマージして EditableText に渡すため、
    // 等価比較ではなく family / size / weight を個別に確認する
    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.style.fontFamily, 'sf_ui');
    expect(
      editable.style.fontSize,
      AppTextStyles.insetGroupValueNumeric.fontSize,
    );
    expect(
      editable.style.fontWeight,
      AppTextStyles.insetGroupValueNumeric.fontWeight,
    );
  });
}
