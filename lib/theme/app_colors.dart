// GENERATED CODE - DO NOT MODIFY BY HAND
// Source    : design-tokens/tokens.json
// Generator : tool/generate_tokens.dart
//
// セマンティック色トークンの ThemeExtension。
// primitive は生成時にインライン解決済み（公開フィールドには含めない）。
// アプリからは context.colors.<token> で参照する。テストの期待値には AppColors.light / dark を使う。
// （静的色クラス AppColorsLight / AppColorsDark は KP-013 で廃止）

import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.primarySubtle,
    required this.primaryTint,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceElevated2,
    required this.surfaceBorder,
    required this.surfaceBorderSubtle,
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
    required this.cardSurface,
    required this.pressedOverlay,
    required this.surfaceHighlight,
  });

  final Color primary;
  final Color onPrimary;
  final Color primarySubtle;
  final Color primaryTint;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceElevated2;
  final Color surfaceBorder;
  final Color surfaceBorderSubtle;
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
  final Color cardSurface;
  final Color pressedOverlay;
  final Color surfaceHighlight;

  static const AppColors light = AppColors(
    primary: Color(0xFF0BB283),
    onPrimary: Color(0xFFFFFFFF),
    primarySubtle: Color(0xFFD7FFF4),
    primaryTint: Color(0x290BB283),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF2F2F7),
    surfaceElevated2: Color(0xFFFFFFFF),
    surfaceBorder: Color(0x24000000),
    surfaceBorderSubtle: Color(0x14000000),
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
    income: Color(0xFF12C281),
    danger: Color(0xFFFF7171),
    icon: Color(0xFF8E8E93),
    disabled: Color(0xFFD1D1D6),
    overlay: Color(0x99FFFFFF),
    link: Color(0xFF007AFF),
    handle: Color(0xFFC7C7CC),
    cardSurface: Color(0xFFF2F2F7),
    pressedOverlay: Color(0x1A000000),
    surfaceHighlight: Color(0x00FFFFFF),
  );

  static const AppColors dark = AppColors(
    primary: Color(0xFF0BB283),
    onPrimary: Color(0xFFFFFFFF),
    primarySubtle: Color(0xFFD7FFF4),
    primaryTint: Color(0x290BB283),
    surface: Color(0xFF0A0A0D),
    surfaceElevated: Color(0xFF1C1C1E),
    surfaceElevated2: Color(0xFF2C2C2E),
    surfaceBorder: Color(0x24FFFFFF),
    surfaceBorderSubtle: Color(0x14FFFFFF),
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
    income: Color(0xFF12C281),
    danger: Color(0xFFFF7171),
    icon: Color(0xFF8E8E93),
    disabled: Color(0xFF3A3A3C),
    overlay: Color(0x33000000),
    link: Color(0xFF0A84FF),
    handle: Color(0xFFD9D9D9),
    cardSurface: Color(0x39767680),
    pressedOverlay: Color(0x1AFFFFFF),
    surfaceHighlight: Color(0x09FFFFFF),
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primarySubtle,
    Color? primaryTint,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceElevated2,
    Color? surfaceBorder,
    Color? surfaceBorderSubtle,
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
    Color? cardSurface,
    Color? pressedOverlay,
    Color? surfaceHighlight,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primarySubtle: primarySubtle ?? this.primarySubtle,
      primaryTint: primaryTint ?? this.primaryTint,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceElevated2: surfaceElevated2 ?? this.surfaceElevated2,
      surfaceBorder: surfaceBorder ?? this.surfaceBorder,
      surfaceBorderSubtle: surfaceBorderSubtle ?? this.surfaceBorderSubtle,
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
      cardSurface: cardSurface ?? this.cardSurface,
      pressedOverlay: pressedOverlay ?? this.pressedOverlay,
      surfaceHighlight: surfaceHighlight ?? this.surfaceHighlight,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primarySubtle: Color.lerp(primarySubtle, other.primarySubtle, t)!,
      primaryTint: Color.lerp(primaryTint, other.primaryTint, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceElevated2: Color.lerp(surfaceElevated2, other.surfaceElevated2, t)!,
      surfaceBorder: Color.lerp(surfaceBorder, other.surfaceBorder, t)!,
      surfaceBorderSubtle: Color.lerp(surfaceBorderSubtle, other.surfaceBorderSubtle, t)!,
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
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      pressedOverlay: Color.lerp(pressedOverlay, other.pressedOverlay, t)!,
      surfaceHighlight: Color.lerp(surfaceHighlight, other.surfaceHighlight, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  /// 現在の Theme に登録された AppColors を返す。
  ///
  /// 未登録（AppTheme を経由しない新規 ThemeData の配下）は設計上の誤りなので
  /// debug では assert で検出し、release では既定のライトへフォールバックする（KP-013）。
  AppColors get colors {
    final ext = Theme.of(this).extension<AppColors>();
    assert(ext != null, 'AppColors が Theme に未登録（AppTheme を経由していない Theme 配下）');
    return ext ?? AppColors.light;
  }
}

