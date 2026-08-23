import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_usecase.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final fixedCostRecordUsecaseProvider = Provider<FixedCostRecordUsecase>(
  FixedCostRecordUsecase.new,
);

/// 固定費の実績行（expenseのうち fixed_cost_id を持つ行）を操作するユースケース
///
/// v10で実績の格納先が fixed_cost_record から expense に変わったため、
/// 確定・編集・削除はいずれも expense を対象にする（仕様 §6.4）。
class FixedCostRecordUsecase {
  FixedCostRecordUsecase(this._ref);
  final Ref _ref;

  ExpenseRepository get _expenseRepositoryProvider =>
      _ref.read(expenseRepositoryProvider);

  FixedCostUsecase get _fixedCostUsecaseRepositoryProvider =>
      _ref.read(fixedCostUsecaseProvider);

  // DBの更新を管理するnotifierを取得
  UpdateDBCountNotifier get updateDBCountNotifier =>
      _ref.read(updateDBCountNotifierProvider.notifier);

  /// 固定費の実績行を1行削除する
  ///
  /// 確定済みの行を削除すると推定額の平均の根拠が変わるため、
  /// 削除後に推定額を再計算する（仕様 §6.5 の再計算トリガー）。
  Future<void> delete({required int id}) async {
    // 再計算の要否判定に必要なので、削除前に対象行を読む
    final target = await _expenseRepositoryProvider.fetchById(id: id);

    _expenseRepositoryProvider.delete(id);

    final fixedCostId = target?.fixedCostId;
    if (fixedCostId != null && target!.isConfirmed == 1) {
      await _fixedCostUsecaseRepositoryProvider.updateEstimatedPrice(
        fixedCostId: fixedCostId,
      );
    }

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }

  /// 固定費の実績行を編集する
  ///
  /// 未確定行への金額入力は常に確定操作として扱う（price設定＋is_confirmed=1）。
  /// 未確定のままの手動金額変更は提供しない（仕様 §6.4）。
  Future<void> edit({required ExpenseEntity entity}) async {
    final price = entity.price;

    // エラーチェック
    if (price == null || price <= 0) {
      throw const AppException('0円以上で入力してください');
    }
    if (price >= 1888888) {
      throw const AppException('金額の入力値が大き過ぎます');
    }

    // 金額入力＝確定操作。予想額 estimatedPrice は消さずに残す（仕様 §3）
    await _expenseRepositoryProvider.update(entity.copyWith(isConfirmed: 1));

    // 確定済み行の金額が変わると平均の根拠が変わるため、推定額を再計算する
    final fixedCostId = entity.fixedCostId;
    if (fixedCostId != null) {
      await _fixedCostUsecaseRepositoryProvider.updateEstimatedPrice(
        fixedCostId: fixedCostId,
      );
    }

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }
}
