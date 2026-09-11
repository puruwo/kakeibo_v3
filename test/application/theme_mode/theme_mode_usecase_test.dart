import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/theme_mode/theme_mode_usecase.dart';
import 'package:kakeibo/model/theme_mode_store.dart';
import 'package:kakeibo/view_model/state/theme_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helper/test_container.dart';

void main() {
  // ThemeModeStore は SharedPreferences 実装のため、
  // プラグインのモックを差し込めるようバインディングを初期化しておく
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // テストごとに保存内容を空（未設定）に戻す
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeModeNotifier', () {
    test('注入が無ければ既定のライトから始まる', () {
      final container = createContainer();
      expect(container.read(themeModeNotifierProvider), ThemeMode.light);
    });

    test('main() が事前読込した保存値（ダーク）から始まる', () {
      // 本番は initialThemeModeProvider を ProviderScope.overrides で注入する
      final container = createContainer(
        overrides: [initialThemeModeProvider.overrideWithValue(ThemeMode.dark)],
      );
      expect(container.read(themeModeNotifierProvider), ThemeMode.dark);
    });
  });

  group('ThemeModeUsecase.save', () {
    test('状態を即時に切り替え、SharedPreferences にも保存する', () async {
      final container = createContainer();
      final usecase = container.read(themeModeUsecaseProvider);

      await usecase.save(ThemeMode.dark);

      expect(container.read(themeModeNotifierProvider), ThemeMode.dark);
      // 次回起動時に main() が読む値も更新されている
      expect(await ThemeModeStore().fetch(), ThemeMode.dark);
    });

    test('ライトへ戻すと状態と保存値の両方が light になる', () async {
      final container = createContainer(
        overrides: [initialThemeModeProvider.overrideWithValue(ThemeMode.dark)],
      );
      final usecase = container.read(themeModeUsecaseProvider);

      await usecase.save(ThemeMode.light);

      expect(container.read(themeModeNotifierProvider), ThemeMode.light);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(ThemeModeStore.key), 'light');
    });
  });
}
