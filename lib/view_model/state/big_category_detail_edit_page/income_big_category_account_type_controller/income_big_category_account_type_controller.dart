import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_income_big_category_appearance_edited/is_income_big_category_appearance_edited.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'income_big_category_account_type_controller.g.dart';

/// 収入大カテゴリー編集の会計種別（1=生活収支, 2=特別枠）の入力状態（ADR-025）
@riverpod
class IncomeBigCategoryAccountTypeControllerNotifier
    extends _$IncomeBigCategoryAccountTypeControllerNotifier {
  @override
  int build() {
    return AccountTypeConstants.living;
  }

  void initState(int accountType) {
    state = accountType;
  }

  void updateState(int accountType) {
    state = accountType;

    ref
        .read(isIncomeBigCategoryAppearanceEditedNotifierProvider.notifier)
        .updateState(true);
  }
}
