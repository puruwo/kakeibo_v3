import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/category_tile_entity/category_tile_entity.dart';
import 'package:kakeibo/application/service/category_tile/category_tile_usecase.dart';

final categoryTileEntityProvider = FutureProvider.autoDispose<List<CategoryTileEntity>>(
  (ref) async => ref.watch(categoryTileProvider).fetchSelectedRangeData(),
);
