import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'input_mode_controller.g.dart';

// 入力画面のモードを管理する
@Riverpod(keepAlive: false)
class InputModeController extends _$InputModeController {
  @override
  TransactionMode build() {
    // 最初のデータ
    return TransactionMode.expense;
  }

  void initialize(TransactionMode? mode) {
    mode ??= TransactionMode.expense;
    state = mode;
  }

  void updateState(TransactionMode mode) {
    // データを上書き
    state = mode;
  }
}
