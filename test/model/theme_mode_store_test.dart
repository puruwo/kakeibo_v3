import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/model/theme_mode_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // ThemeModeStore は SharedPreferences 実装のため、
  // プラグインのモックを差し込めるようバインディングを初期化しておく
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // テストごとに保存内容を空（未設定）に戻す
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeModeStore.fetch', () {
    test('未保存なら既定のライトを返す', () async {
      expect(await ThemeModeStore().fetch(), ThemeMode.light);
    });

    test('保存したダークを再読込で返す', () async {
      final store = ThemeModeStore();
      await store.save(ThemeMode.dark);
      expect(await store.fetch(), ThemeMode.dark);
    });

    test('保存形式は文字列（将来 system を足せる形）', () async {
      await ThemeModeStore().save(ThemeMode.dark);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(ThemeModeStore.key), 'dark');
    });

    test('不正な保存値なら既定のライトへフォールバックする', () async {
      // 旧バージョンや手動編集で壊れた値を想定
      SharedPreferences.setMockInitialValues({ThemeModeStore.key: 'blue'});
      expect(await ThemeModeStore().fetch(), ThemeMode.light);
    });
  });

  group('ThemeModeStore.serialize / parse', () {
    test('全モードが往復で一致する', () {
      for (final mode in ThemeMode.values) {
        expect(ThemeModeStore.parse(ThemeModeStore.serialize(mode)), mode);
      }
    });

    test('null は既定のライト', () {
      expect(ThemeModeStore.parse(null), ThemeMode.light);
    });
  });
}
