import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'input_date_controller.g.dart';

@riverpod
class inputDateControllerNotifier extends _$inputDateControllerNotifier {
  @override
  DateTime build() {
    return DateTime.now();
  }

  void setData(DateTime newState) {
    state = newState;
  }
}