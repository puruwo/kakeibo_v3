import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'is_income_small_category_list_edited.g.dart';

@Riverpod(keepAlive: true)
class IsIncomeSmallCategoryListEditedNotifier
    extends _$IsIncomeSmallCategoryListEditedNotifier {
  @override
  bool build() {
    return false;
  }

  void updateState(bool value) {
    state = value;
  }
}
