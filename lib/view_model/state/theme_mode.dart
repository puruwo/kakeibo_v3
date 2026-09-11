import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'theme_mode.g.dart';

/// 起動時に main() が事前読込したテーマモードの注入口（KP-013）
///
/// main() が ThemeModeStore から読んだ値を ProviderScope.overrides で注入する。
/// override されない場合（テスト等）は既定のライト。
@Riverpod(keepAlive: true)
ThemeMode initialThemeMode(Ref ref) {
  return ThemeMode.light;
}

/// アプリのテーマモード（ライト／ダーク）。MaterialApp.themeMode が watch する
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    // 起動時に事前読込した値から始める
    return ref.read(initialThemeModeProvider);
  }

  void updateState(ThemeMode mode) {
    // データを上書き（保存は ThemeModeUsecase が行う）
    state = mode;
  }
}
