import 'package:kakeibo/domain/ui_value/edit_expense_small_category_list_value/edit_expense_small_category_value.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'editting_small_category_edit_list.g.dart';

// 大カテゴリー並び替え編集ページの状態を保持したカテゴリーリスト
@Riverpod(keepAlive: true)
class EdittingSmallCategoryListNotifier
    extends _$EdittingSmallCategoryListNotifier {
  List<EditExpenseSmallCategoryValue> build() {
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
}
