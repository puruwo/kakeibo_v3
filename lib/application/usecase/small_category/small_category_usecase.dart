import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/small_category_entity/small_category_entity.dart';
import 'package:kakeibo/domain/small_category_entity/small_category_repository.dart';

final smallCategoryProvider = Provider<SmallCategoryUsecase>(
  SmallCategoryUsecase.new,
);

class SmallCategoryUsecase {
  final Ref _ref;

  SmallCategoryRepository get _smallCategoryRepository => _ref.read(smallCategoryRepositoryProvider);

  SmallCategoryUsecase(this._ref);

  Future<List<SmallCategoryEntity>> fetchAll() async {

    
    // todo: 選択日時を取得する
    // 例として2025年3月のデータを取得
    int id = 1;
    DateTime fromDate = DateTime.utc(2025, 3, 1); 
    DateTime toDate = DateTime.utc(2025, 3, 31);

    return await _smallCategoryRepository.fetchAll(id,fromDate,toDate);
  }
}