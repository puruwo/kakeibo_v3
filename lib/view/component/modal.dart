import 'package:flutter/material.dart';

const animationDuration = Duration(milliseconds: 300);

/// showModalBottomSheetの共通関数
///
/// [context] - BuildContext
/// [child] - モーダル内に表示するWidget
/// [useRootNavigator] - ルートナビゲーターを使用するか（デフォルト: true）
/// [isScrollControlled] - スクロール制御を有効にするか（デフォルト: true）
/// [useSafeArea] - SafeAreaを使用するか（デフォルト: true）
/// [maxWidth] - 最大幅（デフォルト: 2000）
/// [wrapWithMaterialApp] - MaterialAppでラップするか（デフォルト: true）
/// [enableDrag] - ドラッグで閉じるか（デフォルト: true）
/// [isDismissible] - 背景タップで閉じるか（デフォルト: false）
/// [backgroundColor] - 背景色（デフォルト: null）
/// [topRadius] - 上部の角丸半径（デフォルト: 0 = 角丸なし）
/// [transitionAnimationController] - アニメーションコントローラー（カスタムduration用）
Future<T?> showAppModalBottomSheet<T>(
  BuildContext context, {
  required Widget child,
  bool useRootNavigator = true,
  bool isScrollControlled = true,
  bool useSafeArea = true,
  double maxWidth = 2000,
  bool wrapWithMaterialApp = true,
  bool enableDrag = true,
  bool isDismissible = false,
  Color? backgroundColor,
  double topRadius = 0,
  AnimationController? transitionAnimationController,
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

  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    enableDrag: enableDrag,
    isDismissible: isDismissible,
    backgroundColor: backgroundColor,
    shape: shape,
    constraints: BoxConstraints(maxWidth: maxWidth),
    transitionAnimationController: transitionAnimationController,
    builder: (context) => content,
  );
}

/// アニメーションコントローラーを作成するヘルパー関数
///
/// [vsync] - TickerProvider（State with SingleTickerProviderStateMixinなど）
/// [duration] - アニメーションの長さ（デフォルト: 300ms）
AnimationController createModalAnimationController({
  required TickerProvider vsync,
  Duration duration = const Duration(milliseconds: 300),
}) {
  return AnimationController(
    vsync: vsync,
    duration: duration,
  );
}

/// 後方互換性のための旧関数（非推奨）
@Deprecated('Use showAppModalBottomSheet instead')
Future<void> showModalBottomSheetFunc(BuildContext context, Widget page) async {
  showAppModalBottomSheet(
    context,
    child: page,
    wrapWithMaterialApp: false,
  );
}
