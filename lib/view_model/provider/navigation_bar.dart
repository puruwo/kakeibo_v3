import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'navigation_bar.g.dart';

//navigationBarでどの画面を開いているかの状態管理

@riverpod
class NavigationBarNotifier extends _$NavigationBarNotifier {
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
