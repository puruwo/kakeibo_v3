import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'is_small_category_list_edited.g.dart';

// 小カテゴリーを編集したかどうか（大カテゴリーごと・ページを閉じると破棄される）
@riverpod
class IsSmallCategoryListEditedNotifier
    extends _$IsSmallCategoryListEditedNotifier {
  @override
  bool build(int bigId) {
    // 最初のデータ
    return false;
  }

  void updateState(bool bool) {
    // データを上書き
    state = bool;
  }
}