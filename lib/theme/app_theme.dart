import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakeibo/constant/font_style.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// アプリの ThemeData の唯一の正本（KP-013）
///
/// light / dark の差はトークン（[AppColors]）の差だけにし、Material 既定色（seed 紫）に依存しない。
/// main.dart（KakeiboApp）と test/helper の pumpApp の両方からこのビルダーを使う。
/// 個別の Widget で `Theme(data: ThemeData(...))` を新規生成しない（AppColors 拡張が落ちる）。
class AppTheme {
  AppTheme._();

  /// ライトテーマ（既定）
  static ThemeData light() => buildAppTheme(AppColors.light, Brightness.light);

  /// ダークテーマ
  static ThemeData dark() => buildAppTheme(AppColors.dark, Brightness.dark);
}

/// トークン [c] と明度 [b] から ThemeData を組み立てる
ThemeData buildAppTheme(AppColors c, Brightness b) {
  final isDark = b == Brightness.dark;

  // seed から生成した ColorScheme に主要色をトークンで上書きし、
  // 拡張（context.colors）を使わない Material 部品にも既定色としてトークンが届くようにする
  final colorScheme = ColorScheme.fromSeed(seedColor: c.primary, brightness: b)
      .copyWith(
        primary: c.primary,
        onPrimary: c.onPrimary,
        surface: c.surface,
        onSurface: c.text,
        error: c.danger,
        onError: c.onPrimary,
        outline: c.surfaceBorder,
        outlineVariant: c.separator,
      );

  // ThemeData の既定フォント（役割スタイルを当てない Material 部品の文字）は和文の noto。
  // ファミリー名の正本は MyFontStyle（KP-007）なので文字列を直書きしない
  final base = ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: colorScheme,
    fontFamily: MyFontStyle.notoSans.fontFamily,
  );

  // ステータスバーの文字色。AppBar が透明でも明度で推定させず、モードで明示する
  final overlayStyle =
      (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: Colors.transparent);

  return base.copyWith(
    extensions: <ThemeExtension<dynamic>>[c],
    // 主要タブ・設定画面などの地。サブページ・モーダルは部品側で surfaceElevated を明示する
    scaffoldBackgroundColor: c.surface,
    canvasColor: c.surface,
    textTheme: base.textTheme.apply(bodyColor: c.text, displayColor: c.text),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: c.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      centerTitle: true,
      iconTheme: IconThemeData(color: c.text),
      actionsIconTheme: IconThemeData(color: c.text),
      // 役割スタイル（KP-007）の値を使う。色だけモードのトークンに差し替える
      titleTextStyle: AppTextStyles(c).pageHeaderText.copyWith(color: c.text),
      systemOverlayStyle: overlayStyle,
    ),
    dividerColor: c.separator,
    dividerTheme: DividerThemeData(
      color: c.separator,
      thickness: 0.5,
      space: 0,
    ),
    switchTheme: SwitchThemeData(
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      thumbColor: WidgetStatePropertyAll(c.onPrimary),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? c.primary : c.icon,
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      hintStyle: AppTextStyles(c).insetGroupPlaceholder.copyWith(
        color: c.textTertiary,
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: c.primary,
      selectionColor: c.primaryTint,
      selectionHandleColor: c.primary,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: c.surfaceElevated2,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.fillOpaque,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: c.surfaceElevated,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: c.surfaceElevated,
      headerForegroundColor: c.text,
      dividerColor: c.separator,
      weekdayStyle: AppTextStyles(c).listTileSecondaryTitle.copyWith(
        color: c.textSecondary,
      ),
      dayForegroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? c.onPrimary : c.text,
      ),
      dayBackgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? c.primary : null,
      ),
      todayForegroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? c.onPrimary : c.primary,
      ),
      todayBackgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? c.primary : null,
      ),
      todayBorder: BorderSide(color: c.primary),
      yearForegroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? c.onPrimary : c.text,
      ),
      yearBackgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? c.primary : null,
      ),
      confirmButtonStyle: TextButton.styleFrom(foregroundColor: c.primary),
      cancelButtonStyle: TextButton.styleFrom(foregroundColor: c.primary),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.surfaceElevated2,
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentTextStyle: AppTextStyles(c).snackBarMessage.copyWith(color: c.text),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary),
    // 押下表現はアプリ全体で「スプラッシュ無し・ハイライトのみ」（AppInkWell と同じ）
    splashColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    highlightColor: c.pressedOverlay,
    hoverColor: Colors.transparent,
    iconTheme: IconThemeData(color: c.text),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: c.text,
        overlayColor: Colors.transparent,
      ),
    ),
    // 文字の段は指定しない（日付ピッカー等の Material 部品のボタンまで 12px に縮むため）。
    // アプリ内のテキストボタンは呼び出し側で役割スタイル textButtonTextStyle を当てる
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.primary,
        overlayColor: Colors.transparent,
      ),
    ),
    tabBarTheme: TabBarThemeData(
      indicatorColor: c.primary,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      labelColor: c.primary,
      unselectedLabelColor: c.textSecondary,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    cupertinoOverrideTheme: CupertinoThemeData(
      primaryColor: c.primary,
      brightness: b,
    ),
  );
}
