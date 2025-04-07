import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/category_entity/category_entity.dart';
import 'package:kakeibo/application/service/category/category_usecase.dart';

final categoryEntityProvider = FutureProvider.autoDispose<List<CategoryEntity>>(
  (ref) async => ref.watch(categoryProvider).fetchAll(),
);
