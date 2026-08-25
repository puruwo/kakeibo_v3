class ScreenLayoutProperties {
  // 基準の画面幅
  final int _defaultWidth = 375;
  int get defaultWidth => _defaultWidth;
}

/// 自作グロナビ（foundation.dart の bottomNavigationBar）の高さ。
/// 下部クリアランス計算（media_query_extension.dart の bottomNavClearance）と
/// 実際のバーの高さを一致させるための単一ソース。
const double appBottomNavBarHeight = 56;

class CalendarProperties {
  // カレンダーの初期ページ
  final int _initialCalendarPage = 500;
  int get initialCalendarPage => _initialCalendarPage;
}
