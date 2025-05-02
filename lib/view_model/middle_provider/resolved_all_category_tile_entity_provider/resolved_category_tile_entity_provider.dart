import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/monthly_category_card/moothly_category_card_usecase.dart';
import 'package:kakeibo/domain/category_card_entity/category_card_entity.dart';
import 'package:kakeibo/view_model/state/date_scope/date_scope.dart';

final resolvedAllCategoryTileEntityProvider =
    FutureProvider<List<CategoryCardEntity>>((ref) async {
  
  // 選択された日付から集計期間を取得する
  final monthPeriodValue = await ref.watch(dateScopeEntityProvider.selectAsync((data) => data.monthPeriod));
  
  // 選択された集計期間を元に、Entityを取得する
  final entity = ref.watch(monthlyCategoryCardNotifierProvider(monthPeriodValue).future);
  return entity;
});
