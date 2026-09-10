import 'package:kakeibo/domain/ui_value/edit_expense_small_category_list_value/edit_expense_small_category_value.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'editting_small_category_edit_list.g.dart';

// 大カテゴリー詳細編集ページの編集中カテゴリーリスト
//
// 大カテゴリーごとに別の状態を持つ（family）。ページを閉じると破棄される（autoDispose）ため、
// 戻るスワイプなど invalidate を通らない経路で離れても次のカテゴリーへ持ち越さない。
// 新規カテゴリー追加のときは bigId に -1 を渡す
//
// このリストは2つの不変条件を保つ:
//   1. editedStateDisplayOrder は並びどおりの 0..n-1（歯抜けを作らない）
//   2. まだDBに無い項目の id は負の一意な値（-1, -2, ...）
@riverpod
class EdittingSmallCategoryListNotifier
    extends _$EdittingSmallCategoryListNotifier {
  @override
  List<EditExpenseSmallCategoryValue> build(int bigId) {
    // 最初のデータ
    return [];
  }

  void setData(List<EditExpenseSmallCategoryValue> initialData) {
    state = _withNormalizedOrder(initialData);
  }

  // 並べ替えが発生した時の処理
  void reorder(int oldIndex, int newIndex) {
    final updatedList = [...state];
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, item);

    state = _withNormalizedOrder(updatedList);
  }

  // 表示チェックボックスの操作時
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
  /// 渡された id と表示順は使わず、ここで採番する。
  /// 追加のたびに同じ id を使い回すと、複数追加したときに項目を区別できない
  /// （保存時の「どれが新規か」の判定と行の同一性がどちらもこの id に依存する）。
  void addSmallCategory(EditExpenseSmallCategoryValue value) {
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
  List<EditExpenseSmallCategoryValue> _withNormalizedOrder(
    List<EditExpenseSmallCategoryValue> list,
  ) {
    return [
      for (var i = 0; i < list.length; i++)
        list[i].copyWith(editedStateDisplayOrder: i),
    ];
  }
}
