import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'register_screen_mode.g.dart';

enum RegisterScreenMode {
  add,
  edit,
}

@riverpod
class RegisterScreenModeNotifier extends _$RegisterScreenModeNotifier {
  @override
  RegisterScreenMode build() {
    return RegisterScreenMode.add;
  }

  void setData(RegisterScreenMode newState) {
    state = newState;
  }
}