import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'when_open.g.dart';

//登録できるかどうか

@riverpod
class WhenOpenNotifier extends _$WhenOpenNotifier {
  @override
  bool build() {
    // 最初のデータ
    return true;
  }

  void updateToOpenedState() {
    // データを上書き
    state = false;
  }
}