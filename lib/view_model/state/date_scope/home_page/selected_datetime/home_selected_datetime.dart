import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_selected_datetime.g.dart';

@Riverpod(keepAlive: true)
class HomeSelectedDatetimeNotifier extends _$HomeSelectedDatetimeNotifier {
  @override
  DateTime build() {
    // 最初のデータ
    final now = ref.read(systemDatetimeNotifierProvider);
    return now;
  }

  void updateState(DateTime dateTime) {
    // データを上書き
    state = dateTime;
  }

  void updateToNextMonth() {
    final newDt = DateTime(state.year, state.month + 1, state.day);
    state = newDt;
  }

  void updateToPreviousMonth() {
    final newDt = DateTime(state.year, state.month - 1, state.day);
    state = newDt;
  }
}