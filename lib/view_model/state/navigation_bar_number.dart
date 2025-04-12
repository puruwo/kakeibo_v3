import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'navigation_bar_number.g.dart';

//navigationBarでどの画面を開いているかの状態管理
// 1: Home, 2: Third

@Riverpod(keepAlive: true)
class NavigationBarNumberNotifier extends _$NavigationBarNumberNotifier {
  @override
  int build() {
    // 最初のデータ
    return 0;
  }

  void updateState(int num) {
    // データを上書き
    state = num;
  }
}
