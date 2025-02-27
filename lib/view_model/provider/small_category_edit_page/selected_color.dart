import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_color.g.dart';


@riverpod
class SelectedColorNotifier extends _$SelectedColorNotifier {
  @override
  Color build() {
    // 最初のデータ
    const selelctedColor = Colors.transparent;
    return selelctedColor;
  }

  void updateState(Color newSelectedColor) {
    // データを上書き
    state = newSelectedColor;
  } 
}
