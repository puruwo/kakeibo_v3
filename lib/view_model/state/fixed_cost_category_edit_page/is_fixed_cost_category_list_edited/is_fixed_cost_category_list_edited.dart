import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'is_fixed_cost_category_list_edited.g.dart';

//編集したかどうか
@Riverpod(keepAlive: true)
class IsFixedCostCategoryListEditedNotifier
    extends _$IsFixedCostCategoryListEditedNotifier {
  @override
  bool build() {
    // 最初のデータ
    return false;
  }

  void updateState(bool bool) {
    // データを上書き
    state = bool;
  }
}
