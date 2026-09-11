import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/theme/app_theme.dart';
import 'package:kakeibo/view/foundation.dart';
import 'package:kakeibo/view_model/state/theme_mode.dart';

/// アプリのルート Widget（KP-013）
///
/// テーマモード（ライト／ダーク）は [themeModeNotifierProvider] を watch して MaterialApp に渡す。
/// ThemeData の正本は [AppTheme]。
class KakeiboApp extends ConsumerWidget {
  const KakeiboApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider);

    return MaterialApp(
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        // AppBar を持たない画面でもステータスバーの文字色をモードに追従させる
        final overlayStyle =
            Theme.of(context).appBarTheme.systemOverlayStyle ??
            SystemUiOverlayStyle.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: MediaQuery(
            // OS の文字拡大・太字設定は無効化する（レイアウト崩れ防止を優先）
            data: mediaQuery.copyWith(
              textScaler: const TextScaler.linear(1.0),
              boldText: false,
            ),
            child: child!,
          ),
        );
      },
      home: const Foundation(),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
    );
  }
}
