import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/all_category_tile_entity/all_category_tile_entity.dart';
import 'package:kakeibo/application/service/all_category_tile/all_category_tile_usecase.dart';

final allCategoryTileEntityProvider = FutureProvider.autoDispose<AllCategoryTileEntity>(
  (ref) async => ref.watch(allCategoryTileProvider).fetch(),
);
