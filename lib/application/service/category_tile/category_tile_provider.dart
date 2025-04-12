import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/category_tile_entity/category_tile_entity.dart';
import 'package:kakeibo/application/service/category_tile/category_tile_usecase.dart';
import 'package:kakeibo/domain/month_period_value/month_period_value.dart';

final categoryTileEntityProvider = FutureProvider.autoDispose.family<List<CategoryTileEntity>,MonthPeriodValue>(
  (ref,monthPeriodValue) async => ref.watch(categoryTileProvider).fetchSelectedRangeData(monthPeriodValue),
);
