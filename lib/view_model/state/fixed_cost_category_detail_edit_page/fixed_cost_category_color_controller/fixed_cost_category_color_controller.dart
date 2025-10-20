import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 固定費カテゴリーカラーの状態管理
final fixedCostCategoryColorControllerNotifierProvider =
    NotifierProvider<FixedCostCategoryColorControllerNotifier, Color>(
  FixedCostCategoryColorControllerNotifier.new,
);

class FixedCostCategoryColorControllerNotifier extends Notifier<Color> {
  @override
  Color build() {
    return const Color(0xFFFF5722); // デフォルトカラー（Deep Orange）
  }

  void updateState(Color newColor) {
    state = newColor;
  }
}
