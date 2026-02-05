import 'package:flutter/material.dart';

/// showModalBottomSheetの共通関数
///
/// [context] - BuildContext
/// [child] - モーダル内に表示するWidget
/// [useRootNavigator] - ルートナビゲーターを使用するか（デフォルト: true）
/// [isScrollControlled] - スクロール制御を有効にするか（デフォルト: true）
/// [useSafeArea] - SafeAreaを使用するか（デフォルト: false）
/// [maxWidth] - 最大幅（デフォルト: 2000）
/// [wrapWithMaterialApp] - MaterialAppでラップするか（デフォルト: true）
/// [enableDrag] - ドラッグで閉じるか（デフォルト: false）
/// [isDismissible] - 背景タップで閉じるか（デフォルト: false）
/// [backgroundColor] - 背景色（デフォルト: null）
/// [topRadius] - 上部の角丸半径（デフォルト: 0 = 角丸なし）
/// [transitionAnimationController] - アニメーションコントローラー（カスタムduration用）
Future<T?> showAppModalBottomSheet<T>(
  BuildContext context, {
  required Widget child,
  bool useRootNavigator = true,
  bool isScrollControlled = true,
  bool useSafeArea = false,
  double maxWidth = 2000,
  bool wrapWithMaterialApp = true,
  bool enableDrag = false,
  bool isDismissible = false,
  Color? backgroundColor,
  double topRadius = 25,
  Duration transitionDuration = const Duration(milliseconds: 325),
}) {
  // 角丸設定
  final ShapeBorder? shape = topRadius > 0
      ? RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(topRadius),
          ),
        )
      : null;

  // 表示するWidget
  Widget content;
  if (wrapWithMaterialApp) {
    content = MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: child,
    );
  } else {
    content = child;
  }

  // SafeArea対応
  if (useSafeArea) {
    content = SafeArea(top: false, child: content);
  }

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: isDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: transitionDuration,
    pageBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      Widget dialogContent = Align(
        alignment: Alignment.bottomCenter,
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.95),
            child: Material(
              color: backgroundColor ??
                  Theme.of(context).bottomSheetTheme.modalBackgroundColor ??
                  Theme.of(context).bottomSheetTheme.backgroundColor ??
                  Theme.of(context).dialogBackgroundColor,
              shape: shape,
              clipBehavior: shape != null ? Clip.antiAlias : Clip.none,
              child: content,
            ),
          ),
        ),
      );

      // ドラッグで閉じられるようにする
      if (enableDrag) {
        dialogContent = Dismissible(
          key: const Key('modal_dismissible'),
          direction: DismissDirection.down,
          onDismissed: (_) => Navigator.of(context).pop(),
          child: dialogContent,
        );
      }

      return dialogContent;
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      );
    },
    useRootNavigator: useRootNavigator,
  );
}
