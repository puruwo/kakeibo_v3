import 'package:kakeibo/domain/ui_value/expense_big_category_with_small_list_value/edit_expense_big_category_value.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'editting_big_category_list.g.dart';

// 大カテゴリー並び替え編集ページの状態を保持したカテゴリーリスト
@Riverpod(keepAlive: false)
class EdittingBigCategoryListNotifier
    extends _$EdittingBigCategoryListNotifier {
  List<EditExpenseBigCategoryValue> build() {
    // 最初のデータ
    return [];
  }

  void setData(List<EditExpenseBigCategoryValue> initialData){
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
    for(var bigCategoryValue in updatedList){
      updatedList[i] = bigCategoryValue.copyWith(editedStateDisplayOrder: i);
      i++;
    }

    state = updatedList;
  }

  /// 削除した大カテゴリーをリストから外す（KP-024）
  ///
  /// DBの論理削除は済んでいる。残りの表示順は並びどおりに振り直す
  void removeById(int id) {
    final updatedList = state.where((e) => e.id != id).toList();
    for (var i = 0; i < updatedList.length; i++) {
      updatedList[i] = updatedList[i].copyWith(editedStateDisplayOrder: i);
    }
    state = updatedList;
  }
}
