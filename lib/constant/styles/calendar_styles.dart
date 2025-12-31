import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';

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
  static const TextStyle calendarDateBoxLarge = TextStyle(
    color: MyColors.white,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFamily: 'sf_ui',
  );

  /// カレンダー6行表示時の金額ラベル（小さめ）
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: calendar_area/date_box.dart (カレンダー日付セル)
  ///   - 詳細: 収入/支出金額表示（6週間表示時）
  ///   - 条件: isCompact = true の場合に使用
  static const TextStyle calendarDateBoxSmall = TextStyle(
    color: MyColors.white,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.0,
    fontFamily: 'sf_ui',
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
  static const TextStyle calendarWeekdayLabel = TextStyle(
    color: MyColors.secondaryLabel,
    fontSize: 12,
  );

  /// 日曜の曜日ラベル（赤色）
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: calendar_area/calendar_area.dart (カレンダーエリア)
  ///   - 詳細: 「日」の曜日表示
  static const TextStyle calendarWeekdaySunday = TextStyle(
    color: MyColors.red,
    fontSize: 12,
  );

  /// 土曜の曜日ラベル（青色）
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: calendar_area/calendar_area.dart (カレンダーエリア)
  ///   - 詳細: 「土」の曜日表示
  static const TextStyle calendarWeekdaySaturday = TextStyle(
    color: MyColors.blue,
    fontSize: 12,
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
  static const TextStyle calendarDateLabel = TextStyle(
    color: MyColors.secondaryLabel,
  );

  /// 日曜の日付ラベル（赤色）
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: calendar_area/date_box.dart (カレンダー日付セル)
  ///   - 詳細: 日曜日の日付表示
  ///   - 条件: isSunday = true の場合
  static const TextStyle calendarDateLabelSunday = TextStyle(
    color: MyColors.red,
  );

  /// 土曜の日付ラベル（青色）
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: calendar_area/date_box.dart (カレンダー日付セル)
  ///   - 詳細: 土曜日の日付表示
  ///   - 条件: isSaturday = true の場合
  static const TextStyle calendarDateLabelSaturday = TextStyle(
    color: MyColors.blue,
  );

  /// 期間外日付ラベル（薄い色）
  ///
  /// 【使用箇所】
  /// - ページ: expense_history_page.dart (履歴ページ)
  ///   - エリア: calendar_area/date_box.dart (カレンダー日付セル)
  ///   - 詳細: 前月・翌月の日付表示
  ///   - 使用関数: vacantDateBox()
  static const TextStyle calendarOutOfPeriodDateLabel = TextStyle(
    color: MyColors.tirtiaryLabel,
  );
}
