import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';


/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final expensebigCategoryRepositoryProvider = Provider<ExpenseBigCategoryRepository>(
  (_) => throw UnimplementedError("BigCategoryRepositoryの実装がされていません。"),
);

/// tbl202(大カテゴリー)に関するリポジトリ
abstract interface class ExpenseBigCategoryRepository {

 // 全ての大カテゴリーの情報を取得する
  Future<List<ExpenseBigCategoryEntity>> fetchAll();

  /// 大カテゴリー指定で大カテゴリーのリストを取得する
  Future<ExpenseBigCategoryEntity> fetchByBigCategory({required int bigCategoryId});
}
