import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/view/component/app_exception.dart';

import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/view_model/state/register_page/original_expense_entity/original_expense_entity.dart';

final expenseUsecaseProvider = Provider<ExpenseUsecase>(
  ExpenseUsecase.new,
);

class ExpenseUsecase {
  ExpenseUsecase(this._ref);
  final Ref _ref;

  ExpenseRepository get _expenseRepositoryProvider =>
      _ref.read(expenseRepositoryProvider);

  // 入力されたentityをproviderから取得
  ExpenseEntity get originalExpenseEntity =>
      _ref.read(originalExpenseEntityNotifierProvider);

  // 登録処理
  Future<void> add({required ExpenseEntity expenseEntity}) async {
    
    //エラーチェック
    if (expenseEntity.price <= 0) {
      throw const AppException('0円以上で入力してください');
    }
    if (expenseEntity.price >= 1888888) {
      throw const AppException('金額の入力値が大き過ぎます');
    }

    // tbl001にデータを追加する
    _expenseRepositoryProvider.insert(expenseEntity);
  }

  // 編集処理
  Future<void> edit(
      {required ExpenseEntity originalEntity,
      required ExpenseEntity editEntity}) async {

    //エラーチェック
    if (originalEntity == editEntity) {
      // 変更がない場合は何もしない
      throw const AppException('変更がありません');
    }
    if (editEntity.price <= 0) {
      throw const AppException('0円以上で入力してください');
    }
    if (editEntity.price >= 1888888) {
      throw const AppException('金額の入力値が大き過ぎます');
    }

    // tbl001にデータを追加する
    _expenseRepositoryProvider.update(editEntity);
  }

  Future<void> delete({required int id}) async {
    // tbl001にデータを削除する
    _expenseRepositoryProvider.delete(id);
  }
}
