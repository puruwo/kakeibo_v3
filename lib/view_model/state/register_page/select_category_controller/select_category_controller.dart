import 'package:kakeibo/domain/core/category_entity/expense_category_entity/expense_category_entity.dart';
import 'package:kakeibo/domain/core/category_entity/i_category_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'select_category_controller.g.dart';

@riverpod
class SelectCategoryControllerNotifier
    extends _$SelectCategoryControllerNotifier {
  @override
  ICategoryEntity build() {
    return const ExpenseCategoryEntity(
      smallCategoryOrderKey: -1,
      bigCategoryKey: -1,
      displaydOrderInBig: -1,
      smallCategoryName: '',
      defaultDisplayed: -1,
      bigCategoryName: '',
      colorCode: '',
      resourcePath: '',
      displayOrder: -1,
      isDisplayed: -1,
    );
  }

  void setData(ICategoryEntity newState) {
    state = newState;
  }
}
