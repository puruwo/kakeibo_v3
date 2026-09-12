import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_service.dart';
import 'package:kakeibo/application/fixed_cost_record/fixed_cost_record_service.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain_service/system_datetime/date_scope.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/logger.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final fixedCostUsecaseProvider = Provider<FixedCostUsecase>(
  FixedCostUsecase.new,
);

class FixedCostUsecase {
  FixedCostUsecase(this._ref);
  final Ref _ref;

  FixedCostRepository get _fixedCostRepositoryProvider =>
      _ref.read(fixedCostRepositoryProvider);

  ExpenseRepository get _expenseRepositoryProvider =>
      _ref.read(expenseRepositoryProvider);

  FixedCostRecordService get _fixedCostRecordServiceProvider =>
      _ref.read(fixedCostRecordServiceProvider);

  // DBの更新を管理するnotifierを取得
  UpdateDBCountNotifier get updateDBCountNotifier =>
      _ref.read(updateDBCountNotifierProvider.notifier);

  // 登録処理
  // 登録完了シート（追加改修 0828）が次回支払日等を表示できるよう、
  // 挿入したマスタ（nextPaymentDate設定済み）を返す
  Future<FixedCostEntity> add({required FixedCostEntity fixedCostEntity}) async {
    // 現在のdateScopeを取得
    final dateScope = await _ref
        .read(systemDateScopeEntityProvider.selectAsync((data) => data));

    //エラーチェック
    // 入力した日付が集計期間より前の日付でないかチェック

    final currentMonthPeriod = dateScope.aggregationMonthPeriod;

    DateTime enteredDate = DateTime.parse(
        '${fixedCostEntity.firstPaymentDate.substring(0, 4)}-${fixedCostEntity.firstPaymentDate.substring(4, 6)}-${fixedCostEntity.firstPaymentDate.substring(6, 8)}');

    //エラーチェック
    if (enteredDate.isBefore(currentMonthPeriod.startDatetime)) {
      throw const AppException('今月の集計期間以降の日付を入力してください');
    }
    if (fixedCostEntity.name == '') {
      throw const AppException('名前を入力してください');
    }
    if (fixedCostEntity.price <= 0 && fixedCostEntity.variable == 0) {
      throw const AppException('0円以上で入力してください');
    }
    if (fixedCostEntity.price >= 99999999) {
      throw const AppException('金額の入力値が大き過ぎます');
    }
    // カテゴリーの参照先は支出小カテゴリー（仕様 §3）
    if (fixedCostEntity.expenseSmallCategoryId <= 0) {
      throw const AppException('カテゴリーを選択してください');
    }

    FixedCostEntity insertRecord;
    if (enteredDate.isAfter(currentMonthPeriod.endDatetime)) {
      //レコードの初回支払いが来月以降
      // 今月の支払いがないので、次の支払い日に初回支払い日を設定する
      insertRecord = fixedCostEntity.copyWith(
        nextPaymentDate: fixedCostEntity.firstPaymentDate,
      );
      // fixed_costにデータを追加する
      // 挿入失敗を完了シート表示前に検知できるよう、完了を待つ
      await _fixedCostRepositoryProvider.insert(insertRecord);
    } else {
      // レコードの初回支払いが今月かどうかチェックし、今月ならexpenseにデータを追加する
      // 次の支払い日と最近支払い日を埋めて、挿入用データを作成
      insertRecord =
          FixedCostService().populateNextPaymentEntity(fixedCostEntity);

      // fixed_costにデータを追加する
      final id = await _fixedCostRepositoryProvider.insert(insertRecord);

      final insertedFixedCostRecord = insertRecord.copyWith(id: id);

      // fixedCostRecordEntityを作成し、DBに挿入する
      await FixedCostService().insertToFixedCostRecord(
        _ref,
        insertedFixedCostRecord,
        insertRecord.firstPaymentDate,
      );
    }

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();

    return insertRecord;
  }

  // 1マスタあたりに回収する支払い周期の上限
  // 支払い周期が不正なマスタで無限ループにならないようにするための保険
  // 月次なら20年分に相当し、正常なデータがこの回数に達することはない
  static const int _maxCatchUpCycles = 240;

