import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/tbl202/big_category_entity.dart';


/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final bigCategoryRepositoryProvider = Provider<BigCategoryRepository>(
  (_) => throw UnimplementedError("BigCategoryRepositoryの実装がされていません。"),
);

/// tbl202(大カテゴリー)に関するリポジトリ
abstract interface class BigCategoryRepository {

 // 全ての大カテゴリーの情報を取得する
  Future<BigCategoryEntity> fetchAll();

  /// 大カテゴリー指定で大カテゴリーのリストを取得する
  Future<BigCategoryEntity> fetchByBigCategory({required int bigCategoryId});
}
