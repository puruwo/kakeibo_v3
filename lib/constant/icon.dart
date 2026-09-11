import 'package:flutter/material.dart';
import 'package:kakeibo/theme/app_colors.dart';

class MyIcon {
  MyIcon._();

  /// 行末の「次へ」シェブロン（一覧カード・カテゴリータイルの右端）
  ///
  /// 色は現在のテーマの `textTertiary`（AppInsetRow の右矢印と同じ。KP-013）
  static Icon next(BuildContext context) => Icon(
    Icons.arrow_forward_ios_rounded,
    color: context.colors.textTertiary,
    size: 15,
  );
}
