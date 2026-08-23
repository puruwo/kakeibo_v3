import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_service.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/logger.dart';

/// 対象期間に発生する固定費の1回ぶん
///
/// 実績行が生成済みのものと、まだ生成されていない周期展開ぶんの
/// 両方を同じ型で表す（仕様 §7.3 の2段構え）。
class FixedCostOccurrence {
  const FixedCostOccurrence({
    required this.fixedCostId,
    required this.date,
    required this.amount,
    required this.expenseSmallCategoryId,
    required this.isGenerated,
    this.expenseId,
  });

  /// 固定費マスタのid
  final int fixedCostId;

  /// 支払日
  final DateTime date;

  /// 実効金額（生成済み＝COALESCE(price, estimated_price)／未生成＝マスタの金額）
  final int amount;

  /// 支出小カテゴリーid
  final int expenseSmallCategoryId;

  /// expenseに実績行が生成済みか
  final bool isGenerated;

  /// 生成済みの場合のexpense行のid
  final int? expenseId;
}

final fixedCostOccurrenceServiceProvider = Provider<FixedCostOccurrenceService>(
  FixedCostOccurrenceService.new,
);

/// 対象期間の固定費の発生を列挙するサービス
///
/// 固定費見込み（予算画面）と予測グラフの未来分が同じ算出を使うため、
/// 周期展開のロジックをここに集約する（仕様 §7.3・§7.4）。
class FixedCostOccurrenceService {
  FixedCostOccurrenceService(this._ref);

  final Ref _ref;

  /// 1マスタあたりに展開する周期の上限
  ///
  /// 支払い周期が不正なマスタで無限ループにならないようにするための保険。
  /// バッチ側（FixedCostUsecase）と同じ値。
  static const int _maxExpandCycles = 240;

  ExpenseRepository get _expenseRepository =>
      _ref.read(expenseRepositoryProvider);

  FixedCostRepository get _fixedCostRepository =>
      _ref.read(fixedCostRepositoryProvider);

  /// 対象期間に発生する固定費を列挙する
  ///
  /// 1. 対象期間に実績行（expense の fixed_cost_id IS NOT NULL）があるもの
  ///    → その行の実効金額をそのまま使う
  /// 2. まだ実績行が無いもの
  ///    → fixed_cost.next_payment_date を起点に周期展開し、対象期間に入る回を加える
  ///
  /// 「next_payment_date が対象期間内か」の単純判定は使わない。
  /// バッチは実績生成後に next_payment_date を次周期へ前進させるため、
  /// その判定だと当月分が常に0になる（仕様 §7.3）。
  Future<List<FixedCostOccurrence>> fetchOccurrences({
    required PeriodValue period,
  }) async {
    final result = <FixedCostOccurrence>[];

    // ---- 1段目: 生成済みの実績行 ----
    final generatedRows = await _expenseRepository.fetchFixedCostRecordByPeriod(
      period: period,
    );

    // 未生成分の判定に使う「マスタid + 支払日(yyyyMMdd)」の集合
    final generatedKeys = <String>{};

    for (final row in generatedRows) {
      final fixedCostId = row.fixedCostId;
      if (fixedCostId == null) continue;
      generatedKeys.add('$fixedCostId#${row.date}');
      result.add(
        FixedCostOccurrence(
          fixedCostId: fixedCostId,
          date: _parseDate(row.date),
          amount: row.effectivePrice,
          expenseSmallCategoryId: row.paymentCategoryId,
          isGenerated: true,
          expenseId: row.id,
        ),
      );
    }

    // ---- 2段目: 未生成分を周期展開 ----
    // 論理削除済みマスタ（delete_flag=1）は対象外
    final masters = await _fixedCostRepository.fetchAllActive();
    final startKey = DateFormat('yyyyMMdd').format(period.startDatetime);
    final endKey = DateFormat('yyyyMMdd').format(period.endDatetime);

    for (final master in masters) {
      final fixedCostId = master.id;
      if (fixedCostId == null) continue;

      // 支払い周期が不正なマスタは日付が前進せず展開できない
      if ((master.intervalUnit != 1 && master.intervalUnit != 2) ||
          master.intervalNumber <= 0) {
        logger.e(
          '[FAIL]: 固定費マスタの支払い周期が不正です id=$fixedCostId intervalUnit=${master.intervalUnit} intervalNumber=${master.intervalNumber}',
        );
        continue;
      }

      // 周期展開の起点。next_payment_date が未設定なら初回支払日を使う
      var paymentDate = master.nextPaymentDate?.isNotEmpty == true
          ? master.nextPaymentDate!
          : master.firstPaymentDate;
      if (paymentDate.isEmpty) continue;

      // 周期計算の起点を nextPaymentDate に揃える
      // （リポジトリは未設定を空文字で返すため、そのままだと日付計算に失敗する）
      var currentEntity = master.copyWith(nextPaymentDate: paymentDate);
      var cycleCount = 0;

      // 起点が期間開始日より前の場合（バッチ未実行で取り残されたマスタ）も
      // 期間に追いつくまで前進させる
      while (paymentDate.compareTo(endKey) <= 0) {
        if (cycleCount >= _maxExpandCycles) {
          logger.e(
            '[FAIL]: 固定費の周期展開が上限($_maxExpandCycles回)に達したため打ち切ります id=$fixedCostId',
          );
          break;
        }
        cycleCount++;

        // 期間内かつ実績行が未生成の回だけ見込みに加える
        if (paymentDate.compareTo(startKey) >= 0 &&
            !generatedKeys.contains('$fixedCostId#$paymentDate')) {
          result.add(
            FixedCostOccurrence(
              fixedCostId: fixedCostId,
              date: _parseDate(paymentDate),
              amount: _masterAmount(master),
              expenseSmallCategoryId: master.expenseSmallCategoryId,
              isGenerated: false,
            ),
          );
        }

        // 次の周期へ進める
        currentEntity = FixedCostService().populateNextPaymentEntity(
          currentEntity,
        );
        final next = currentEntity.nextPaymentDate;
        if (next == null || next.compareTo(paymentDate) <= 0) {
          // 日付が前進しない場合は無限ループになるため打ち切る
          break;
        }
        paymentDate = next;
      }
    }

    return result;
  }

  /// 未生成分に使うマスタ側の金額
  ///
  /// 確定型（variable=0）は price、変動型（variable=1）は estimated_price。
  int _masterAmount(FixedCostEntity master) =>
      master.variable == 1 ? master.estimatedPrice : master.price;

  /// `yyyyMMdd` を DateTime に変換する
  DateTime _parseDate(String yyyyMMdd) => DateTime(
        int.parse(yyyyMMdd.substring(0, 4)),
        int.parse(yyyyMMdd.substring(4, 6)),
        int.parse(yyyyMMdd.substring(6, 8)),
      );
}
