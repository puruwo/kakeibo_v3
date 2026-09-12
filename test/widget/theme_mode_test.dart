// テーマモードの配線（pumpApp ＝ 本番 KakeiboApp と同じ構成）の Widget 結合テスト
//
// - 既定はライトで AppColors.light が Theme に登録される
// - themeMode 引数でダーク始まりにできる
// - themeModeNotifierProvider を切り替えると MaterialApp が追従する（設定画面の切替行が使う経路）
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view_model/state/theme_mode.dart';

import '../helper/widget_test_helper.dart';

void main() {
  /// 画面の代わりに context を捕まえるだけの Widget を描く
  Future<BuildContext> pumpProbe(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
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

  testWidgets('既定はライトで、AppColors.light が Theme に登録される', (tester) async {
    final context = await pumpProbe(tester);

    expect(Theme.of(context).brightness, Brightness.light);
    expect(context.colors, same(AppColors.light));
  });

  testWidgets('themeMode: dark を渡すとダークで描く', (tester) async {
    final context = await pumpProbe(tester, themeMode: ThemeMode.dark);

    expect(Theme.of(context).brightness, Brightness.dark);
    expect(context.colors, same(AppColors.dark));
  });

  testWidgets('テーマモードを切り替えると MaterialApp が追従する', (tester) async {
    final context = await pumpProbe(tester);
    expect(Theme.of(context).brightness, Brightness.light);

    ProviderScope.containerOf(
      context,
    ).read(themeModeNotifierProvider.notifier).updateState(ThemeMode.dark);
    // テーマ切替のアニメーション（kThemeAnimationDuration）を進める
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(Theme.of(context).brightness, Brightness.dark);
    expect(context.colors.surface, AppColors.dark.surface);
    expect(context.colors.text, AppColors.dark.text);
  });
}
