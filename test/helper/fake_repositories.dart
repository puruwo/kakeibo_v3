// テスト用のFakeリポジトリ群
//
// 本物のリポジトリIFのProviderを ProviderContainer の overrides で
// 差し替えて使う（リポジトリIF側のコメント「テスト時に本プロバイダーを
// override して使用してください」に対応する実装）。
// テストで使うメソッドのみ実装し、未実装メソッドは noSuchMethod 経由で
// NoSuchMethodError になる（呼ばれた時点でテストが落ちるので検知できる）。
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_entity.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_repository.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/core/month_value/month_value.dart';
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
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';
import 'package:kakeibo/domain/db/month_basis_entity/month_basis_entity.dart';
import 'package:kakeibo/domain/db/month_basis_entity/month_basis_repository.dart';
import 'package:kakeibo/domain/db/year_basis_entity/year_basis_entity.dart';
import 'package:kakeibo/domain/db/year_basis_entity/year_basis_entity_repository.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_entity.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_repository.dart';
import 'package:kakeibo/util/extension/datetime_extension.dart';

/// 期間の開始日・終了日を 'yyyyMMdd' の文字列に直すヘルパー
///
/// 本物のリポジトリはSQLでこの形式の文字列比較をしているため、
/// Fake側のメモリ内フィルタも同じ比較になるようにそろえる。
bool _isDateInPeriod(String date, PeriodValue period) {
  final start = period.startDatetime.toFormattedString();
  final end = period.endDatetime.toFormattedString();
  return date.compareTo(start) >= 0 && date.compareTo(end) <= 0;
}

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
/// 「nextPaymentDateが期間内 かつ deleteFlag=0」のレコードを
/// id降順で返す（本実装のSQL条件・ORDER BY と同じ振る舞い）。
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
    final matched = records.where((e) {
      if (e.deleteFlag != 0) return false;
      final next = e.nextPaymentDate;
      if (next == null) return false;
      final nextDate = next.toDateTime();
      return !nextDate.isBefore(period.startDatetime) &&
          !nextDate.isAfter(period.endDatetime);
    }).toList();
    // 本実装のSQLの ORDER BY id DESC に合わせてid降順で返す
    matched.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    return matched;
  }

  @override
  Future<List<FixedCostEntity>> fetchAllActive() async {
    // 本実装のSQL条件（deleteFlag = 0）と ORDER BY id ASC に合わせる
    final matched = records.where((e) => e.deleteFlag == 0).toList();
    matched.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
    return matched;
  }

  @override
  Future<int> fetchEstimatedPriceById({required int id}) async {
    // 本実装は該当レコードが無いとき0を返すため、それに合わせる
    for (final record in records) {
      if (record.id == id) return record.estimatedPrice;
    }
    return 0;
  }

  @override
  Future<FixedCostEntity> fetch({required int fixedCostId}) async {
    // 本実装は該当レコードが無いとき例外ではなくid:0の既定エンティティを返すため、それに合わせる
    return records.firstWhere(
      (e) => e.id == fixedCostId,
      orElse: () => const FixedCostEntity(
        id: 0,
        name: '',
        variable: 0,
        price: 0,
        fixedCostCategoryId: 0,
        intervalNumber: 0,
        intervalUnit: 0,
        firstPaymentDate: '',
        recentPaymentDate: null,
        nextPaymentDate: null,
        deleteFlag: 0,
      ),
    );
  }

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

  /// fetchFixedCostExpenseWithCostId が参照する既存レコード（updateで置き換わる）
  final List<FixedCostExpenseEntity> records;

  /// insert / update で渡された内容の記録（検証用）
  final List<FixedCostExpenseEntity> insertedEntities = [];
  final List<FixedCostExpenseEntity> updatedEntities = [];

  /// fetchFixedCostEstimatedPriceById が返す過去支払いの平均額（テストで設定する）
  double estimatedPriceResult = 0;

  /// confirmExpense で渡された内容の記録（検証用）
  final List<({int id, int price})> confirmedExpenses = [];

  /// delete で渡されたidの記録（検証用）
  final List<int> deletedIds = [];

  @override
  Future<void> delete(int id) async {
    deletedIds.add(id);
    records.removeWhere((e) => e.id == id);
  }

  @override
  Future<int> insert(FixedCostExpenseEntity entity) async {
    insertedEntities.add(entity);
    return insertedEntities.length;
  }

  @override
  Future<List<FixedCostExpenseEntity>> fetchByPeriod({
    required PeriodValue period,
  }) async {
    final matched = records
        .where((e) => _isDateInPeriod(e.date, period))
        .toList();
    // 本実装のSQLの ORDER BY date DESC に合わせる（同日はid昇順で安定させる）
    matched.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });
    return matched;
  }

  @override
  Future<int> fetchTotalConfirmedFixedCostExpenseWithPeriod({
    required PeriodValue period,
  }) async {
    return records
        .where((e) => _isDateInPeriod(e.date, period) && e.isConfirmed == 1)
        .fold<int>(0, (sum, e) => sum + e.price);
  }

  @override
  Future<int> fetchTotalConfirmedFixedCostExpenseWithPeriodAndCategory({
    required PeriodValue period,
    required int fixedCostCategoryId,
  }) async {
    return records
        .where(
          (e) =>
              _isDateInPeriod(e.date, period) &&
              e.isConfirmed == 1 &&
              e.fixedCostCategoryId == fixedCostCategoryId,
        )
        .fold<int>(0, (sum, e) => sum + e.price);
  }

  @override
  Future<List<FixedCostExpenseEntity>>
  fetchUnconfirmedFixedCostExpenseWithPeriod({
    required PeriodValue period,
  }) async {
    return records
        .where((e) => _isDateInPeriod(e.date, period) && e.isConfirmed == 0)
        .toList();
  }

  @override
  Future<List<FixedCostExpenseEntity>>
  fetchUnconfirmedFixedCostExpenseWithPeriodAndCategory({
    required PeriodValue period,
    required int fixedCostCategoryId,
  }) async {
    return records
        .where(
          (e) =>
              _isDateInPeriod(e.date, period) &&
              e.isConfirmed == 0 &&
              e.fixedCostCategoryId == fixedCostCategoryId,
        )
        .toList();
  }

  @override
  Future<void> confirmExpense({required int id, required int price}) async {
    confirmedExpenses.add((id: id, price: price));
    final index = records.indexWhere((e) => e.id == id);
    if (index >= 0) {
      records[index] = records[index].copyWith(price: price, isConfirmed: 1);
    }
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
    final index = records.indexWhere((e) => e.id == entity.id);
    if (index >= 0) {
      records[index] = entity;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 支出のFake（書き込み系の呼び出し記録＋集計系の返却値設定）
class FakeExpenseRepository implements ExpenseRepository {
  final List<ExpenseEntity> insertedEntities = [];
  final List<ExpenseEntity> updatedEntities = [];
  final List<int> deletedIds = [];

  /// fetchTotalExpenseByPeriodWithBigCategory が返す合計額（テストで設定する）
  ///
  /// 本物は支出テーブルを期間と拠出元大カテゴリーで絞ってSUMするが、
  /// Fakeでは合計額そのものを設定する方式にしている。
  int totalExpenseByPeriodWithBigCategoryResult = 0;

  @override
  Future<int> fetchTotalExpenseByPeriodWithBigCategory({
    required int incomeSourceBigCategory,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    return totalExpenseByPeriodWithBigCategoryResult;
  }

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

/// 収入のFake（書き込み系の呼び出し記録＋メモリ内の集計）
class FakeIncomeRepository implements IncomeRepository {
  FakeIncomeRepository({
    List<IncomeEntity>? initialRecords,
    Map<int, int>? smallCategoryToBigCategory,
  }) : records = List.of(initialRecords ?? []),
       smallCategoryToBigCategory = Map.of(smallCategoryToBigCategory ?? {});

  /// 集計対象の収入レコード
  final List<IncomeEntity> records;

  /// 収入小カテゴリーID → 収入大カテゴリーID の対応
  ///
  /// 本物は income → income_small_category → income_big_category のJOINで
  /// 解決するが、Fakeではこのマップで代用する。
  final Map<int, int> smallCategoryToBigCategory;

  final List<IncomeEntity> insertedEntities = [];
  final List<IncomeEntity> updatedEntities = [];
  final List<int> deletedIds = [];

  @override
  Future<int> calcurateSumWithBigCategoryAndPeriod({
    required PeriodValue period,
    required int bigCategoryId,
  }) async {
    return records
        .where(
          (e) =>
              _isDateInPeriod(e.date, period) &&
              smallCategoryToBigCategory[e.categoryId] == bigCategoryId,
        )
        .fold<int>(0, (sum, e) => sum + e.price);
  }

  @override
  Future<int> calcurateSumWithSmallCategoryAndPeriod({
    required PeriodValue period,
    required int smallCategoryId,
  }) async {
    return records
        .where(
          (e) =>
              _isDateInPeriod(e.date, period) &&
              e.categoryId == smallCategoryId,
        )
        .fold<int>(0, (sum, e) => sum + e.price);
  }

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

/// 予算のFake（書き込み系の呼び出し記録＋メモリ内の検索）
class FakeBudgetRepository implements BudgetRepository {
  FakeBudgetRepository({List<BudgetEntity>? initialRecords})
    : records = List.of(initialRecords ?? []);

  /// 検索対象の予算レコード
  final List<BudgetEntity> records;

  final List<BudgetEntity> insertedEntities = [];
  final List<BudgetEntity> updatedEntities = [];
  final List<int> deletedIds = [];

  @override
  Future<int> fetchMonthly({required int id, required MonthValue month}) async {
    // 本実装は該当行が無いとき0を返す（ORDER BY id ASC の先頭を採用）
    final matched =
        records
            .where(
              (e) => e.month == month.month && e.expenseBigCategoryId == id,
            )
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id));
    return matched.isEmpty ? 0 : matched.first.price;
  }

  @override
  Future<int> fetchMonthlyAll({required MonthValue month}) async {
    // 本実装は月の全カテゴリー合計（該当なしは0）
    return records
        .where((e) => e.month == month.month)
        .fold<int>(0, (sum, e) => sum + e.price);
  }

  @override
  Future<BudgetEntity> fetchMonthlyByBigCategory({
    required MonthValue month,
    required int expenseBigCategoryId,
  }) async {
    // 本実装は同一カテゴリー内で最大idの行を採用し、該当なしは id:-1 / price:0 を返す
    final matched =
        records
            .where(
              (e) =>
                  e.month == month.month &&
                  e.expenseBigCategoryId == expenseBigCategoryId,
            )
            .toList()
          ..sort((a, b) => b.id.compareTo(a.id));
    if (matched.isEmpty) {
      return BudgetEntity(
        id: -1,
        expenseBigCategoryId: expenseBigCategoryId,
        month: month.month,
        price: 0,
      );
    }
    return matched.first;
  }

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

/// 固定費カテゴリーマスタのFake
///
/// [records] の並び順がそのまま fetchAll の順序になる
/// （本実装は ORDER BY id ASC のため、id昇順で積んでおく）。
class FakeFixedCostCategoryRepository implements FixedCostCategoryRepository {
  FakeFixedCostCategoryRepository({
    List<FixedCostCategoryEntity>? initialRecords,
  }) : records = List.of(initialRecords ?? []);

  /// 現在のカテゴリーマスタ（insert/update/deleteで変化する）
  final List<FixedCostCategoryEntity> records;

  /// insert / update / delete で渡された内容の記録（検証用）
  final List<FixedCostCategoryEntity> insertedEntities = [];
  final List<FixedCostCategoryEntity> updatedEntities = [];
  final List<int> deletedIds = [];

  int _nextId = 1000;

  @override
  Future<List<FixedCostCategoryEntity>> fetchAll() async => List.of(records);

  @override
  Future<FixedCostCategoryEntity> fetch({required int id}) async {
    // 本実装は該当レコードが無いと例外を投げるため、それに合わせる
    return records.firstWhere(
      (e) => e.id == id,
      orElse: () => throw Exception('FixedCostCategory not found with id: $id'),
    );
  }

  @override
  Future<int> getMaxDisplayOrder() async {
    // 本実装は1件も無いとき0を返す
    return records.fold<int>(
      0,
      (max, e) => e.displayOrder > max ? e.displayOrder : max,
    );
  }

  @override
  Future<int> insert(FixedCostCategoryEntity entity) async {
    final id = _nextId++;
    records.add(entity.copyWith(id: id));
    insertedEntities.add(entity);
    return id;
  }

  @override
  Future<void> update(FixedCostCategoryEntity entity) async {
    updatedEntities.add(entity);
    final index = records.indexWhere((e) => e.id == entity.id);
    if (index >= 0) {
      records[index] = entity;
    }
  }

  @override
  Future<void> delete(int id) async {
    deletedIds.add(id);
    records.removeWhere((e) => e.id == id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 大カテゴリー別の月次集計（支出カード用）のFake
///
/// 本物はSQLで支出テーブルを集計してエンティティを組み立てるため、
/// Fakeでは組み立て済みのエンティティを直接持たせる。
class FakeCategoryAccountingRepository implements CategoryAccountingRepository {
  FakeCategoryAccountingRepository({List<CategoryAccountingEntity>? categories})
    : categories = List.of(categories ?? []);

  /// 表示順に並んだ大カテゴリーのリスト
  final List<CategoryAccountingEntity> categories;

  @override
  Future<List<CategoryAccountingEntity>> fetchAll({
    required int incomeSourceBigCategoryId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    return List.of(categories);
  }

  @override
  Future<CategoryAccountingEntity> fetchSelectedCategory({
    required int incomeSourceBigCategoryId,
    required DateTime fromDate,
    required DateTime toDate,
    required int expenseBigCategoryId,
  }) async {
    return categories.firstWhere((e) => e.id == expenseBigCategoryId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// カード内の小カテゴリータイルのFake
///
/// 大カテゴリーIDごとに返すタイルのリストを設定する。
class FakeSmallCategoryTileRepository implements SmallCategoryTileRepository {
  FakeSmallCategoryTileRepository({
    Map<int, List<SmallCategoryTileEntity>>? tilesByBigCategoryId,
  }) : tilesByBigCategoryId = Map.of(tilesByBigCategoryId ?? {});

  /// 大カテゴリーID → そのカテゴリーの小カテゴリータイル
  final Map<int, List<SmallCategoryTileEntity>> tilesByBigCategoryId;

  @override
  Future<List<SmallCategoryTileEntity>> fetchAll({
    required int incomeSourceBigCategoryId,
    required int bigCategoryId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    return List.of(tilesByBigCategoryId[bigCategoryId] ?? []);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 収入小カテゴリーマスタのFake
class FakeIncomeSmallCategoryRepository
    implements IncomeSmallCategoryRepository {
  FakeIncomeSmallCategoryRepository({
    List<IncomeSmallCategoryEntity>? initialRecords,
  }) : records = List.of(initialRecords ?? []);

  /// 収入小カテゴリーマスタ
  final List<IncomeSmallCategoryEntity> records;

  @override
  Future<List<IncomeSmallCategoryEntity>> fetchAll() async => List.of(records);

  @override
  Future<IncomeSmallCategoryEntity> fetchBySmallCategory({
    required int smallCategoryId,
  }) async {
    return records.firstWhere((e) => e.id == smallCategoryId);
  }

  @override
  Future<List<IncomeSmallCategoryEntity>> fetchByBigCategory({
    required int bigCategoryId,
  }) async {
    return records.where((e) => e.bigCategoryKey == bigCategoryId).toList();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 収入大カテゴリーマスタのFake
class FakeIncomeBigCategoryRepository implements IncomeBigCategoryRepository {
  FakeIncomeBigCategoryRepository({
    List<IncomeBigCategoryEntity>? initialRecords,
  }) : records = List.of(initialRecords ?? []);

  /// 収入大カテゴリーマスタ
  final List<IncomeBigCategoryEntity> records;

  @override
  Future<List<IncomeBigCategoryEntity>> fetchAll() async => List.of(records);

  @override
  Future<IncomeBigCategoryEntity> fetchByBigCategory({
    required int bigCategoryId,
  }) async {
    return records.firstWhere((e) => e.id == bigCategoryId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
