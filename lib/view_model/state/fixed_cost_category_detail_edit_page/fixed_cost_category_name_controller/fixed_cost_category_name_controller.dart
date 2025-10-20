import 'package:flutter_riverpod/flutter_riverpod.dart';

// 固定費カテゴリー名の状態管理
final fixedCostCategoryNameControllerNotifierProvider =
    NotifierProvider<FixedCostCategoryNameControllerNotifier, String>(
  FixedCostCategoryNameControllerNotifier.new,
);

class FixedCostCategoryNameControllerNotifier extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  void updateState(String newName) {
    state = newName;
  }
}
