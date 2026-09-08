import 'package:kakeibo/domain/ui_value/edit_income_small_category_list_value/edit_income_small_category_value.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'editting_income_small_category_list.g.dart';

// 大カテゴリー詳細編集ページの編集中収入小カテゴリーリスト
//
// 大カテゴリーごとに別の状態を持ち（family）、ページを閉じると破棄される（autoDispose）。
// 新規カテゴリー追加のときは bigId に -1 を渡す
@riverpod
class EdittingIncomeSmallCategoryListNotifier
    extends _$EdittingIncomeSmallCategoryListNotifier {
  @override
  List<EditIncomeSmallCategoryValue> build(int bigId) {
    return [];
  }

  void setData(List<EditIncomeSmallCategoryValue> initialData) {
    state = initialData;
  }

  // 並べ替え発生時の処理
  void reorder(int oldIndex, int newIndex) {
    final updatedList = [...state];
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, item);

    int i = 0;
    for (var value in updatedList) {
      updatedList[i] = value.copyWith(editedStateDisplayOrder: i);
      i++;
    }

    state = updatedList;
  }

  // 表示チェックボックスの操作
  void toggleDisplay(int order) {
    final oldState = state[order].etitedStateIsChecked;
    state[order] = state[order].copyWith(etitedStateIsChecked: !oldState);
  }

  // 小カテゴリーを追加
  void addSmallCategory(EditIncomeSmallCategoryValue value) {
    state = [...state, value];
  }

  // 小カテゴリーの名前を更新する
  void updateName(int index, String name) {
    state[index] = state[index].copyWith(name: name);
  }
}
