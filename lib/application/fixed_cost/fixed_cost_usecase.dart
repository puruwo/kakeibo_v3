import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_service.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view_model/state/date_scope/date_scope.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final fixedCostUsecaseProvider = Provider<FixedCostUsecase>(
  FixedCostUsecase.new,
);

class FixedCostUsecase {
  FixedCostUsecase(this._ref);
  final Ref _ref;

  FixedCostRepository get _fixedCostRepositoryProvider =>
      _ref.read(fixedCostRepositoryProvider);

  // DBの更新を管理するnotifierを取得
  UpdateDBCountNotifier get updateDBCountNotifier =>
      _ref.read(updateDBCountNotifierProvider.notifier);

  // 登録処理
  Future<void> add({required FixedCostEntity fixedCostEntity}) async {
    // 現在のdateScopeを取得
    final dateScope =
        await _ref.read(dateScopeEntityProvider.selectAsync((data) => data));

    //エラーチェック
    // 入力した日付が集計期間より前の日付でないかチェック

    final currentMonthPeriod = dateScope.monthPeriod;

    DateTime enteredDate = DateTime.parse(
        '${fixedCostEntity.firstPaymentDate.substring(0, 4)}-${fixedCostEntity.firstPaymentDate.substring(4, 6)}-${fixedCostEntity.firstPaymentDate.substring(6, 8)}');

    if (enteredDate.isBefore(currentMonthPeriod.startDatetime)) {
      throw const AppException('今月以降の日付を入力してください');
    }

    // レコードの初回支払いが今月かどうかチェックし、今月ならexpenseにデータを追加する
    FixedCostEntity insertRecord;
    if (enteredDate.isAfter(currentMonthPeriod.endDatetime)) {

      // 次の支払い日と最近支払い日を埋めて、挿入用データを作成
      insertRecord =
          FixedCostService().populateNextPaymentEntity(fixedCostEntity);

      // fixed_costにデータを追加する
      final fixedCostId =
          await _fixedCostRepositoryProvider.insert(insertRecord);

      // expenseEntityを作成し、DBに挿入する
      FixedCostService().insertToExpense(
          _ref, fixedCostEntity, insertRecord.firstPaymentDate, fixedCostId);
    } else {
      // 今月の支払いがない場合は、次の支払い日に初回支払い日を設定する
      insertRecord = fixedCostEntity.copyWith(
        nextPaymentDate: fixedCostEntity.firstPaymentDate,
      );
      // fixed_costにデータを追加する
      _fixedCostRepositoryProvider.insert(insertRecord);
    }

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }

  // 月の変わり目に呼ばれる処理
  // その月に支払いがある固定費を取得し、expenseに支出データを追加する
  Future<void> addExpenseForFixedCost(PeriodValue periodValue) async {

    // 期間を指定して支払いがある固定費を取得
    final fixedCostList = await _fixedCostRepositoryProvider.fetchNextPeriodPayment(
      period: periodValue,
    );

    // 今月の支払いがある固定費に対して、支出データを追加する
    for (final fixedCostEntity in fixedCostList) {
          // expenseEntityを作成し、DBに挿入する
          FixedCostService().insertToExpense(
            _ref,
            fixedCostEntity,
            fixedCostEntity.nextPaymentDate!,
            fixedCostEntity.id,
          );
          // 次の支払い日と最近支払い日を埋めて、更新用データを作成
          final updateRecord =FixedCostService().populateNextPaymentEntity(fixedCostEntity);

          // fixed_costを更新する
          _fixedCostRepositoryProvider.update(updateRecord);
    }

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }

  // 編集処理
  Future<void> edit(
      {required FixedCostEntity originalEntity,
      required FixedCostEntity editEntity}) async {
    //エラーチェック
    if (originalEntity == editEntity) {
      // 変更がない場合は何もしない
      throw const AppException('変更がありません');
    }

    // データを追加する
    _fixedCostRepositoryProvider.update(editEntity);

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }

  Future<void> delete({required int id}) async {
    // データを削除する
    _fixedCostRepositoryProvider.delete(id);

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }
}
