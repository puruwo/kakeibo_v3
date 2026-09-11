// 共通スイッチ AppSwitch（KP-013）の Widget 結合テスト
//
// - 入れ子の ThemeData を作らず、AppTheme の switchTheme で枠線なし・つまみ onPrimary になる
// - タップで onChanged が呼ばれる
// - AppInsetRow.switchRow が AppSwitch を使う
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/component/app_inset_group.dart';
import 'package:kakeibo/view/component/app_switch.dart';

import '../helper/widget_test_helper.dart';

void main() {
  for (final (mode, colors) in [
    (ThemeMode.light, AppColors.light),
    (ThemeMode.dark, AppColors.dark),
  ]) {
    testWidgets('$mode: スイッチの色はテーマから解決され、入れ子の Theme を作らない', (tester) async {
      await pumpApp(
        tester,
        home: Scaffold(
          body: Center(child: AppSwitch(value: true, onChanged: (_) {})),
        ),
        themeMode: mode,
      );

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.activeTrackColor, colors.primary);
      expect(switchWidget.inactiveTrackColor, colors.icon);
      expect(switchWidget.thumbColor?.resolve(const {}), colors.onPrimary);

      // Switch の直下でも AppColors 拡張が引ける（新規 ThemeData で落ちていない）
      final context = tester.element(find.byType(Switch));
      expect(Theme.of(context).extension<AppColors>(), same(colors));
      expect(
        Theme.of(context).switchTheme.trackOutlineColor?.resolve(const {}),
        Colors.transparent,
      );
    });
  }

  testWidgets('タップすると onChanged に反転した値が渡る', (tester) async {
    bool? received;
    await pumpApp(
      tester,
      home: Scaffold(
        body: Center(
          child: AppSwitch(value: false, onChanged: (v) => received = v),
        ),
      ),
    );

    await tester.tap(find.byType(Switch));
    await pumpTimes(tester, times: 3);

    expect(received, isTrue);
  });

  testWidgets('AppInsetRow.switchRow は AppSwitch を使う', (tester) async {
    await pumpApp(
      tester,
      home: Scaffold(
        body: AppInsetGroup(
          children: [
            AppInsetRow.switchRow(
              label: '固定費として登録',
              switchValue: false,
              onSwitchChanged: (_) {},
            ),
          ],
        ),
      ),
    );

    expect(find.byType(AppSwitch), findsOneWidget);
    expect(find.text('固定費として登録'), findsOneWidget);
  });
}
