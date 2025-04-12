import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/all_category_tile_entity/all_category_tile_entity.dart';
import 'package:kakeibo/application/service/all_category_tile/all_category_tile_usecase.dart';
import 'package:kakeibo/domain/month_period_value/month_period_value.dart';

final allCategoryTileEntityProvider = FutureProvider.family.autoDispose<AllCategoryTileEntity,MonthPeriodValue>(
  (ref,selectedMonthPeriod) async => ref.watch(allCategoryTileProvider).fetch(selectedMonthPeriod),
);
