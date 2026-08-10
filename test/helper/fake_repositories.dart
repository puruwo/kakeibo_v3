// テスト用のFakeリポジトリ群
//
// 本物のリポジトリIFのProviderを ProviderContainer の overrides で
// 差し替えて使う（リポジトリIF側のコメント「テスト時に本プロバイダーを
// override して使用してください」に対応する実装）。
// テストで使うメソッドのみ実装し、未実装メソッドは noSuchMethod 経由で
// NoSuchMethodError になる（呼ばれた時点でテストが落ちるので検知できる）。
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/aggregation_start_day_entity/aggregation_start_day_entity.dart';
import 'package:kakeibo/domain/db/aggregation_start_day_entity/aggregation_start_day_repository.dart';
import 'package:kakeibo/domain/db/aggregation_start_month_entity/aggregation_start_month_entity.dart';
import 'package:kakeibo/domain/db/aggregation_start_month_entity/aggregation_start_month_repository.dart';
import 'package:kakeibo/domain/db/batch_history/batch_history_entity.dart';
import 'package:kakeibo/domain/db/batch_history/batch_history_repository.dart';
import 'package:kakeibo/domain/db/budget/budget_entity.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/db/month_basis_entity/month_basis_entity.dart';
import 'package:kakeibo/domain/db/month_basis_entity/month_basis_repository.dart';
import 'package:kakeibo/domain/db/year_basis_entity/year_basis_entity.dart';
import 'package:kakeibo/domain/db/year_basis_entity/year_basis_entity_repository.dart';
import 'package:kakeibo/util/extension/datetime_extension.dart';

/// 集計開始日を固定値で返すFake（既定は本番の初期設定と同じ25日）
class FakeAggregationStartDayRepository
    implements AggregationStartDayRepository {
  FakeAggregationStartDayRepository({this.day = 25});
  final int day;

  @override
  Future<AggregationStartDayEntity> fetch() async =>
      AggregationStartDayEntity(day: day);
}

/// 集計開始月を固定値で返すFake（既定は本番の初期設定と同じ4月）
class FakeAggregationStartMonthRepository
    implements AggregationStartMonthRepository {
  FakeAggregationStartMonthRepository({this.month = 4});
  final int month;

  @override
  Future<AggregationStartMonthEntity> fetch() async =>
      AggregationStartMonthEntity(month: month);
}

/// 代表月の基準（開始日側/終了日側）を固定値で返すFake（既定はstart）
class FakeMonthBasisRepository implements MonthBasisRepository {
  FakeMonthBasisRepository({this.basis = MonthBasis.start});
  final MonthBasis basis;

  @override
  Future<MonthBasisEntity> fetch() async => MonthBasisEntity(monthBasis: basis);
}

/// 代表年の基準（開始年側/終了年側）を固定値で返すFake（既定はstart）
class FakeYearBasisRepository implements YearBasisRepository {
  FakeYearBasisRepository({this.basis = YearBasis.start});
  final YearBasis basis;

  @override
  Future<YearBasisEntity> fetch() async => YearBasisEntity(monthBasis: basis);
}

/// バッチ履歴のFake
///
/// 挿入されたレコードをメモリに保持し、fetchLatestDate は
/// 「初期値」と「挿入済みレコードのendDate」のうち最大の値を返す
/// （実DBの fetchLatestDate 相当の振る舞い）。
class FakeBatchHistoryRepository implements BatchHistoryRepository {
  FakeBatchHistoryRepository({required String initialLatestDate})
    : _latestDate = initialLatestDate;

  String _latestDate;

  /// insertで渡されたエンティティの記録（検証用）
  final List<BatchHistoryEntity> insertedEntities = [];

  @override
  Future<String> fetchLatestDate() async => _latestDate;

