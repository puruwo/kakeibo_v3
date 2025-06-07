import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_big_category_appearance_edited/is_big_category_appearance_edited.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'big_category_color_contoroller.g.dart';

//登録できるかどうか

@riverpod
class BigCategroyColorControllerNotifier
    extends _$BigCategroyColorControllerNotifier {
  @override
  Color build() {
    // 最初のデータ
    return MyColors.transparent;
  }

  // 初回設定時に利用する
  // 編集フラグは立てないため、初回ビルド時に値を設定するときのみの使用
  void initState(Color color) {
    // データを上書き
    state = color;
  }

  void updateState(Color color) {
    // データを上書き
    state = color;

    // 大カテゴリーの見た目が編集されたことを通知
    ref
        .read(isBigCategoryAppearanceEditedNotifierProvider.notifier)
        .updateState(true);
  }
}
