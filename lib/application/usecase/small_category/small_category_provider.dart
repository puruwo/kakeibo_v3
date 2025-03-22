import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/small_category_entity/small_category_entity.dart';
import 'package:kakeibo/application/usecase/small_category/small_category_usecase.dart';

final smallCategoryEntityProvider = FutureProvider.autoDispose<List<SmallCategoryEntity>>(
  (ref) async => ref.watch(smallCategoryProvider).fetchAll(),
);
