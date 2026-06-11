import 'package:flutter/material.dart';
import 'package:kakeibo/theme/category_palette.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_income_big_category_appearance_edited/is_income_big_category_appearance_edited.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'income_big_category_color_controller.g.dart';

@riverpod
class IncomeBigCategoryColorControllerNotifier
    extends _$IncomeBigCategoryColorControllerNotifier {
  @override
  Color build() {
    return CategoryPalette.income2;
  }

  void initState(Color color) {
    state = color;
  }

  void updateState(Color color) {
    state = color;

    ref
        .read(isIncomeBigCategoryAppearanceEditedNotifierProvider.notifier)
        .updateState(true);
  }
}
