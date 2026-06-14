import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// バンドル済みフォント（noto_sans / sf_ui）をテストランタイムへ読み込む。
/// これを呼ばないと golden は既定フォントになり実機と字形がずれる。
Future<void> loadAppFonts() async {
  final families = <String, List<String>>{
    'noto_sans': [
      'assets/fonts/noto-sans-jp-thin-100.ttf',
      'assets/fonts/noto-sans-jp-extralight-200.ttf',
      'assets/fonts/noto-sans-jp-light-300.ttf',
      'assets/fonts/noto-sans-jp-regular-400.ttf',
      'assets/fonts/noto-sans-jp-medium-500.ttf',
      'assets/fonts/noto-sans-jp-semibold-600.ttf',
      'assets/fonts/noto-sans-jp-bold-700.ttf',
      'assets/fonts/noto-sans-jp-extraBold-800.ttf',
      'assets/fonts/noto-sans-jp-black-900.ttf',
    ],
    'sf_ui': [
      'assets/fonts/sf-ui-display-ultralight.otf',
      'assets/fonts/sf-ui-display-thin.otf',
      'assets/fonts/sf-ui-display-light.otf',
      'assets/fonts/sf-ui-display-regular.otf',
      'assets/fonts/sf-ui-display-medium.otf',
      'assets/fonts/sf-ui-display-semibold.otf',
      'assets/fonts/sf-ui-display-bold.otf',
      'assets/fonts/sf-ui-display-heavy.otf',
      'assets/fonts/sf-ui-display-black.otf',
    ],
  };
  for (final entry in families.entries) {
    final loader = FontLoader(entry.key);
    for (final path in entry.value) {
      loader.addFont(rootBundle.load(path));
    }
    await loader.load();
  }

  // NOTE: Icons.*（MaterialIcons）/ CupertinoIcons は、この flutter test 環境では
  // FontLoader.load() がハングするため読み込まない（goldenでは豆腐□表示になる）。
  // レイアウト・色・実フォント(noto/sf)・SVGカテゴリアイコン・余白・枠線は正確に出る。
}

/// 実機と同じ ThemeData(dark) + AppColors 拡張でウィジェットを包む。
/// [overrides] でリポジトリ/プロバイダのフェイクを注入する。
Widget wrapDark(
  Widget child, {
  List<Override> overrides = const [],
  Color bg = const Color(0xFF000000),
  EdgeInsets padding = const EdgeInsets.all(16),
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(extensions: const [AppColors.light]),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme(
          scrolledUnderElevation: 0,
          elevation: 0,
        ),
        extensions: const [AppColors.dark],
      ),
      home: Scaffold(
        backgroundColor: bg,
        body: Center(
          child: Padding(padding: padding, child: child),
        ),
      ),
    ),
  );
}
