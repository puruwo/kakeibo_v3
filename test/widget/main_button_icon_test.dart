// MainButton の iconData（lib/view/component/button_util.dart）のWidget結合テスト
//
// KP-023 ボタン内アイコン基準: 完了・追加・削除の主操作は AppIcons の意味名を iconData で渡し、
// アイコンは文字色と同色・18px・非活性時は textTertiary で描かれる。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/component/button_util.dart';

import '../helper/widget_test_helper.dart';

void main() {
  Future<BuildContext> pumpButton(
    WidgetTester tester, {
    required ButtonColorType type,
    VoidCallback? onPressed,
    Color? textColor,
  }) async {
    late BuildContext ctx;
    await pumpApp(
      tester,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            ctx = context;
            return Center(
              child: MainButton(
                buttonType: type,
                iconData: AppIcons.done,
                textColor: textColor,
                onPressed: onPressed,
                buttonText: '保存',
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();
    return ctx;
  }

  Icon iconOf(WidgetTester tester) => tester.widget<Icon>(find.byType(Icon));

  group('MainButton.iconData', () {
    testWidgets('main 種別ではアイコンが primary 色・18px で文字の左に描かれる', (tester) async {
      final ctx = await pumpButton(
        tester,
        type: ButtonColorType.main,
        onPressed: () {},
      );

      final icon = iconOf(tester);
      expect(icon.icon, AppIcons.done);
      expect(icon.size, 18);
      expect(icon.color, ctx.colors.primary);
      // アイコンは文字より左
      expect(
        tester.getTopLeft(find.byType(Icon)).dx,
        lessThan(tester.getTopLeft(find.text('保存')).dx),
      );
    });

    testWidgets('textColor 指定時（secondary 地の削除）はアイコンも同じ色になる', (tester) async {
      final ctx = await pumpButton(
        tester,
        type: ButtonColorType.secondary,
        textColor: Colors.red,
        onPressed: () {},
      );
      expect(iconOf(tester).color, Colors.red);
      expect(iconOf(tester).color, isNot(ctx.colors.text));
    });

    testWidgets('非活性（onPressed null）ではアイコンも textTertiary になる', (tester) async {
      final ctx = await pumpButton(tester, type: ButtonColorType.main);
      expect(iconOf(tester).color, ctx.colors.textTertiary);
    });

    testWidgets('iconData を渡さなければアイコンは描かれない', (tester) async {
      await pumpApp(
        tester,
        home: Scaffold(
          body: MainButton(
            buttonType: ButtonColorType.secondary,
            onPressed: () {},
            buttonText: 'キャンセル',
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(Icon), findsNothing);
    });
  });
}
