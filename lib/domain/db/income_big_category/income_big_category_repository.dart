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

  /// 大カテゴリーを追加する（戻り値は採番されたid）
  Future<int> add({required IncomeBigCategoryEntity entity});

  /// 大カテゴリーを更新する
  Future<void> update({required IncomeBigCategoryEntity entity});

  /// 大カテゴリーを削除する（id=1, id=2 は削除不可）
  Future<void> delete({required int id});

  /// 既存の大カテゴリーIDの最大値を返す
  Future<int> getMaxId();
}
