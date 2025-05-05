import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';

final incomeCategoryUsecaseProvider = Provider<IncomeCategoryUsecase>(
  IncomeCategoryUsecase.new,
);

class IncomeCategoryUsecase {
  IncomeCategoryUsecase(this._ref);

  final Ref _ref;

  // ゲッターを使うことで、呼び出されるたびに _ref.read() が実行され、状態が最新化される
  // IncomeSmallCategoryRepository get _smallCategoryRepositoryProvider =>
  //     _ref.read(incomeSmallCategoryRepositoryProvider);
  IncomeBigCategoryRepository get _bigCategoryRepositoryProvider =>
      _ref.read(incomeBigCategoryRepositoryProvider);

  /// [fetchAllBigCategory] メソッドは、収入大カテゴリーを全て取得する
  Future<List<IncomeBigCategoryEntity>> fetchAllBigCategory() async {
    // 大カテゴリーを全て取得する
    final list = await _bigCategoryRepositoryProvider.fetchAll();

    return list;
  }

  /// [fetchByBigCategory] メソッドは、収入小カテゴリーを取得する
  Future<IncomeBigCategoryEntity> fetchByBigCategory(int id) async {
    // 大カテゴリーを取得する
    final incomeBigCategoryEntity =
        await _bigCategoryRepositoryProvider.fetchByBigCategory(bigCategoryId: id);

    return incomeBigCategoryEntity;
  }



}
