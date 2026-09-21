import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_fixed_cost_tile_service.dart';
import 'package:kakeibo/application/fixed_cost_record/fixed_cost_record_usecase.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/domain_service/month_period_service/month_period_service.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/domain_service/unconfirmed_fixed_cost_prompt_rule/unconfirmed_fixed_cost_prompt_rule.dart';
import 'package:kakeibo/view/component/app_exception.dart';

final unconfirmedFixedCostPromptUsecaseProvider =
    Provider<UnconfirmedFixedCostPromptUsecase>(
      UnconfirmedFixedCostPromptUsecase.new,
    );

/// 未確定固定費の金額確定を促す機能のユースケース（KP-028）
///
/// 対象の判定は [UnconfirmedFixedCostPromptRule]（純粋関数）に置き、
/// ここは行の取得と一覧用Valueへの組み立てだけを受け持つ。
class UnconfirmedFixedCostPromptUsecase {
  UnconfirmedFixedCostPromptUsecase(this._ref);

  final Ref _ref;

  /// 過去の未確定行を取得するときの下限日（これより前の記録は存在しない前提）
  static final DateTime _oldestDate = DateTime(2000, 1, 1);

  ExpenseRepository get _expenseRepo => _ref.read(expenseRepositoryProvider);

  MonthlyFixedCostTileService get _tileService =>
      _ref.read(monthlyFixedCostTileServiceProvider);

  DateTime get _today => _ref.read(systemDatetimeNotifierProvider);

  /// 起動時の促しの対象（支払日が現在の月度より前の月度にある未確定行）
  ///
  /// 支払日の古い順。
  Future<List<MonthlyUnconfirmedFixedCostTileValue>>
  fetchLaunchPromptTargets() async {
    final currentPeriod = await _ref
        .read(monthPeriodServiceProvider)
        .fetchMonthPeriod(_today);

    // 現在の月度の開始日の前日までを取得範囲にする
    final start = currentPeriod.startDatetime;
    final rows = await _expenseRepo.fetchUnconfirmedFixedCostRecordByPeriod(
      period: PeriodValue(
        startDatetime: _oldestDate,
        endDatetime: DateTime(start.year, start.month, start.day - 1),
      ),
    );

    final targets = rows
        .where(
          (row) => UnconfirmedFixedCostPromptRule.isLaunchPromptTarget(
            paymentDate: _paymentDateOf(row),
            isConfirmed: row.isConfirmed == 1,
            currentPeriod: currentPeriod,
          ),
        )
        .toList();

    return _toTileValues(targets);
  }

  /// 月間分析の注意バナーの対象（[shownPeriod] に支払日があり、支払日から3日経過した未確定行）
  ///
  /// 支払日の古い順。
  Future<List<MonthlyUnconfirmedFixedCostTileValue>> fetchOverdueTargets({
    required PeriodValue shownPeriod,
  }) async {
    final rows = await _expenseRepo.fetchUnconfirmedFixedCostRecordByPeriod(
      period: shownPeriod,
    );

    final targets = rows
        .where(
          (row) => UnconfirmedFixedCostPromptRule.isOverdueTarget(
            paymentDate: _paymentDateOf(row),
            isConfirmed: row.isConfirmed == 1,
            today: _today,
            shownPeriod: shownPeriod,
          ),
        )
        .toList();

    return _toTileValues(targets);
  }

  /// 未確定行を予想額のまま確定する
  ///
  /// [estimatedPrice] は一覧に出した予想額（行の値が無ければマスタの推定額）。
  /// 行の estimated_price が空でも、画面に出した金額どおりに確定するため引数で受け取る。
  /// 通常の確定（編集シートの「金額を確定」）と同じ経路を通すため、
  /// 推定額の再計算と画面の再描画も同じように走る。
  Future<void> confirmWithEstimatedPrice({
    required int expenseId,
    required int estimatedPrice,
  }) async {
    final entity = await _expenseRepo.fetchById(id: expenseId);
    if (entity == null) {
      throw const AppException('対象の固定費が見つかりませんでした');
    }
    // すでに確定済みなら何もしない（一覧の再読込が間に合わず二重に押された場合）
    if (entity.isConfirmed == 1) return;

    await _ref
        .read(fixedCostRecordUsecaseProvider)
        .edit(entity: entity.copyWith(price: estimatedPrice));
  }

  /// 行を一覧用のValueへ組み立て、支払日の古い順（同日はid順）に並べる
  Future<List<MonthlyUnconfirmedFixedCostTileValue>> _toTileValues(
    List<ExpenseEntity> rows,
  ) async {
    final entries = await _tileService.buildEntries(rows: rows);
    final values = entries
        .map((entry) => entry.tile)
        .whereType<MonthlyUnconfirmedFixedCostTileValue>()
        .toList();
    values.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });
    return values;
  }

  /// expense.date（`yyyyMMdd`）を DateTime にする
  DateTime _paymentDateOf(ExpenseEntity row) => DateTime(
    int.parse(row.date.substring(0, 4)),
    int.parse(row.date.substring(4, 6)),
    int.parse(row.date.substring(6, 8)),
  );
}
