import 'package:flutter/material.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/constant/font_style.dart';

/// ============================================================================
/// カレンダーウィジェットで使用するTextStyleを定義
/// ============================================================================
class CalendarStyles {
  // ==========================================================================
  // カレンダーセル内の金額表示
  // ==========================================================================

  /// カレンダー5行表示時の金額ラベル（大きめ）
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: calendar_area/date_box.dart (カレンダー日付セル)
  ///   - 詳細: 収入/支出金額表示（5週間表示時）
  ///   - 条件: isCompact = false の場合に使用
  static final TextStyle calendarDateBoxLarge = MyFontStyle.sfUi.copyWith(
    fontSize: 11.5,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w500,
  );

  /// カレンダー6行表示時の金額ラベル（小さめ）
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: calendar_area/date_box.dart (カレンダー日付セル)
  ///   - 詳細: 収入/支出金額表示（6週間表示時）
  ///   - 条件: isCompact = true の場合に使用
  static final TextStyle calendarDateBoxSmall = MyFontStyle.sfUi.copyWith(
    fontSize: 11,
    color: AppColorsDark.text,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );

  // ==========================================================================
  // カレンダーヘッダー（曜日表示）
  // ==========================================================================

  /// 曜日ラベル（月〜金）
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: calendar_area/calendar_area.dart (カレンダーエリア)
  ///   - 詳細: 「月」「火」「水」「木」「金」の曜日表示
  static final TextStyle calendarWeekdayLabel = MyFontStyle.notoSans.copyWith(
    fontSize: 12,
    color: AppColorsDark.textSecondary,
    fontWeight: FontWeight.w500,
  );

  // TextStyle(
  //   color: AppColorsDark.textSecondary,
  //   fontSize: 12,
  // );

  /// 日曜の曜日ラベル（赤色）
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: calendar_area/calendar_area.dart (カレンダーエリア)
  ///   - 詳細: 「日」の曜日表示
  static final TextStyle calendarWeekdaySunday = MyFontStyle.notoSans.copyWith(
    fontSize: 12,
    color: AppColorsDark.expense,
    fontWeight: FontWeight.w500,
  );

  /// 土曜の曜日ラベル（青色）
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: calendar_area/calendar_area.dart (カレンダーエリア)
  ///   - 詳細: 「土」の曜日表示
  static final TextStyle calendarWeekdaySaturday = MyFontStyle.notoSans
      .copyWith(
        fontSize: 12,
        color: AppColorsDark.income,
        fontWeight: FontWeight.w500,
      );

  // ==========================================================================
  // カレンダー日付セル内の日付表示
  // ==========================================================================

  /// 日付ラベル（平日）
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: calendar_area/date_box.dart (カレンダー日付セル)
  ///   - 詳細: 「1」「2」...「31」などの日付表示（月〜金）
  ///   - 使用関数: activeDateBox(), normalDateBox()
  static final TextStyle calendarDateLabel = MyFontStyle.sfUi.copyWith(
    fontSize: 12,
    color: AppColorsDark.textSecondary,
    fontWeight: FontWeight.w500,
  );

  /// 日曜の日付ラベル（赤色）
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: calendar_area/date_box.dart (カレンダー日付セル)
  ///   - 詳細: 日曜日の日付表示
  ///   - 条件: isSunday = true の場合
  static final TextStyle calendarDateLabelSunday = MyFontStyle.sfUi.copyWith(
    fontSize: 12,
    color: AppColorsDark.expense,
    fontWeight: FontWeight.w500,
  );

  /// 土曜の日付ラベル（青色）
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: calendar_area/date_box.dart (カレンダー日付セル)
  ///   - 詳細: 土曜日の日付表示
  ///   - 条件: isSaturday = true の場合
  static final TextStyle calendarDateLabelSaturday = MyFontStyle.sfUi.copyWith(
    fontSize: 12,
    color: AppColorsDark.income,
    fontWeight: FontWeight.w500,
  );

  /// 期間外日付ラベル（薄い色）
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: calendar_area/date_box.dart (カレンダー日付セル)
  ///   - 詳細: 前月・翌月の日付表示
  ///   - 使用関数: vacantDateBox()
  static final TextStyle calendarOutOfPeriodDateLabel = MyFontStyle.sfUi
      .copyWith(
        fontSize: 12,
        color: AppColorsDark.textTertiary,
        fontWeight: FontWeight.w500,
      );
}
