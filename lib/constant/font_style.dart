import 'package:flutter/material.dart';

/// フォントファミリーのベース。AppTypeScale（lib/constant/styles/app_type_scale.dart）からのみ参照する
///
/// 使い分け（Vault「Kakeibo テキストスタイルルール」§5）:
/// - 数字が主役の文字列（金額・日付・件数・割合）→ sfUi
/// - 和文が主役の文字列（ラベル・見出し・文）→ notoSans
class MyFontStyle {
  MyFontStyle._();

  /// noto sans 日本語・英数併用
  static TextStyle get notoSans => const TextStyle(fontFamily: 'noto_sans');

  /// sf ui 英数のみ
  ///
  /// sf_ui に日本語グリフは無いため、混じった和文は同梱の Noto Sans JP にフォールバックさせる
  /// （端末のフォールバックフォントに依存せず、数字は SF・和文は Noto で描く）
  static TextStyle get sfUi =>
      const TextStyle(fontFamily: 'sf_ui', fontFamilyFallback: ['noto_sans']);
}
