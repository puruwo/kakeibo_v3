import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';


/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final expensebigCategoryRepositoryProvider = Provider<ExpenseBigCategoryRepository>(
  (_) => throw UnimplementedError("BigCategoryRepositoryの実装がされていません。"),
);

/// SqfExpenseNmallCategory(大カテゴリー)に関するリポジトリ
abstract interface class ExpenseBigCategoryRepository {

 // 全ての大カテゴリーの情報を取得する（削除済みを含む。登録済みの支出の表示・集計用）
  Future<List<ExpenseBigCategoryEntity>> fetchAll();

  /// 削除されていない大カテゴリーを全て取得する（入力・設定画面用。KP-024）
  Future<List<ExpenseBigCategoryEntity>> fetchAllActive();

  /// 大カテゴリーを論理削除する（行は残す。KP-024）
  Future<void> logicalDelete({required int id});

  /// 大カテゴリー指定で大カテゴリーのリストを取得する
  Future<ExpenseBigCategoryEntity> fetchByBigCategory({required int bigCategoryId});

  Future<void> update({required ExpenseBigCategoryEntity entity});

  /// 大カテゴリーを追加する
  Future<int> add({required ExpenseBigCategoryEntity entity});
}
