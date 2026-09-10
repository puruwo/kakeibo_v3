import 'package:kakeibo/domain/ui_value/edit_income_small_category_list_value/edit_income_small_category_value.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'editting_income_small_category_list.g.dart';

// 大カテゴリー詳細編集ページの編集中収入小カテゴリーリスト
//
// 大カテゴリーごとに別の状態を持ち（family）、ページを閉じると破棄される（autoDispose）。
// 新規カテゴリー追加のときは bigId に -1 を渡す
//
// 支出側（EdittingSmallCategoryListNotifier）と同じ2つの不変条件を保つ:
//   1. editedStateDisplayOrder は並びどおりの 0..n-1（歯抜けを作らない）
//   2. まだDBに無い項目の id は負の一意な値（-1, -2, ...）
@riverpod
class EdittingIncomeSmallCategoryListNotifier
    extends _$EdittingIncomeSmallCategoryListNotifier {
  @override
  List<EditIncomeSmallCategoryValue> build(int bigId) {
    return [];
  }

  void setData(List<EditIncomeSmallCategoryValue> initialData) {
    state = _withNormalizedOrder(initialData);
  }

  // 並べ替え発生時の処理
  void reorder(int oldIndex, int newIndex) {
    final updatedList = [...state];
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, item);

    state = _withNormalizedOrder(updatedList);
  }

  // 表示チェックボックスの操作
  void toggleDisplay(int order) {
    // 旧状態を取得
    final oldState = state[order].etitedStateIsChecked;
    // 状態を反転させ更新（listを差し替えて購読者へ通知する）
    final updatedList = [...state];
    updatedList[order] = updatedList[order].copyWith(
      etitedStateIsChecked: !oldState,
    );
    state = updatedList;
  }

  /// 小カテゴリーを末尾に追加する
  ///
  /// 渡された id と表示順は使わず、ここで採番する（理由は支出側と同じ）。
  void addSmallCategory(EditIncomeSmallCategoryValue value) {
    state = _withNormalizedOrder([
      ...state,
      value.copyWith(id: _nextUnsavedId()),
    ]);
  }

  // 小カテゴリーの名前を更新する
  void updateName(int index, String name) {
    // listを差し替えて購読者へ通知する
    final updatedList = [...state];
    updatedList[index] = updatedList[index].copyWith(name: name);
    state = updatedList;
  }

  /// まだDBに無い項目に振る次の id（負の一意な値）
  int _nextUnsavedId() {
    final minId = state.fold<int>(0, (min, e) => e.id < min ? e.id : min);
    return minId - 1;
  }

  /// 表示順をリストの並びどおり 0..n-1 に振り直す
  List<EditIncomeSmallCategoryValue> _withNormalizedOrder(
    List<EditIncomeSmallCategoryValue> list,
  ) {
    return [
      for (var i = 0; i < list.length; i++)
        list[i].copyWith(editedStateDisplayOrder: i),
    ];
  }
}
