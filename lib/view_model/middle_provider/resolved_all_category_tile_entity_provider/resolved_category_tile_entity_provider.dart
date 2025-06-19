import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/monthly_category_card/moothly_category_card_usecase.dart';
import 'package:kakeibo/application/monthly_category_card/moothly_selected_category_card_usecase.dart';
import 'package:kakeibo/application/monthly_category_card/request_moothly_category_card.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/category_card_entity.dart';
import 'package:kakeibo/view_model/state/date_scope/date_scope.dart';

final resolvedAllCategoryTileEntityProvider =
    FutureProvider<List<CategoryCardEntity>>((ref) async {
  
  // 選択された日付から集計期間を取得する
  final dateScope = await ref.watch(dateScopeEntityProvider.selectAsync((data) => data));
  
  // 選択された集計期間を元に、Entityを取得する
  final entity = ref.watch(monthlyCategoryCardNotifierProvider(dateScope).future);
  return entity;
});

final resolvedCategoryTileEntityProvider =
    FutureProvider.family<CategoryCardEntity,int>((ref,bigId) async {
  
  // 選択された日付から集計期間を取得する
  final dateScope = await ref.watch(dateScopeEntityProvider.selectAsync((data) => data));

  final request = RequestMonthlyCateoryCard(
    bigId: bigId,
    dateScope: dateScope,
  );
  
  // 選択された集計期間を元に、Entityを取得する
  final entity = ref.watch(monthlySelectedCategoryCardNotifierProvider(request).future);
  return entity;
});
