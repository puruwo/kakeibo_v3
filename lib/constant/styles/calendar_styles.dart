import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_type_scale.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// ============================================================================
/// 履歴カレンダー専用の役割スタイル
/// 値は AppTypeScale の段を参照する。新しいスタイルは AppTextStyles に置く（画面専用クラスは新設しない）
/// ============================================================================
class CalendarStyles {
  /// [colors] は現在のテーマの色トークン。通常は `context.calendarStyles` 経由で受け取る
  const CalendarStyles(this.colors);

  /// 役割スタイルの色の出どころ（ライト／ダークで値が変わる）
  final AppColors colors;

  /// context 無しに使う固定インスタンス（テストの期待値・Painter への注入元）
  static const CalendarStyles light = CalendarStyles(AppColors.light);
  static const CalendarStyles dark = CalendarStyles(AppColors.dark);

  // ==========================================================================
  // カレンダーセル内の金額表示
  // ==========================================================================

  /// 5週表示時のセル金額（既存の例外値 11.5px）
  TextStyle get calendarDateBoxLarge =>
      AppTypeScale.sfUi11_5w500.copyWith(color: colors.text);

  /// 6週表示時のセル金額（行高を詰めてセルに収める）
  TextStyle get calendarDateBoxSmall =>
      AppTypeScale.sfUi11w500.copyWith(color: colors.text, height: 1.0);

  // ==========================================================================
  // カレンダーヘッダー（曜日表示）
  // ==========================================================================

  /// 曜日ラベル（月〜金）
  TextStyle get calendarWeekdayLabel =>
      AppTypeScale.noto12w500.copyWith(color: colors.textSecondary);

  /// 日曜の曜日ラベル（支出色）
  TextStyle get calendarWeekdaySunday =>
      AppTypeScale.noto12w500.copyWith(color: colors.expense);

  /// 土曜の曜日ラベル（収入色）
  TextStyle get calendarWeekdaySaturday =>
      AppTypeScale.noto12w500.copyWith(color: colors.income);

  // ==========================================================================
  // カレンダー日付セル内の日付表示
  // ==========================================================================

  /// 日付ラベル（平日）
  TextStyle get calendarDateLabel =>
      AppTypeScale.sfUi12w500.copyWith(color: colors.textSecondary);

  /// 日曜の日付ラベル（支出色）
  TextStyle get calendarDateLabelSunday =>
      AppTypeScale.sfUi12w500.copyWith(color: colors.expense);

  /// 土曜の日付ラベル（収入色）
  TextStyle get calendarDateLabelSaturday =>
      AppTypeScale.sfUi12w500.copyWith(color: colors.income);

  /// 期間外（前月・翌月）の日付ラベル
  TextStyle get calendarOutOfPeriodDateLabel =>
      AppTypeScale.sfUi12w500.copyWith(color: colors.textTertiary);
}

/// BuildContext から現在のテーマの履歴カレンダー専用の役割スタイルを取る（KP-013）
extension CalendarStylesX on BuildContext {
  CalendarStyles get calendarStyles => CalendarStyles(colors);
}
