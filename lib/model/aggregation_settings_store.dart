import 'package:shared_preferences/shared_preferences.dart';

/// 集計期間設定の保存ストア
///
/// 集計開始日・開始月と、代表月/代表年の基準をSharedPreferencesに保持する。
/// 値が未保存の場合は既定値（毎月25日はじまり・4月はじまり・開始日側基準）を返す。
class AggregationSettingsStore {
  /// 集計開始日の既定値
  static const int defaultStartDay = 25;

  /// 集計開始月の既定値
  static const int defaultStartMonth = 4;

  /// 基準値の保存形式（集計期間の開始日側）
  static const String basisStart = 'start';

  /// 基準値の保存形式（集計期間の終了日側）
  static const String basisEnd = 'end';

  static const _startDayKey = 'aggregation_start_day';
  static const _startMonthKey = 'aggregation_start_month';
  static const _monthBasisKey = 'aggregation_month_basis';
  static const _yearBasisKey = 'aggregation_year_basis';

  /// 集計開始日を取得する
  Future<int> fetchStartDay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_startDayKey) ?? defaultStartDay;
  }

  /// 集計開始月を取得する
  Future<int> fetchStartMonth() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_startMonthKey) ?? defaultStartMonth;
  }

  /// 集計開始日を保存する
  Future<void> saveStartDay(int day) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_startDayKey, day);
  }

  /// 集計開始月を保存する
  Future<void> saveStartMonth(int month) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_startMonthKey, month);
  }

  /// 代表月の基準を取得する（現状は変更UIを持たない内部設定）
  Future<String> fetchMonthBasis() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_monthBasisKey) ?? basisStart;
  }

  /// 代表年の基準を取得する（現状は変更UIを持たない内部設定）
  Future<String> fetchYearBasis() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_yearBasisKey) ?? basisStart;
  }
}
