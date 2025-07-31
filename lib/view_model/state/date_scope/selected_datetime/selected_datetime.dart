import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_datetime.g.dart';

@Riverpod(keepAlive: true)
class SelectedDatetimeNotifier extends _$SelectedDatetimeNotifier {
  @override
  DateTime build() {
    // 最初のデータ
    final now = DateTime.now();
    // final now = DateTime(2025,9,26);
    return DateTime(now.year, now.month, now.day);
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