import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'is_small_category_list_edited.g.dart';

//編集したかどうか
@Riverpod(keepAlive: false)
class IsSmallCategoryListEditedNotifier extends _$IsSmallCategoryListEditedNotifier {
  bool build() {
    // 最初のデータ
    return false;
  }

  void updateState(bool bool) {
    // データを上書き
    state = bool;
  }
}