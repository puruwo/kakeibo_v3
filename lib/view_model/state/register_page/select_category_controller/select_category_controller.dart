import 'package:kakeibo/domain/core/category_entity/category_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'select_category_controller.g.dart';

@riverpod
class SelectCategoryControllerNotifier extends _$SelectCategoryControllerNotifier {
  @override
  CategoryEntity build() {
    const big = ExpenseBigCategoryEntity(
      id: -1,
      colorCode: '',
      bigCategoryName: '',
      resourcePath: '',
      displayOrder: -1,
      isDisplayed: -1,
    );

    return const CategoryEntity(
      smallCategoryOrderKey:-1,
    bigCategoryKey:-1,
    displaydOrderInBig:-1,
    smallCategoryName:'',
    defaultDisplayed:-1,
    bigCategoryEntity:big,
    );
  }

  void setData(CategoryEntity newState) {
    state = newState;
  }
}