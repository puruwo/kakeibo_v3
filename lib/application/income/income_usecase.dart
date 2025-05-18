import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/view/component/app_exception.dart';

import 'package:kakeibo/view_model/state/update_DB_count.dart';

final incomeUsecaseProvider = Provider<IncomeUsecase>(
  IncomeUsecase.new,
);

class IncomeUsecase {
  IncomeUsecase(this._ref);
  final Ref _ref;

  IncomeRepository get _incomeRepositoryProvider =>
      _ref.read(incomeRepositoryProvider);


  // DBの更新を管理するnotifierを取得
  UpdateDBCountNotifier get updateDBCountNotifier =>
      _ref.read(updateDBCountNotifierProvider.notifier);

  // 登録処理
  Future<void> add({required IncomeEntity incomeEntity}) async {
    
    //エラーチェック
    if (incomeEntity.price <= 0) {
      throw const AppException('0円以上で入力してください');
    }
    if (incomeEntity.price >= 99999999) {
      throw const AppException('金額の入力値が大き過ぎます');
    }

    // incomeにデータを追加する
    _incomeRepositoryProvider.insert(incomeEntity);

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();

  }

  // 編集処理
  Future<void> edit(
      {required IncomeEntity originalEntity,
      required IncomeEntity editEntity}) async {

    //エラーチェック
    if (originalEntity == editEntity) {
      // 変更がない場合は何もしない
      throw const AppException('変更がありません');
    }
    if (editEntity.price <= 0) {
      throw const AppException('0円以上で入力してください');
    }
    if (editEntity.price >= 99999999) {
      throw const AppException('金額の入力値が大き過ぎます');
    }

    // incomeにデータを追加する
    _incomeRepositoryProvider.update(editEntity);

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }

  Future<void> delete({required int id}) async {
    // income内のレコードデータを削除する
    _incomeRepositoryProvider.delete(id);

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }
}
