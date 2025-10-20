import 'package:flutter_riverpod/flutter_riverpod.dart';

// 固定費カテゴリーアイコンの状態管理
final fixedCostCategoryIconControllerNotifierProvider =
    NotifierProvider<FixedCostCategoryIconControllerNotifier, String>(
  FixedCostCategoryIconControllerNotifier.new,
);

class FixedCostCategoryIconControllerNotifier extends Notifier<String> {
  @override
  String build() {
    return ''; // デフォルトアイコン
  }

  void updateState(String newIconPath) {
    state = newIconPath;
  }
}
