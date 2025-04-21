import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'is_registerable.g.dart';

//登録できるかどうか

@riverpod
class IsRegisterableNotifier extends _$IsRegisterableNotifier {
  @override
  bool build() {
    // 最初のデータ
    return false;
  }

  void updateState(bool bool) {
    // データを上書き
    state = bool;
  }
}