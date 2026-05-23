import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'is_income_big_category_appearance_edited.g.dart';

@Riverpod(keepAlive: true)
class IsIncomeBigCategoryAppearanceEditedNotifier
    extends _$IsIncomeBigCategoryAppearanceEditedNotifier {
  @override
  bool build() {
    return false;
  }

  void updateState(bool value) {
    state = value;
  }
}
