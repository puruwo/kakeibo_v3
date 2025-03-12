import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/category_entity/category_entity.dart';
import 'package:kakeibo/domain/category_entity/category_repository.dart';

final categoryProvider = Provider<CategoryUsecase>(
  CategoryUsecase.new,
);

class CategoryUsecase {
  final Ref _ref;

  CategoryRepository get _categoryRepository => _ref.read(categoryRepositoryProvider);

  CategoryUsecase(this._ref);

  Future<List<CategoryEntity>> fetchAll() async {
    
    // todo: 選択日時を取得する
    // 例として2025年3月のデータを取得
    DateTime fromDate = DateTime.utc(2025, 3, 1); 
    DateTime toDate = DateTime.utc(2025, 3, 31);

    return await _categoryRepository.fetchAll(fromDate,toDate);
  }
}