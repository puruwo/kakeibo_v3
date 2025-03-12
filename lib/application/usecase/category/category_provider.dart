import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/category_entity/category_entity.dart';
import 'package:kakeibo/application/usecase/category/category_usecase.dart';

/// 全投稿を保持するプロバイダー
final categoryEntityProvider = FutureProvider.autoDispose<List<CategoryEntity>>(
  (ref) async => ref.watch(categoryProvider).fetchAll(),
);
