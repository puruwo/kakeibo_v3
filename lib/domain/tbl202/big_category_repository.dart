import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/tbl202/big_category_entity.dart';


/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final bigCategoryRepositoryProvider = Provider<BigCategoryRepository>(
  (_) => throw UnimplementedError("BigCategoryRepositoryの実装がされていません。"),
);

/// tbl202(大カテゴリー)に関するリポジトリ
abstract interface class BigCategoryRepository {

  /// カテゴリーidを指定してレコードを取得する
  Future<BigCategoryEntity> fetch({required int id});
}
