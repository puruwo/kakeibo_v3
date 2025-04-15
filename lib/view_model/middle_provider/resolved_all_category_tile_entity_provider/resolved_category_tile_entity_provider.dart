import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/service/category_tile/category_tile_usecase.dart';
import 'package:kakeibo/domain/category_tile_entity/category_tile_entity.dart';
import 'package:kakeibo/view_model/provider/selected_calendar_period/selected_calendar_period.dart';
import 'package:kakeibo/view_model/provider/selected_datetime/selected_datetime.dart';

final resolvedAllCategoryTileEntityProvider =
    FutureProvider<List<CategoryTileEntity>>((ref) async {

  // 選択された日付を取得する
  final selectedDate = ref.watch(selectedDatetimeNotifierProvider);
  
  // 選択された日付から集計期間を取得する
  final monthPeriodValue = await ref.watch(selectedCalendarPeriodProvider(selectedDate).future);
  
  // 選択された集計期間を元に、Entityを取得する
  final entity = ref.watch(categoryTileNotifierProvider(monthPeriodValue).future);
  return entity;
});
