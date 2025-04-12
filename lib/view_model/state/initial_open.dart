import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'initial_open.g.dart';

// アプリを開いた時かどうか（状態を保持する）
@Riverpod(keepAlive: true)
class InitialOpenNotifier extends _$InitialOpenNotifier {
  @override
  bool build() {
    // 最初のデータ
    return true;
  }

  void updateState() {
    // データを上書き
    state = false;
  }
}