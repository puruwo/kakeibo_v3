import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/all_category_tile_entity/all_category_tile_entity.dart';
import 'package:kakeibo/application/usecase/all_category_tile/all_category_tile_usecase.dart';

/// 全投稿を保持するプロバイダー
final allCategoryTileEntityProvider = FutureProvider.autoDispose<AllCategoryTileEntity>(
  (ref) async => ref.watch(allCategoryTileProvider).fetch(),
);
