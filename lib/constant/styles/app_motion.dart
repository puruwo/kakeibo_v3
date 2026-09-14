import 'package:flutter/animation.dart';

/// ============================================================================
/// アニメーションの時間と曲線（KP-025）
///
/// 画面の切り替え（グロナビのタブ切替・期間移動によるヘッダーと本文の入れ替え）は
/// すべてこの値で揃える。個別の画面で Duration を直書きしない。
/// ============================================================================
class AppMotion {
  AppMotion._();

  /// 画面の切り替えにかける時間（グロナビのタブ切替のフェードと同じ）
  static const Duration switchDuration = Duration(milliseconds: 200);

  /// 切り替えで現れる側の曲線（グロナビのタブ切替のフェードと同じ）
  static const Curve switchInCurve = Curves.easeIn;
}