  // 月の変わり目に呼ばれる処理
  // その月までに支払いがある固定費を取得し、expenseに支出データを追加する
  //
  // 取得条件には期間開始日の下限が無いため、過去のバッチで取りこぼして
  // next_payment_dateが過去日のまま固定されたマスタもここに含まれる。
  // そのため1マスタにつき、next_payment_dateが期間終了日を超えるまで繰り返し、
  // 複数周期ぶんの実績をまとめて生成して追いつかせる。
  Future<void> addExpenseForFixedCost(PeriodValue periodValue) async {
    // 期間を指定して支払いがある固定費を取得
    final fixedCostList =
        await _fixedCostRepositoryProvider.fetchNextPeriodPayment(
      period: periodValue,
    );

    // 期間終了日（yyyyMMdd）。日付は同形式の文字列なので辞書順比較で大小判定できる
    final periodEndDate = DateFormat('yyyyMMdd').format(periodValue.endDatetime);

    // 支払いがある固定費に対して、支出データを追加する
    for (final fixedCostEntity in fixedCostList) {
      // 支払い周期が不正なマスタは次の支払い日を計算できず、日付が前進しない
      // 処理を打ち切り、他のマスタの処理は継続する
      if ((fixedCostEntity.intervalUnit != 1 &&
              fixedCostEntity.intervalUnit != 2) ||
          fixedCostEntity.intervalNumber <= 0) {
        logger.e(
            '[FAIL]: 固定費マスタの支払い周期が不正です id=${fixedCostEntity.id} intervalUnit=${fixedCostEntity.intervalUnit} intervalNumber=${fixedCostEntity.intervalNumber}');
        continue;
      }

      // 次の支払い日が未設定のマスタは周期計算の起点が無く、日付が前進しない
      // 処理を打ち切り、他のマスタの処理は継続する
      if (fixedCostEntity.nextPaymentDate == null) {
        logger.e('[FAIL]: 固定費マスタの次の支払い日が未設定です id=${fixedCostEntity.id}');
        continue;
      }

      // 次の支払い日が期間終了日を超えるまで、周期ぶんの実績を生成し続ける
      final currentEntity = await _generateRecordsThroughPeriodEnd(
        fixedCostEntity,
        periodEndDate,
      );

      // 何周期進んだかに関わらず、fixed_costの更新は最後に1回だけ行う
      await _fixedCostRepositoryProvider.update(currentEntity);
    }

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }


  /// 次の支払い日が [periodEndDate]（yyyyMMdd）を超えるまで、周期ぶんの実績を生成する
  ///
  /// バッチ（月の変わり目）と、固定費の設定画面での編集（ADR-006 規則3・KP-015）が
  /// 同じ規則で実績を作るための共通処理。マスタの更新は呼び出し側で行う。
  /// 同じ支払い日の実績が既にある場合は生成せず日付だけ進める（多重生成の防止）。
  /// [entity.nextPaymentDate] は非nullであること。
  Future<FixedCostEntity> _generateRecordsThroughPeriodEnd(
    FixedCostEntity entity,
    String periodEndDate,
  ) async {
    var currentEntity = entity;
    // 処理中の支払い日。populateNextPaymentEntityは必ず次の支払い日を埋めるためnullにならない
    var paymentDate = entity.nextPaymentDate!;
    var cycleCount = 0;

    while (paymentDate.compareTo(periodEndDate) <= 0) {
      if (cycleCount >= _maxCatchUpCycles) {
        logger.e(
            '[FAIL]: 固定費の回収が上限($_maxCatchUpCycles回)に達したため打ち切ります id=${entity.id}');
        break;
      }
      cycleCount++;

      final alreadyExists =
          await _expenseRepositoryProvider.existsByFixedCostIdAndDate(
        fixedCostId: currentEntity.id!,
        date: paymentDate,
      );
      if (!alreadyExists) {
        // fixedCostRecordEntityを作成し、DBに挿入する
        await FixedCostService().insertToFixedCostRecord(
          _ref,
          currentEntity,
          paymentDate,
        );
      }

      // 次の支払い日と最近支払い日を埋めて、次の周期へ進める
      currentEntity =
          FixedCostService().populateNextPaymentEntity(currentEntity);
      paymentDate = currentEntity.nextPaymentDate!;
    }

    return currentEntity;
  }

  /// 次の支払い日を「今日以降で最初に来る支払日」に正規化する（ADR-006 規則1・KP-015）
  ///
  /// 固定費の設定画面は今日より前を選べないが、別導線で過去日が保存されても
  /// 周期展開が過去日の未生成分を作らないよう usecase 側でも防御する。
  /// 過去日でなければそのまま返す。
  FixedCostEntity _normalizeNextPaymentDate(
    FixedCostEntity entity,
    String today,
  ) {
    var currentEntity = entity;
    var cycleCount = 0;
    while ((currentEntity.nextPaymentDate ?? today).compareTo(today) < 0) {
      if (cycleCount >= _maxCatchUpCycles) {
        logger.e(
            '[FAIL]: 次回支払日の正規化が上限($_maxCatchUpCycles回)に達したため打ち切ります id=${entity.id}');
        break;
      }
      cycleCount++;
      final next = FixedCostService().populateNextPaymentEntity(currentEntity);
      if (next.nextPaymentDate == null ||
          next.nextPaymentDate!.compareTo(currentEntity.nextPaymentDate!) <=
              0) {
        // 日付が前進しない（周期が不正）場合は無限ループになるため打ち切る
        break;
      }
      // 正規化は「まだ支払っていない回を読み飛ばす」操作なので最近支払日は動かさない
      currentEntity = currentEntity.copyWith(
        nextPaymentDate: next.nextPaymentDate,
      );
    }
    return currentEntity;
  }

