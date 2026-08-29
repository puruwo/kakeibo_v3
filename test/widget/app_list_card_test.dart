// 一覧行カード（lib/view/component/app_list_card.dart）のWidget結合テスト
//
// KP-004: 一覧行カードの角丸がボタンと同じ12px（appListCardRadius）であることを確認する。
// 面カード（CardContainer, appCardRadius=18px）とは別トークンで管理されている。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/view/component/app_list_card.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/component/card_container.dart';

import '../helper/widget_test_helper.dart';

void main() {
  test('appListCardRadius はボタンの角丸（kButtonRadius）と同値で、面カードより小さい', () {
    expect(appListCardRadius, kButtonRadius);
    expect(
      appListCardRadius.topLeft.x,
      lessThan(appCardRadius.topLeft.x),
    );
  });

  testWidgets('AppListCard の Material が appListCardRadius で描かれる', (tester) async {
    await pumpApp(
      tester,
      home: const Scaffold(
        body: AppListCard(
          primaryTitle: '食費',
          priceLabel: '¥ 1,000',
          isIncome: false,
        ),
      ),
    );
    await tester.pump();

    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(AppListCard),
        matching: find.byType(Material),
      ),
    );
    expect(material.borderRadius, appListCardRadius);
  });
}
