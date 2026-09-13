// カテゴリー比率行（lib/view/component/category_ratio_row.dart）の縦揃え（KP-017）
//
// 上段のアイコン＋名称と金額、下段の構成比バーと比率が、それぞれ縦中心で揃うことを固定する。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/view/component/category_ratio_row.dart';

import '../helper/widget_test_helper.dart';

void main() {
  const iconKey = Key('category-icon');

  Future<void> pumpRow(WidgetTester tester) async {
    await pumpApp(
      tester,
      home: Scaffold(
        body: Center(
          child: CategoryRatioRow(
            icon: const SizedBox(key: iconKey, width: 25, height: 25),
            name: '月次収入',
            priceLabel: '¥ 3,000,000',
            ratio: 1.0,
            colorCode: 'FF7171',
            onTap: () {},
          ),
        ),
      ),
    );
    await tester.pump();
  }

  double centerY(WidgetTester tester, Finder finder) =>
      tester.getCenter(finder).dy;

  testWidgets('上段: アイコンと名称と金額の縦中心が揃う', (tester) async {
    await pumpRow(tester);

    final iconY = centerY(tester, find.byKey(iconKey));
    expect(centerY(tester, find.text('月次収入')), moreOrLessEquals(iconY));
    expect(
      centerY(tester, find.text('¥ 3,000,000')),
      moreOrLessEquals(iconY),
    );
  });

  testWidgets('下段: 構成比バーと比率の縦中心が揃う', (tester) async {
    await pumpRow(tester);

    final barY = centerY(tester, find.byType(CategoryRatioBar));
    expect(centerY(tester, find.text('100.0%')), moreOrLessEquals(barY));
  });

  testWidgets('比率の右端が金額の右端と揃う', (tester) async {
    await pumpRow(tester);

    expect(
      tester.getTopRight(find.text('100.0%')).dx,
      moreOrLessEquals(tester.getTopRight(find.text('¥ 3,000,000')).dx),
    );
  });
}
