import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/monthly_all_category_card/moothly_all_category_card_usecase.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/all_category_card_value/all_category_card_entity.dart';
import 'package:kakeibo/view_model/state/date_scope/date_scope.dart';

// カレンダーで表示されている選択期間を取得し、Entityを取得する中間プロバイダ
final resolvedAllCategoryTileEntityProvider =
    FutureProvider<AllCategoryCardEntity>((ref) async {

  // 選択された日付から集計期間を取得する
  final dateScope = await ref.watch(dateScopeEntityProvider.selectAsync((data) => data));

  // 選択された集計期間を元に、Entityを取得する
  final entity = ref.watch(monthlyAllCategoryCardNotifierProvider(dateScope).future);
  return entity;
});
