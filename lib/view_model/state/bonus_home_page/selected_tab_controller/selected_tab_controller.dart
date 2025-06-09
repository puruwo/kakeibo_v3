import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'selected_tab_controller.g.dart';

enum SelectedTab {
  bonusExpense,
  bonusIncome,
}

//登録できるかどうか
@Riverpod(keepAlive: false)
class SelectedTabControllerNotifier extends _$SelectedTabControllerNotifier {
  SelectedTab build() {
    // 最初のデータ
    return SelectedTab.bonusExpense;
  }

  void updateState(SelectedTab newState) {
    // データを上書き
    state = newState;
  }
}