import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_type_scale.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// ============================================================================
/// 履歴カレンダー専用の役割スタイル
/// 値は AppTypeScale の段を参照する。新しいスタイルは AppTextStyles に置く（画面専用クラスは新設しない）
/// ============================================================================
class CalendarStyles {
  CalendarStyles._();

  // ==========================================================================
  // カレンダーセル内の金額表示
  // ==========================================================================

  /// 5週表示時のセル金額（既存の例外値 11.5px）
  static final TextStyle calendarDateBoxLarge = AppTypeScale.sfUi11_5w500
      .copyWith(color: AppColorsDark.text);

  /// 6週表示時のセル金額（行高を詰めてセルに収める）
  static final TextStyle calendarDateBoxSmall = AppTypeScale.sfUi11w500
      .copyWith(color: AppColorsDark.text, height: 1.0);

  // ==========================================================================
  // カレンダーヘッダー（曜日表示）
  // ==========================================================================

  /// 曜日ラベル（月〜金）
  static final TextStyle calendarWeekdayLabel = AppTypeScale.noto12w500
      .copyWith(color: AppColorsDark.textSecondary);

  /// 日曜の曜日ラベル（支出色）
  static final TextStyle calendarWeekdaySunday = AppTypeScale.noto12w500
      .copyWith(color: AppColorsDark.expense);

  /// 土曜の曜日ラベル（収入色）
  static final TextStyle calendarWeekdaySaturday = AppTypeScale.noto12w500
      .copyWith(color: AppColorsDark.income);

  // ==========================================================================
  // カレンダー日付セル内の日付表示
  // ==========================================================================

  /// 日付ラベル（平日）
  static final TextStyle calendarDateLabel = AppTypeScale.sfUi12w500.copyWith(
    color: AppColorsDark.textSecondary,
  );

  /// 日曜の日付ラベル（支出色）
  static final TextStyle calendarDateLabelSunday = AppTypeScale.sfUi12w500
      .copyWith(color: AppColorsDark.expense);

  /// 土曜の日付ラベル（収入色）
  static final TextStyle calendarDateLabelSaturday = AppTypeScale.sfUi12w500
      .copyWith(color: AppColorsDark.income);

  /// 期間外（前月・翌月）の日付ラベル
  static final TextStyle calendarOutOfPeriodDateLabel = AppTypeScale.sfUi12w500
      .copyWith(color: AppColorsDark.textTertiary);
}
