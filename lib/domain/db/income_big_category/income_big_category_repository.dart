import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';



/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final incomeBigCategoryRepositoryProvider = Provider<IncomeBigCategoryRepository>(
  (_) => throw UnimplementedError("IncomeBigCategoryRepositoryの実装がされていません。"),
);

/// 収入大カテゴリーに関するリポジトリ
abstract interface class IncomeBigCategoryRepository {

 // 全ての大カテゴリーの情報を取得する
  Future<List<IncomeBigCategoryEntity>> fetchAll();

  /// 大カテゴリー指定で大カテゴリーのリストを取得する
  Future<IncomeBigCategoryEntity> fetchByBigCategory({required int bigCategoryId});
}