  @override
  Future<int> insert(BatchHistoryEntity entity) async {
    insertedEntities.add(entity);
    if (entity.endDate.compareTo(_latestDate) > 0) {
      _latestDate = entity.endDate;
    }
    return insertedEntities.length;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 固定費マスタのFake
///
/// [records] に事前データを積んでおくと、fetchNextPeriodPayment が
/// 「nextPaymentDateが期間内 かつ deleteFlag=0」のレコードを返す
/// （本実装のSQL条件を模したもの）。
class FakeFixedCostRepository implements FixedCostRepository {
  FakeFixedCostRepository({List<FixedCostEntity>? initialRecords})
    : records = List.of(initialRecords ?? []);

  /// 現在のマスタ状態（insert/updateで変化する）
  final List<FixedCostEntity> records;

  /// insert / update / delete で渡された内容の記録（検証用）
  final List<FixedCostEntity> insertedEntities = [];
  final List<FixedCostEntity> updatedEntities = [];
  final List<int> deletedIds = [];

  int _nextId = 1000;

  @override
  Future<List<FixedCostEntity>> fetchNextPeriodPayment({
    required PeriodValue period,
  }) async {
    return records.where((e) {
      if (e.deleteFlag != 0) return false;
      final next = e.nextPaymentDate;
      if (next == null) return false;
      final nextDate = next.toDateTime();
      return !nextDate.isBefore(period.startDatetime) &&
          !nextDate.isAfter(period.endDatetime);
    }).toList();
  }

  @override
  Future<FixedCostEntity> fetch({required int fixedCostId}) async =>
      records.firstWhere((e) => e.id == fixedCostId);

  @override
  Future<int> insert(FixedCostEntity entity) async {
    final id = _nextId++;
    records.add(entity.copyWith(id: id));
    insertedEntities.add(entity);
    return id;
  }

  @override
  Future<void> update(FixedCostEntity entity) async {
    updatedEntities.add(entity);
    final index = records.indexWhere((e) => e.id == entity.id);
    if (index >= 0) {
      records[index] = entity;
    }
  }

  @override
  Future<void> delete(int id) async {
    deletedIds.add(id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 固定費支出（支払い実績）のFake
class FakeFixedCostExpenseRepository implements FixedCostExpenseRepository {
  FakeFixedCostExpenseRepository({List<FixedCostExpenseEntity>? initialRecords})
    : records = List.of(initialRecords ?? []);

  /// fetchFixedCostExpenseWithCostId が参照する既存レコード
  final List<FixedCostExpenseEntity> records;

  /// insert / update で渡された内容の記録（検証用）
  final List<FixedCostExpenseEntity> insertedEntities = [];
  final List<FixedCostExpenseEntity> updatedEntities = [];

  /// fetchFixedCostEstimatedPriceById が返す過去支払いの平均額（テストで設定する）
  double estimatedPriceResult = 0;

  @override
  Future<int> insert(FixedCostExpenseEntity entity) async {
    insertedEntities.add(entity);
    return insertedEntities.length;
  }

  @override
  Future<double> fetchFixedCostEstimatedPriceById({
    required int fixedCostId,
  }) async {
    return estimatedPriceResult;
  }

  @override
  Future<List<FixedCostExpenseEntity>> fetchFixedCostExpenseWithCostId({
    required int fixedCostId,
  }) async {
    return records.where((e) => e.fixedCostId == fixedCostId).toList();
  }

  @override
  Future<void> update(FixedCostExpenseEntity entity) async {
    updatedEntities.add(entity);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 支出のFake（書き込み系の呼び出し記録のみ）
class FakeExpenseRepository implements ExpenseRepository {
  final List<ExpenseEntity> insertedEntities = [];
  final List<ExpenseEntity> updatedEntities = [];
  final List<int> deletedIds = [];

  @override
  void insert(ExpenseEntity expenseEntity) {
    insertedEntities.add(expenseEntity);
  }

  @override
  void update(ExpenseEntity expenseEntity) {
    updatedEntities.add(expenseEntity);
  }

  @override
  void delete(int id) {
    deletedIds.add(id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 収入のFake（書き込み系の呼び出し記録のみ）
class FakeIncomeRepository implements IncomeRepository {
  final List<IncomeEntity> insertedEntities = [];
  final List<IncomeEntity> updatedEntities = [];
  final List<int> deletedIds = [];

  @override
  void insert(IncomeEntity expenseEntity) {
    insertedEntities.add(expenseEntity);
  }

  @override
  void update(IncomeEntity expenseEntity) {
    updatedEntities.add(expenseEntity);
  }

  @override
  void delete(int id) {
    deletedIds.add(id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 予算のFake（書き込み系の呼び出し記録のみ）
class FakeBudgetRepository implements BudgetRepository {
  final List<BudgetEntity> insertedEntities = [];
  final List<BudgetEntity> updatedEntities = [];
  final List<int> deletedIds = [];

  @override
  void insert(BudgetEntity expenseEntity) {
    insertedEntities.add(expenseEntity);
  }

  @override
  void update(BudgetEntity expenseEntity) {
    updatedEntities.add(expenseEntity);
  }

  @override
  void delete(int id) {
    deletedIds.add(id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
