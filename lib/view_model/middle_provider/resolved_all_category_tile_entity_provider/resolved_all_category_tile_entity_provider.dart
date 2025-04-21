import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/service/all_category_tile/all_category_tile_usecase.dart';
import 'package:kakeibo/domain/all_category_tile_entity/all_category_tile_entity.dart';
import 'package:kakeibo/view_model/state/date_scope/selected_period/selected_period.dart';
import 'package:kakeibo/view_model/state/date_scope/selected_datetime/selected_datetime.dart';

// カレンダーで表示されている選択期間を取得し、Entityを取得する中間プロバイダ
final resolvedAllCategoryTileEntityProvider =
    FutureProvider<AllCategoryTileEntity>((ref) async {
  
  // 選択された日付を取得する
  final selectedDate = ref.watch(selectedDatetimeNotifierProvider);

  // 選択された日付から集計期間を取得する
  final monthPeriodValue = await ref.watch(selectedPeriodProvider(selectedDate).future);

  // 選択された集計期間を元に、Entityを取得する
  final entity = ref.watch(allCategoryTileNotifierProvider(monthPeriodValue).future);
  return entity;
});
