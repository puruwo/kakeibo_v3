import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/service/all_category_tile/all_category_tile_provider.dart';
import 'package:kakeibo/domain/all_category_tile_entity/all_category_tile_entity.dart';
import 'package:kakeibo/view_model/provider/selected_calendar_period/selected_calendar_period.dart';
import 'package:kakeibo/view_model/provider/selected_datetime/selected_datetime.dart';

// カレンダーで表示されている選択期間を取得し、Entityを取得する中間プロバイダ
final resolvedAllCategoryTileEntityProvider =
    FutureProvider<AllCategoryTileEntity>((ref) async {
  final selectedDate = ref.watch(selectedDatetimeNotifierProvider);
  final monthPeriodValue = await ref.watch(selectedCalendarPeriodProvider(selectedDate).future);
  final entity = ref.watch(allCategoryTileEntityProvider(monthPeriodValue).future);
  return entity;
});
