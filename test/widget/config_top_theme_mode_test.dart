// 設定画面の「ダークモード」スイッチ行（KP-013）の Widget 結合テスト
//
// - 既定（ライト）ではスイッチが OFF で表示される
// - スイッチ操作でアプリのテーマがダークへ切り替わり、SharedPreferences に保存される
// - 行のタップでも切り替わる（ダーク → ライトへ戻す）
// - 保存済みの値（ダーク）で起動するとスイッチが ON で表示される
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/model/theme_mode_store.dart';
import 'package:kakeibo/view/component/app_switch.dart';
import 'package:kakeibo/view/config/config_top.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/widget_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // テーマモードは SharedPreferences に保存されるためモックを初期化する
    SharedPreferences.setMockInitialValues({});
  });

  /// 設定画面（ConfigTop）の context から現在の明度を読む
  Brightness brightnessOf(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(ConfigTop))).brightness;

  testWidgets('既定はライトで、「ダークモード」のスイッチは OFF', (tester) async {
    await pumpApp(tester, home: const ConfigTop());
    await pumpTimes(tester);

    expect(find.text('ダークモード'), findsOneWidget);
    final switchWidget = tester.widget<AppSwitch>(find.byType(AppSwitch));
    expect(switchWidget.value, isFalse);
    expect(brightnessOf(tester), Brightness.light);
  });

  testWidgets('スイッチを操作するとダークに切り替わり、保存される', (tester) async {
    await pumpApp(tester, home: const ConfigTop());
    await pumpTimes(tester);

    await tester.tap(find.byType(Switch));
    // 保存（非同期）とテーマ切替のアニメーションを進める
    await pumpTimes(tester, times: 5);

    expect(brightnessOf(tester), Brightness.dark);
    expect(tester.widget<AppSwitch>(find.byType(AppSwitch)).value, isTrue);
    expect(await ThemeModeStore().fetch(), ThemeMode.dark);
  });

  testWidgets('行のタップでも切り替わる（ダーク → ライト）', (tester) async {
    await pumpApp(tester, home: const ConfigTop(), themeMode: ThemeMode.dark);
    await pumpTimes(tester);
    expect(brightnessOf(tester), Brightness.dark);

    await tester.tap(find.text('ダークモード'));
    await pumpTimes(tester, times: 5);

    expect(brightnessOf(tester), Brightness.light);
    expect(tester.widget<AppSwitch>(find.byType(AppSwitch)).value, isFalse);
    expect(await ThemeModeStore().fetch(), ThemeMode.light);
  });

  testWidgets('保存済みの値（ダーク）で起動するとスイッチは ON', (tester) async {
    // main() は保存値を initialThemeMode に注入する。pumpApp の themeMode 引数がその代わり
    await pumpApp(tester, home: const ConfigTop(), themeMode: ThemeMode.dark);
    await pumpTimes(tester);

    expect(tester.widget<AppSwitch>(find.byType(AppSwitch)).value, isTrue);
    expect(brightnessOf(tester), Brightness.dark);
  });
}
