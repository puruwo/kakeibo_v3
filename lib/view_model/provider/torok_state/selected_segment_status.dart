import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'selected_segment_status.g.dart';

enum SelectedEnum { sisyt, syunyu }

@riverpod
class SelectedSegmentStatusNotifier extends _$SelectedSegmentStatusNotifier {
  @override
  SelectedEnum build() {
    // 最初のデータ
    return SelectedEnum.sisyt;
  }

  void updateState(SelectedEnum key) {
    // データを上書き
    state = key;
  }
}