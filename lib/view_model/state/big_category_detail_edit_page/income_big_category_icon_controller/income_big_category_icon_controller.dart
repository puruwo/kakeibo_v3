import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_income_big_category_appearance_edited/is_income_big_category_appearance_edited.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'income_big_category_icon_controller.g.dart';

@riverpod
class IncomeBigCategoryIconControllerNotifier
    extends _$IncomeBigCategoryIconControllerNotifier {
  @override
  String build() {
    return 'assets/images/icon_favo.svg';
  }

  void initState(String path) {
    state = path;
  }

  void updateState(String path) {
    state = path;

    ref
        .read(isIncomeBigCategoryAppearanceEditedNotifierProvider.notifier)
        .updateState(true);
  }
}
