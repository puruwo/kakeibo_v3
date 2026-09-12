import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// テーマモード（ライト／ダーク）の保存ストア（KP-013）
///
/// SharedPreferences に文字列で保持する。未保存・不正値は既定のライトを返す。
/// 保存形式を bool ではなく文字列にしているのは、将来「端末に合わせる」（system）を
/// 選択肢に追加できるようにするため。
class ThemeModeStore {
  /// 保存キー
  static const String key = 'theme_mode';

  /// 既定のテーマモード
  static const ThemeMode defaultMode = ThemeMode.light;

  /// 保存されたテーマモードを取得する（未保存・不正値は既定値）
  Future<ThemeMode> fetch() async {
    final prefs = await SharedPreferences.getInstance();
    return parse(prefs.getString(key));
  }

  /// テーマモードを保存する
  Future<void> save(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, serialize(mode));
  }

  /// enum → 保存文字列
  static String serialize(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };

  /// 保存文字列 → enum（未知の値は既定値）
  static ThemeMode parse(String? value) => switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => defaultMode,
  };
}
