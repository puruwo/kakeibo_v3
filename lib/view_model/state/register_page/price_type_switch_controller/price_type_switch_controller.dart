import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'price_type_switch_controller.g.dart';

@riverpod
class PriceTypeSwitchControllerNotifier extends _$PriceTypeSwitchControllerNotifier {
  @override
  bool build() {
    return false;
  }

  void setData(bool newState) {
    state = newState;
  }
}