import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'entered_income_source_controller.g.dart';

@riverpod
class EnteredIncomeSourceControllerNotifier
    extends _$EnteredIncomeSourceControllerNotifier {
  @override
  int build() {
    return 1;
  }

  void setData(int newState) {
    state = newState;
  }
}
