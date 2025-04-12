import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/service/category_tile/category_tile_provider.dart';
import 'package:kakeibo/domain/category_tile_entity/category_tile_entity.dart';
import 'package:kakeibo/view_model/provider/selected_calendar_period/selected_calendar_period.dart';
import 'package:kakeibo/view_model/provider/selected_datetime/selected_datetime.dart';

final resolvedAllCategoryTileEntityProvider =
    FutureProvider<List<CategoryTileEntity>>((ref) async {
  final selectedDate = ref.watch(selectedDatetimeNotifierProvider);
  final monthPeriodValue = await ref.watch(selectedCalendarPeriodProvider(selectedDate).future);
  final entity = ref.watch(categoryTileEntityProvider(monthPeriodValue).future);
  return entity;
});
