import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_service.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_usecase.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final fixedCostConversionUsecaseProvider = Provider<FixedCostConversionUsecase>(
  FixedCostConversionUsecase.new,
);

/// 既存の支出レコードを固定費化するユースケース（仕様 §6.2・§6.6）
///
/// 当該レコードから固定費マスタを作り、その行に fixed_cost_id を付与する。
/// 過去の類似レコードの遡及紐付け・過去分の実績生成は行わない。
class FixedCostConversionUsecase {
  FixedCostConversionUsecase(this._ref);
  final Ref _ref;

  FixedCostRepository get _fixedCostRepositoryProvider =>
      _ref.read(fixedCostRepositoryProvider);

  ExpenseRepository get _expenseRepositoryProvider =>
      _ref.read(expenseRepositoryProvider);

  FixedCostUsecase get _fixedCostUsecaseProvider =>
      _ref.read(fixedCostUsecaseProvider);

  // DBの更新を管理するnotifierを取得
  UpdateDBCountNotifier get updateDBCountNotifier =>
      _ref.read(updateDBCountNotifierProvider.notifier);

  /// 次回支払日の算出で回す支払い周期の上限
  /// 支払い周期が不正なマスタで無限ループにならないようにするための保険
  static const int _maxCycles = 240;

  /// 既存の支出レコードを固定費化する
  ///
  /// [expenseEntity] は固定費化する支出レコード（実額を持つ確定済みの行）。
  /// [name] は固定費マスタの名称、[variable] は 0=確定型 / 1=変動型。
  Future<void> convertToFixedCost({
    required ExpenseEntity expenseEntity,
    required String name,
    required int variable,
    required int intervalNumber,
    required int intervalUnit,
  }) async {
    // エラーチェック
    if (name.isEmpty) {
      throw const AppException('名前を入力してください');
    }
    final price = expenseEntity.price;
    if (price == null || price <= 0) {
      throw const AppException('0円以上で入力してください');
    }
    if (intervalNumber <= 0 || (intervalUnit != 1 && intervalUnit != 2)) {
      throw const AppException('支払い頻度を選択してください');
    }
    if (expenseEntity.fixedCostId != null) {
      throw const AppException('すでに固定費として登録されています');
    }

    // マスタを作成する
    // カテゴリーは当該レコードの支出小カテゴリーを引き継ぐ
    // 推定額は当該レコードの金額で初期化する（仕様 §6.5）
    // 旧列 fixedCostCategoryId はT6で削除するまで0を入れておく
    final baseEntity = FixedCostEntity(
      name: name,
      variable: variable,
      price: price,
      estimatedPrice: price,
      fixedCostCategoryId: 0,
      expenseSmallCategoryId: expenseEntity.paymentCategoryId,
      intervalNumber: intervalNumber,
      intervalUnit: intervalUnit,
      firstPaymentDate: expenseEntity.date,
      recentPaymentDate: expenseEntity.date,
      nextPaymentDate: _calculateNextPaymentDate(expenseEntity.date,
          intervalNumber: intervalNumber, intervalUnit: intervalUnit),
    );

    final fixedCostId = await _fixedCostRepositoryProvider.insert(baseEntity);

    // 当該レコードに fixed_cost_id を付与する（実額があるので確定済み扱い）
    await _expenseRepositoryProvider.update(
      expenseEntity.copyWith(fixedCostId: fixedCostId, isConfirmed: 1),
    );

    // 変動型は紐づいた確定行（この1件）の平均で推定額を確定させる
    if (variable == 1) {
      await _fixedCostUsecaseProvider.updateEstimatedPrice(
        fixedCostId: fixedCostId,
      );
    }

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }

  /// 次回支払日を「今日より後の最初の支払日」まで進めて返す
  ///
  /// 古い支出を固定費化しても過去分のキャッチアップ生成はしない（仕様 §6.6）。
  /// 当該レコードの支払いは記録済みなので、今日ちょうどの日付も進める対象にする。
  String _calculateNextPaymentDate(
    String paymentDate, {
    required int intervalNumber,
    required int intervalUnit,
  }) {
    final today =
        DateFormat('yyyyMMdd').format(_ref.read(systemDatetimeNotifierProvider));

    // 日付は同形式のyyyyMMdd文字列なので辞書順比較で大小判定できる
    var entity = FixedCostEntity(
      variable: 0,
      fixedCostCategoryId: 0,
      intervalNumber: intervalNumber,
      intervalUnit: intervalUnit,
      firstPaymentDate: paymentDate,
    );

    var cycleCount = 0;
    do {
      entity = FixedCostService().populateNextPaymentEntity(entity);
      cycleCount++;
    } while (entity.nextPaymentDate!.compareTo(today) <= 0 &&
        cycleCount < _maxCycles);

    return entity.nextPaymentDate!;
  }
}
