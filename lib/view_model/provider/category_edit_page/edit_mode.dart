import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_mode.g.dart';


@riverpod
class EditModeNotifier extends _$EditModeNotifier {
  @override
  bool build() {
    // 最初のデータ
    const now = false;
    return now;
  }

  void updateState() {
    // データを上書き
    state = !state;
  }  
}