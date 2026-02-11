import 'package:flutter/material.dart';

/// showModalBottomSheetの共通関数
///
/// [context] - BuildContext
/// [child] - モーダル内に表示するWidget
/// [useRootNavigator] - ルートナビゲーターを使用するか（デフォルト: true）
/// [useSafeArea] - SafeAreaを使用するか（デフォルト: false）
Future<T?> showAppModalBottomSheet<T>(
  BuildContext context, {
  required Widget child,
  bool useRootNavigator = true,
  bool useSafeArea = false,
}) {
  // SafeArea対応
  Widget content = child;
  if (useSafeArea) {
    content = SafeArea(top: false, child: content);
  }

  return Navigator.of(context, rootNavigator: useRootNavigator).push(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => content,
      transitionsBuilder: (_, animation, __, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: Offset.zero)
              .animate(curved),
          child: child,
        );
      },
    ),
  );
}
