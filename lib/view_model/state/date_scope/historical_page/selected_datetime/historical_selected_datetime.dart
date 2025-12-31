import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/util/extension/datetime_extension.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'historical_selected_datetime.g.dart';

@Riverpod(keepAlive: true)
class HistoricalSelectedDatetimeNotifier
    extends _$HistoricalSelectedDatetimeNotifier {
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
    state = state.addMonths(1);
  }

  void updateToPreviousMonth() {
    state = state.addMonths(-1);
  }
}
