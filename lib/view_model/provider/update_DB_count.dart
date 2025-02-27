import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'update_DB_count.g.dart';

//アプリを開いてからDB更新された回数

@riverpod
class UpdateDBCountNotifier extends _$UpdateDBCountNotifier {
  @override
  int build() {
    // 最初のデータ
    return 0;
  }

  void incrementState() {
    // データを上書き
    state++;
  }
}
