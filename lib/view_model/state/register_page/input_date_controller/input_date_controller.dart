import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'input_date_controller.g.dart';

@riverpod
class InputDateControllerNotifier extends _$inputDateControllerNotifier {
  @override
  DateTime build() {
    return ref.read(systemDatetimeNotifierProvider);
  }

  void setData(DateTime newState) {
    state = newState;
  }
}
