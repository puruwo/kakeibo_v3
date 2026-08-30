import 'package:flutter/material.dart';
import 'package:kakeibo/constant/font_style.dart';

/// ============================================================================
/// 型スケール（family × size × weight の段）。テキストスタイルの「値の正本」
///
/// 3層構造（Vault「Kakeibo テキストスタイルルール」§3）:
///   MyFontStyle（family）→ AppTypeScale（この段）→ 役割スタイル（AppTextStyles 等）→ 呼び出し側
///
/// - 役割スタイル（AppTextStyles / RegisterPageStyles / CalendarStyles / GraphTextStyles）の
///   定義からのみ参照する。呼び出し側（lib/view 等）で直接使わない
/// - 色・height はここに持たせない（役割スタイル側で付ける）
/// - 段の命名は noto{size}w{weight} / sfUi{size}w{weight}。FontWeight.bold は使わず w700 と書く
/// - 段の追加は「必要な組み合わせが本当に無いとき」だけ。追加したら Vault の段表を更新する
/// ============================================================================
class AppTypeScale {
  AppTypeScale._();

  // ==========================================================================
  // noto_sans（和文が主役の文字列）
  // ==========================================================================
  static final TextStyle noto22w600 = _noto(22, FontWeight.w600);
  static final TextStyle noto18w500 = _noto(18, FontWeight.w500);
  static final TextStyle noto16w600 = _noto(16, FontWeight.w600);
  static final TextStyle noto16w500 = _noto(16, FontWeight.w500);
  static final TextStyle noto16w400 = _noto(16, FontWeight.w400);
  static final TextStyle noto15w600 = _noto(15, FontWeight.w600);
  static final TextStyle noto15w500 = _noto(15, FontWeight.w500);
  static final TextStyle noto14w700 = _noto(14, FontWeight.w700);
  static final TextStyle noto14w600 = _noto(14, FontWeight.w600);
  static final TextStyle noto14w500 = _noto(14, FontWeight.w500);
  static final TextStyle noto14w400 = _noto(14, FontWeight.w400);
  static final TextStyle noto14w300 = _noto(14, FontWeight.w300);
  static final TextStyle noto13w500 = _noto(13, FontWeight.w500);
  static final TextStyle noto13w400 = _noto(13, FontWeight.w400);
  static final TextStyle noto13w300 = _noto(13, FontWeight.w300);
  static final TextStyle noto12w500 = _noto(12, FontWeight.w500);
  static final TextStyle noto11w600 = _noto(11, FontWeight.w600);
  static final TextStyle noto11w500 = _noto(11, FontWeight.w500);
  static final TextStyle noto11w400 = _noto(11, FontWeight.w400);
  static final TextStyle noto11w300 = _noto(11, FontWeight.w300);
  static final TextStyle noto10w500 = _noto(10, FontWeight.w500);
  static final TextStyle noto10w400 = _noto(10, FontWeight.w400);

  // ==========================================================================
  // sf_ui（数字が主役の文字列）
  // ==========================================================================
  static final TextStyle sfUi42w700 = _sfUi(42, FontWeight.w700);
  static final TextStyle sfUi40w700 = _sfUi(40, FontWeight.w700);
  static final TextStyle sfUi32w700 = _sfUi(32, FontWeight.w700);
  static final TextStyle sfUi32w600 = _sfUi(32, FontWeight.w600);
  static final TextStyle sfUi28w700 = _sfUi(28, FontWeight.w700);
  static final TextStyle sfUi22w700 = _sfUi(22, FontWeight.w700);
  static final TextStyle sfUi20w700 = _sfUi(20, FontWeight.w700);
  static final TextStyle sfUi19w500 = _sfUi(19, FontWeight.w500);
  static final TextStyle sfUi18w500 = _sfUi(18, FontWeight.w500);
  static final TextStyle sfUi17w600 = _sfUi(17, FontWeight.w600);
  static final TextStyle sfUi16w600 = _sfUi(16, FontWeight.w600);
  static final TextStyle sfUi16w500 = _sfUi(16, FontWeight.w500);
  static final TextStyle sfUi15w500 = _sfUi(15, FontWeight.w500);
  static final TextStyle sfUi15w400 = _sfUi(15, FontWeight.w400);
  static final TextStyle sfUi14w700 = _sfUi(14, FontWeight.w700);
  static final TextStyle sfUi14w600 = _sfUi(14, FontWeight.w600);
  static final TextStyle sfUi14w500 = _sfUi(14, FontWeight.w500);
  static final TextStyle sfUi13w600 = _sfUi(13, FontWeight.w600);
  static final TextStyle sfUi13w500 = _sfUi(13, FontWeight.w500);
  static final TextStyle sfUi12w700 = _sfUi(12, FontWeight.w700);
  static final TextStyle sfUi12w500 = _sfUi(12, FontWeight.w500);

  /// カレンダーの5週表示のセル金額専用（既存の例外値。新規に参照しない）
  static final TextStyle sfUi11_5w500 = _sfUi(11.5, FontWeight.w500);
  static final TextStyle sfUi11w500 = _sfUi(11, FontWeight.w500);

  static TextStyle _noto(double size, FontWeight weight) =>
      MyFontStyle.notoSans.copyWith(fontSize: size, fontWeight: weight);

  static TextStyle _sfUi(double size, FontWeight weight) =>
      MyFontStyle.sfUi.copyWith(fontSize: size, fontWeight: weight);
}
