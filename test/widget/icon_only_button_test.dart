// Icon-onlyボタン（lib/view/component/button_util.dart IconOnlyButton）のWidget結合テスト
//
// KP-006 ボタンルール §3・§5: 非活性は onTap null で表現し、枠の有無は bordered で切り替える。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/component/app_icon_circle_container.dart';
import 'package:kakeibo/view/component/button_util.dart';

import '../helper/widget_test_helper.dart';

void main() {
  /// 円の地色を取り出す
  AppIconCircleContainer circleOf(WidgetTester tester) => tester
      .widget<AppIconCircleContainer>(find.byType(AppIconCircleContainer));

  Icon iconOf(WidgetTester tester) => tester.widget<Icon>(find.byType(Icon));

  /// 外枠（shape: circle の BoxDecoration）を持つ Container の数
  int borderedContainerCount(WidgetTester tester) =>
      tester.widgetList<Container>(find.byType(Container)).where((c) {
        final d = c.decoration;
        return d is BoxDecoration &&
            d.shape == BoxShape.circle &&
            d.border != null;
      }).length;

  group('IconOnlyButton', () {
    testWidgets(
      '活性時はタップで onTap が呼ばれ、既定の色（fillQuaternary / textSecondary）で描かれる',
      (tester) async {
        var tapped = 0;
        late BuildContext ctx;
        await pumpApp(
          tester,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                ctx = context;
                return Center(
                  child: IconOnlyButton(
                    icon: Icons.add_rounded,
                    onTap: () => tapped++,
                  ),
                );
              },
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.byType(IconOnlyButton));
        await tester.pump();

        expect(tapped, 1);
        expect(circleOf(tester).color, ctx.colors.fillQuaternary);
        expect(iconOf(tester).color, ctx.colors.textSecondary);
        // 既定: 塗り46・アイコンは40%・枠あり
        expect(circleOf(tester).size, 46);
        expect(iconOf(tester).size, 46 * 0.4);
        expect(borderedContainerCount(tester), 1);
      },
    );

    testWidgets(
      'onTap が null なら指定色に関わらず地は fillQuaternary・アイコンは textTertiary に沈みタップできない',
      (tester) async {
        late BuildContext ctx;
        await pumpApp(
          tester,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                ctx = context;
                return Center(
                  child: IconOnlyButton(
                    icon: Icons.add_rounded,
                    onTap: null,
                    backgroundColor: context.colors.primaryTint,
                    iconColor: context.colors.primary,
                  ),
                );
              },
            ),
          ),
        );
        await tester.pump();

        expect(circleOf(tester).color, ctx.colors.fillQuaternary);
        expect(iconOf(tester).color, ctx.colors.textTertiary);
        // InkWell の onTap も null（Semantics 上も非活性）
        final ink = tester.widget<InkWell>(find.byType(InkWell));
        expect(ink.onTap, isNull);
      },
    );

    testWidgets('bordered: false なら外枠の Container を持たず、iconSize でアイコン径を上書きできる', (
      tester,
    ) async {
      await pumpApp(
        tester,
        home: Scaffold(
          body: Center(
            child: IconOnlyButton(
              icon: Icons.remove_rounded,
              onTap: () {},
              bordered: false,
              iconSize: 23,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(borderedContainerCount(tester), 0);
      expect(iconOf(tester).size, 23);
    });
  });
}
