import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_entity.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_entity.dart';

//Freezedで生成されるデータクラス
part 'category_card_entity.freezed.dart';

enum GraphType {
  hasBudget, // 予算あり
  hasBudgetButOver, // 予算ありだが、支出が予算を超過
  noExpenseNoBudget, // 予算なし支出なし
  noBudgetOtherHasBudget, // 他に予算設定はあるが、該当カテゴリーに予算なし
  allNoBudget, // 他のカードも全て予算なしだが、支出はある

  noBudget // 個別カード表示で利用 --予算なし
}

@freezed
class CategoryCardEntity with _$CategoryCardEntity {
  const factory CategoryCardEntity({
    required GraphType graphType,
    double? graphRatio,
    double? graphDenomiratorRatio,
    required int monthlyBudget,
    required int monthlyExpense,
    required CategoryAccountingEntity monthlyExpenseByCategoryEntity,
    required List<SmallCategoryTileEntity> smallCategoryList,
  }) = _CategoryCardEntity;
}
