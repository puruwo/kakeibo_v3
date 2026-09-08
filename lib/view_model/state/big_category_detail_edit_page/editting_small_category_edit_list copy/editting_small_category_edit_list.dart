import 'package:kakeibo/domain/ui_value/edit_expense_small_category_list_value/edit_expense_small_category_value.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'editting_small_category_edit_list.g.dart';

// 大カテゴリー詳細編集ページの編集中カテゴリーリスト
//
// 大カテゴリーごとに別の状態を持つ（family）。ページを閉じると破棄される（autoDispose）ため、
// 戻るスワイプなど invalidate を通らない経路で離れても次のカテゴリーへ持ち越さない。
// 新規カテゴリー追加のときは bigId に -1 を渡す
@riverpod
class EdittingSmallCategoryListNotifier
    extends _$EdittingSmallCategoryListNotifier {
  @override
  List<EditExpenseSmallCategoryValue> build(int bigId) {
    // 最初のデータ
    return [];
  }

  void setData(List<EditExpenseSmallCategoryValue> initialData){
    state = initialData;
  }

  // 並べ替えが発生した時の処理
  void reorder(int oldIndex, int newIndex) {
    final updatedList = [...state];
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, item);

    // value自体が保持している表示順も変更する
    int i = 0;
    for(var value in updatedList){
      updatedList[i] = value.copyWith(editedStateDisplayOrder: i);
      i++;
    }

    state = updatedList;
  }

  // 表示チェックボックスの操作時
  void toggleDisplay(int order){
    // 旧状態を取得
    final oldState = state[order].etitedStateIsChecked;
    // 状態を反転させ更新
    state[order] = state[order].copyWith(etitedStateIsChecked: !oldState);
  }

  // 小カテゴリーを追加する
  void addSmallCategory(EditExpenseSmallCategoryValue value) {
    // 新しい値を追加
    state = [...state, value];
  }

  // 小カテゴリーの名前を更新する
  void updateName(int index, String name) {
    state[index] = state[index].copyWith(name: name);
  }
}
