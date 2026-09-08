import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'is_income_small_category_list_edited.g.dart';

// 収入小カテゴリーを編集したかどうか（大カテゴリーごと・ページを閉じると破棄される）
@riverpod
class IsIncomeSmallCategoryListEditedNotifier
    extends _$IsIncomeSmallCategoryListEditedNotifier {
  @override
  bool build(int bigId) {
    return false;
  }

  void updateState(bool value) {
    state = value;
  }
}
