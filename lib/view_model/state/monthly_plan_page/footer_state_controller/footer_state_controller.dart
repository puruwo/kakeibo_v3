import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'footer_state_controller.g.dart';

enum TabState {
  budgetNormal,
  budgetEdditing,
  income,
}

//登録できるかどうか
@Riverpod(keepAlive: false)
class FooterStateControllerNotifier extends _$FooterStateControllerNotifier {
  TabState build() {
    // 最初のデータ
    return TabState.budgetNormal;
  }

  void updateState(TabState newState) {
    // データを上書き
    state = newState;
  }
}