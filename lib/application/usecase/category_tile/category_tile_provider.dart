import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/category_tile_entity/category_tile_entity.dart';
import 'package:kakeibo/application/usecase/category_tile/category_tile_usecase.dart';

/// 全投稿を保持するプロバイダー
final categoryTileEntityProvider = FutureProvider.autoDispose<List<CategoryTileEntity>>(
  (ref) async => ref.watch(categoryTileProvider).fetchAll(),
);
