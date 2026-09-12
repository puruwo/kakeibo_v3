// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$initialThemeModeHash() => r'a0c7fc6753efeccd43d643fd94f344d363a5347b';

/// 起動時に main() が事前読込したテーマモードの注入口（KP-013）
///
/// main() が ThemeModeStore から読んだ値を ProviderScope.overrides で注入する。
/// override されない場合（テスト等）は既定のライト。
///
/// Copied from [initialThemeMode].
@ProviderFor(initialThemeMode)
final initialThemeModeProvider = Provider<ThemeMode>.internal(
  initialThemeMode,
  name: r'initialThemeModeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$initialThemeModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InitialThemeModeRef = ProviderRef<ThemeMode>;
String _$themeModeNotifierHash() => r'20ed723cbadfb32b985eba37689ef62ebd6b24aa';

/// アプリのテーマモード（ライト／ダーク）。MaterialApp.themeMode が watch する
///
/// Copied from [ThemeModeNotifier].
@ProviderFor(ThemeModeNotifier)
final themeModeNotifierProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>.internal(
      ThemeModeNotifier.new,
      name: r'themeModeNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$themeModeNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ThemeModeNotifier = Notifier<ThemeMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
