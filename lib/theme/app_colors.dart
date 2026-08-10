// GENERATED CODE - DO NOT MODIFY BY HAND
// Source    : design-tokens/tokens.json
// Generator : tool/generate_tokens.dart
//
// セマンティック色トークンの ThemeExtension。
// primitive は生成時にインライン解決済み（公開フィールドには含めない）。
// あわせて const TextStyle 用の static const 色クラス AppColorsLight / AppColorsDark も出力する。
// ※ MaterialApp への接続・既存 MyColors の置き換えは別STEPで対応。

import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.primarySubtle,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceElevated2,
    required this.fill,
    required this.fillSecondary,
    required this.fillTertiary,
    required this.fillQuaternary,
    required this.fillOpaque,
    required this.text,
    required this.textSecondary,
    required this.textTertiary,
    required this.separator,
    required this.expense,
    required this.income,
    required this.danger,
    required this.icon,
    required this.disabled,
    required this.overlay,
    required this.link,
    required this.handle,
  });

  final Color primary;
  final Color onPrimary;
  final Color primarySubtle;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceElevated2;
  final Color fill;
  final Color fillSecondary;
  final Color fillTertiary;
  final Color fillQuaternary;
  final Color fillOpaque;
  final Color text;
  final Color textSecondary;
  final Color textTertiary;
  final Color separator;
  final Color expense;
  final Color income;
  final Color danger;
  final Color icon;
  final Color disabled;
  final Color overlay;
  final Color link;
  final Color handle;

  static const AppColors light = AppColors(
    primary: Color(0xFF0BB283),
    onPrimary: Color(0xFFFFFFFF),
    primarySubtle: Color(0xFFD7FFF4),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF2F2F7),
    surfaceElevated2: Color(0xFFFFFFFF),
    fill: Color(0x33787880),
    fillSecondary: Color(0x28787880),
    fillTertiary: Color(0x1E767680),
    fillQuaternary: Color(0x14747480),
    fillOpaque: Color(0xFFEFEFF0),
    text: Color(0xFF000000),
    textSecondary: Color(0x993C3C43),
    textTertiary: Color(0x4C3C3C43),
    separator: Color(0x493C3C43),
    expense: Color(0xFFFF7171),
    income: Color(0xFF21D19F),
    danger: Color(0xFFFF7171),
    icon: Color(0xFF8E8E93),
    disabled: Color(0xFFD1D1D6),
    overlay: Color(0x33000000),
    link: Color(0xFF007AFF),
    handle: Color(0xFFC7C7CC),
  );

  static const AppColors dark = AppColors(
    primary: Color(0xFF0BB283),
    onPrimary: Color(0xFFFFFFFF),
    primarySubtle: Color(0xFFD7FFF4),
    surface: Color(0xFF000000),
    surfaceElevated: Color(0xFF1C1C1E),
    surfaceElevated2: Color(0xFF2C2C2E),
    fill: Color(0x5B787880),
    fillSecondary: Color(0x51787880),
    fillTertiary: Color(0x3D767680),
    fillQuaternary: Color(0x39767680),
    fillOpaque: Color(0xFF2C2C30),
    text: Color(0xFFFFFFFF),
    textSecondary: Color(0x99EBEBF5),
    textTertiary: Color(0x4CEBEBF5),
    separator: Color(0x99545458),
    expense: Color(0xFFFF7171),
    income: Color(0xFF21D19F),
    danger: Color(0xFFFF7171),
    icon: Color(0xFF8E8E93),
    disabled: Color(0xFF3A3A3C),
    overlay: Color(0x33000000),
    link: Color(0xFF0A84FF),
    handle: Color(0xFFD9D9D9),
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primarySubtle,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceElevated2,
    Color? fill,
    Color? fillSecondary,
    Color? fillTertiary,
    Color? fillQuaternary,
    Color? fillOpaque,
    Color? text,
    Color? textSecondary,
    Color? textTertiary,
    Color? separator,
    Color? expense,
    Color? income,
    Color? danger,
    Color? icon,
    Color? disabled,
    Color? overlay,
    Color? link,
    Color? handle,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primarySubtle: primarySubtle ?? this.primarySubtle,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceElevated2: surfaceElevated2 ?? this.surfaceElevated2,
      fill: fill ?? this.fill,
      fillSecondary: fillSecondary ?? this.fillSecondary,
      fillTertiary: fillTertiary ?? this.fillTertiary,
      fillQuaternary: fillQuaternary ?? this.fillQuaternary,
      fillOpaque: fillOpaque ?? this.fillOpaque,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      separator: separator ?? this.separator,
      expense: expense ?? this.expense,
      income: income ?? this.income,
      danger: danger ?? this.danger,
      icon: icon ?? this.icon,
      disabled: disabled ?? this.disabled,
      overlay: overlay ?? this.overlay,
      link: link ?? this.link,
      handle: handle ?? this.handle,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primarySubtle: Color.lerp(primarySubtle, other.primarySubtle, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceElevated2: Color.lerp(surfaceElevated2, other.surfaceElevated2, t)!,
      fill: Color.lerp(fill, other.fill, t)!,
      fillSecondary: Color.lerp(fillSecondary, other.fillSecondary, t)!,
      fillTertiary: Color.lerp(fillTertiary, other.fillTertiary, t)!,
      fillQuaternary: Color.lerp(fillQuaternary, other.fillQuaternary, t)!,
      fillOpaque: Color.lerp(fillOpaque, other.fillOpaque, t)!,
      text: Color.lerp(text, other.text, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      income: Color.lerp(income, other.income, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      icon: Color.lerp(icon, other.icon, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      link: Color.lerp(link, other.link, t)!,
      handle: Color.lerp(handle, other.handle, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  // 移行期: 新規 ThemeData を生成する Theme 配下など、AppColors 未登録の
  // subtree でも null クラッシュしないよう、未取得時はダーク既定値へフォールバックする。
  // （当面 themeMode.dark 固定のため dark を既定とする）
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.dark;
}

/// AppColorsLight: const TextStyle 用の静的色トークン（light 実値）。
class AppColorsLight {
  AppColorsLight._();

  static const Color primary = Color(0xFF0BB283);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primarySubtle = Color(0xFFD7FFF4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF2F2F7);
  static const Color surfaceElevated2 = Color(0xFFFFFFFF);
  static const Color fill = Color(0x33787880);
  static const Color fillSecondary = Color(0x28787880);
  static const Color fillTertiary = Color(0x1E767680);
  static const Color fillQuaternary = Color(0x14747480);
  static const Color fillOpaque = Color(0xFFEFEFF0);
  static const Color text = Color(0xFF000000);
  static const Color textSecondary = Color(0x993C3C43);
  static const Color textTertiary = Color(0x4C3C3C43);
  static const Color separator = Color(0x493C3C43);
  static const Color expense = Color(0xFFFF7171);
  static const Color income = Color(0xFF21D19F);
  static const Color danger = Color(0xFFFF7171);
  static const Color icon = Color(0xFF8E8E93);
  static const Color disabled = Color(0xFFD1D1D6);
  static const Color overlay = Color(0x33000000);
  static const Color link = Color(0xFF007AFF);
  static const Color handle = Color(0xFFC7C7CC);
}

/// AppColorsDark: const TextStyle 用の静的色トークン（dark 実値）。
class AppColorsDark {
  AppColorsDark._();

  static const Color primary = Color(0xFF0BB283);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primarySubtle = Color(0xFFD7FFF4);
  static const Color surface = Color(0xFF000000);
  static const Color surfaceElevated = Color(0xFF1C1C1E);
  static const Color surfaceElevated2 = Color(0xFF2C2C2E);
  static const Color fill = Color(0x5B787880);
  static const Color fillSecondary = Color(0x51787880);
  static const Color fillTertiary = Color(0x3D767680);
  static const Color fillQuaternary = Color(0x39767680);
  static const Color fillOpaque = Color(0xFF2C2C30);
  static const Color text = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0x99EBEBF5);
  static const Color textTertiary = Color(0x4CEBEBF5);
  static const Color separator = Color(0x99545458);
  static const Color expense = Color(0xFFFF7171);
  static const Color income = Color(0xFF21D19F);
  static const Color danger = Color(0xFFFF7171);
  static const Color icon = Color(0xFF8E8E93);
  static const Color disabled = Color(0xFF3A3A3C);
  static const Color overlay = Color(0x33000000);
  static const Color link = Color(0xFF0A84FF);
  static const Color handle = Color(0xFFD9D9D9);
}