  // 変動固定費の想定支出を再計算し、未確定行の予想額まで同期する（仕様 §6.5）
  //
  // 推定額＝いま当該マスタに紐づく確定行（is_confirmed=1）のpriceの平均（現在状態主義）。
  // 再計算・マスタ更新・行同期はリポジトリ側で同一トランザクションにまとめる。
  // 確定行が0件のときは更新しない（最後の値を保持する）。
  Future<void> updateEstimatedPrice({required int fixedCostId}) async {
    // fixedCostEntityを取得
    final fixedCostEntity =
        await _fixedCostRepositoryProvider.fetch(fixedCostId: fixedCostId);

    if (fixedCostEntity.variable == 0) {
      // 変動費でない場合は何もしない
      return;
    }

    await _fixedCostRepositoryProvider.recalculateEstimatedPriceWithSync(
      fixedCostId: fixedCostId,
    );

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

    // カテゴリーが変わったら
    if (originalEntity.expenseSmallCategoryId !=
        editEntity.expenseSmallCategoryId) {
      // 過去の実績（expenseの固定費行）のカテゴリーを一括変更する
      await _fixedCostRecordServiceProvider.changeCategoryOfExistingRecord(
          originalEntity: originalEntity,
          expenseSmallCategoryId: editEntity.expenseSmallCategoryId);
    }

    // データを編集する（全てのフィールドを更新）
    final newEntity = originalEntity.copyWith(
      name: editEntity.name,
      price: editEntity.price,
      variable: editEntity.variable,
      estimatedPrice: editEntity.estimatedPrice,
      estimatedPriceIsManual: editEntity.estimatedPriceIsManual,
      expenseSmallCategoryId: editEntity.expenseSmallCategoryId,
      // 固定費の設定画面で変更できる周期・次回支払日も反映する
      // （以前は name/price/variable/estimatedPrice/カテゴリーしか引き継がれず保存されなかった）
      intervalNumber: editEntity.intervalNumber,
      intervalUnit: editEntity.intervalUnit,
      nextPaymentDate: editEntity.nextPaymentDate,
    );

    // 手動設定→自動算出へ戻したときは、確定行の平均で再計算し直す（仕様 §6.9）
    // フラグ更新・再計算・行同期を同一トランザクションで実行する
    final backToAuto = originalEntity.estimatedPriceIsManual == 1 &&
        newEntity.estimatedPriceIsManual == 0;
    if (backToAuto) {
      await _fixedCostRepositoryProvider
          .updateWithAutoEstimatedPriceSync(newEntity);
    } else {
      // マスタの金額・推定額を手動編集した場合に備え、
      // 未確定行の予想額の同期まで同一トランザクションで実行する（仕様 §6.5）
      await _fixedCostRepositoryProvider
          .updateWithUnconfirmedRowsSync(newEntity);
    }

    // 次回支払日の正規化と、今の集計期間内ぶんの実績の即時生成（ADR-006 規則1・3。KP-015）
    // 編集で次回支払日が期間内に入った場合、月次バッチは期間が変わるまで走らないため
    // ここで生成しないと日別支出・履歴に行が無い状態が翌月まで続く
    await _normalizeAndGenerateAfterEdit(newEntity);

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }

  /// 編集後のマスタについて、次回支払日を今日以降に正規化し、
  /// 今の集計期間内に支払日があれば実績を即時生成してマスタを更新する
  Future<void> _normalizeAndGenerateAfterEdit(FixedCostEntity entity) async {
    // 周期が不正・次回支払日が無いマスタは日付を前進できないため何もしない
    if ((entity.intervalUnit != 1 && entity.intervalUnit != 2) ||
        entity.intervalNumber <= 0 ||
        entity.nextPaymentDate == null ||
        entity.nextPaymentDate!.isEmpty ||
        entity.id == null) {
      return;
    }

    final today =
        DateFormat('yyyyMMdd').format(_ref.read(systemDatetimeNotifierProvider));
    final dateScope = await _ref
        .read(systemDateScopeEntityProvider.selectAsync((data) => data));
    final periodEndDate =
        DateFormat('yyyyMMdd').format(dateScope.aggregationMonthPeriod.endDatetime);

    // 保存直後のマスタをDBから読み直す。手動→自動へ戻した保存では
    // 予想額がDB側で再計算されており、編集エンティティの値は古いため
    final saved = await _fixedCostRepositoryProvider.fetch(
      fixedCostId: entity.id!,
    );

    final normalized = _normalizeNextPaymentDate(saved, today);
    final generated =
        await _generateRecordsThroughPeriodEnd(normalized, periodEndDate);

    // 日付が動いた場合だけマスタを保存し直す
    if (generated.nextPaymentDate != saved.nextPaymentDate) {
      await _fixedCostRepositoryProvider.update(generated);
    }
  }

  // マスタのレコードは削除せず、deleteFlagを1にする
  // あわせて未払いの実績を連動削除する（支払日が到来済みの記録は履歴として残す）
  // 未払い分を残すと、解約したのに支出に出続ける幽霊レコードになる（→ ADR-007）
  Future<void> delete({required int id}) async {
    // 運用日付（アプリ起動時点の日付）を基準に、支払日の到来を判定する
    final today =
        DateFormat('yyyyMMdd').format(_ref.read(systemDatetimeNotifierProvider));

    await _fixedCostRepositoryProvider.deleteWithUnpaidExpenses(
      id: id,
      today: today,
    );

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }
}
