// テスト用のFakeリポジトリ群
//
// 本物のリポジトリIFのProviderを ProviderContainer の overrides で
// 差し替えて使う（リポジトリIF側のコメント「テスト時に本プロバイダーを
// override して使用してください」に対応する実装）。
// テストで使うメソッドのみ実装し、未実装メソッドは noSuchMethod 経由で
// NoSuchMethodError になる（呼ばれた時点でテストが落ちるので検知できる）。
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_entity.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_repository.dart';
import 'package:kakeibo/domain/core/daily_expense_entity/daily_expense_entity.dart';
import 'package:kakeibo/domain/core/daily_expense_entity/daily_expense_repository.dart';
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
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
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

/// 「期間別の返却値」を設定するMapのキーを作る
///
/// 年間グラフのように「12ヶ月それぞれ違う金額」を返させたいとき、
/// Fake側は期間開始日の 'yyyyMMdd' をキーにして返却値を引く。
/// テストからも同じ関数でキーを組み立てられるように公開している。
String periodKeyOf(DateTime periodStart) => periodStart.toFormattedString();

/// 「日付別の返却値」を設定するMapのキーを時刻なしDateTimeにそろえる
///
/// テストからは `DateTime(2025, 7, 1)` のように書くのが自然だが、
/// 呼び出し側が時刻付きのDateTimeを渡してくる可能性があるため、
/// Fake内部では常に年月日だけのDateTimeをキーにする。
Map<DateTime, T> _dateKeyedMap<T>(Map<DateTime, T>? source) {
  final result = <DateTime, T>{};
  source?.forEach((key, value) {
    result[DateTime(key.year, key.month, key.day)] = value;
  });
  return result;
}

/// 日付から時刻を落とす（Fake内部の日付キー用）
DateTime _dateKeyOf(DateTime date) => DateTime(date.year, date.month, date.day);

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
/// 「nextPaymentDateが期間終了日以前 かつ deleteFlag=0」のレコードを
/// id降順で返す（本実装のSQL条件・ORDER BY と同じ振る舞い）。
class FakeFixedCostRepository implements FixedCostRepository {
  FakeFixedCostRepository({List<FixedCostEntity>? initialRecords})
    : records = List.of(initialRecords ?? []);

  /// 現在のマスタ状態（insert/updateで変化する）
  final List<FixedCostEntity> records;

  /// insert / update で渡された内容の記録（検証用）
  final List<FixedCostEntity> insertedEntities = [];
  final List<FixedCostEntity> updatedEntities = [];

  int _nextId = 1000;

  /// fetchNextPeriodPayment で送出させたい例外（テストで設定する）
  ///
  /// 本実装はDB例外を握りつぶさず呼び出し元へ伝播させる。
  /// 空リストを返すと、バッチが「取得失敗」と「対象0件」を区別できず、
  /// SQLエラーでも成功として記録されてしまうため（→ ADR-007）。
  Object? fetchNextPeriodPaymentError;

  @override
  Future<List<FixedCostEntity>> fetchNextPeriodPayment({
    required PeriodValue period,
  }) async {
    if (fetchNextPeriodPaymentError != null) {
      throw fetchNextPeriodPaymentError!;
    }
    final matched = records.where((e) {
      if (e.deleteFlag != 0) return false;
      final next = e.nextPaymentDate;
      if (next == null) return false;
      // 本実装のSQLは期間開始日という下限を持たない
      // 過去のバッチで取りこぼしてnextPaymentDateが過去日のまま固定された
      // マスタも拾い、追いつかせるため（→ ADR-007）
      return !next.toDateTime().isAfter(period.endDatetime);
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

  /// deleteWithUnpaidExpenses で渡された内容の記録（検証用）
  final List<({int id, String today})> deletedWithUnpaidExpensesArgs = [];

  /// マスタの論理削除と未払い実績の削除（本実装は1トランザクション）
  ///
  /// Fakeは固定費支出を持たないため、ここではマスタ側の論理削除（deleteFlag=1）と
  /// 引数の記録だけを行う。実績側の削除条件
  /// （is_confirmed=0 または date > today）は本物のSQLでしか検証できないため、
  /// test/db_integration/repository/fixed_cost_repository_test.dart で検証する。
  @override
  Future<void> deleteWithUnpaidExpenses({
    required int id,
    required String today,
  }) async {
    deletedWithUnpaidExpensesArgs.add((id: id, today: today));
    final index = records.indexWhere((e) => e.id == id);
    if (index >= 0) {
      records[index] = records[index].copyWith(deleteFlag: 1);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 固定費支出（支払い実績）のFake
class FakeFixedCostExpenseRepository implements FixedCostExpenseRepository {
  FakeFixedCostExpenseRepository({List<FixedCostExpenseEntity>? initialRecords})
    : records = List.of(initialRecords ?? []);

  /// 取得系メソッドが参照する現在のレコード状態（insert/update/deleteで変化する）
  final List<FixedCostExpenseEntity> records;

  /// insert / update で渡された内容の記録（検証用）
  ///
  /// [records] と違い「呼び出し時に何を渡されたか」をそのまま保持する
  /// （insertのid採番前の値が入る）。
  final List<FixedCostExpenseEntity> insertedEntities = [];
  final List<FixedCostExpenseEntity> updatedEntities = [];

  /// 次に採番するid（本物のAUTOINCREMENT相当）
  ///
  /// 事前データ [records] の最大id+1から始め、deleteされても払い出し済みidは再利用しない。
  late int _nextId =
      records.fold<int>(0, (max, e) => e.id > max ? e.id : max) + 1;

  /// fetchFixedCostEstimatedPriceById が返す過去支払いの平均額（テストで設定する）
  double estimatedPriceResult = 0;

  /// confirmExpense で渡された内容の記録（検証用）
  final List<({int id, int price})> confirmedExpenses = [];

  /// delete で渡されたidの記録（検証用）
  final List<int> deletedIds = [];

  /// 期間別の確定固定費合計（キーは期間開始日のyyyyMMdd）
  ///
  /// キーが無い期間は、これまで通りメモリ内レコードからの集計になる。
  final Map<String, int> confirmedTotalByPeriodStart = {};

  /// 未確定固定費の推定額合計（既定は0）
  ///
  /// 本物は fixed_cost.estimated_price をJOINして合算するが、
  /// Fakeは固定費マスタを持たないため合計額そのものを設定する方式にしている。
  int unconfirmedEstimatedTotalResult = 0;

  /// 期間別の未確定固定費推定額合計（キーは期間開始日のyyyyMMdd）
  ///
  /// キーが無い期間は [unconfirmedEstimatedTotalResult] を返す。
  final Map<String, int> unconfirmedEstimatedTotalByPeriodStart = {};

  /// 合計取得メソッドに渡された期間の記録（検証用）
  final List<PeriodValue> confirmedTotalPeriods = [];
  final List<PeriodValue> unconfirmedEstimatedTotalPeriods = [];

  @override
  Future<void> delete(int id) async {
    deletedIds.add(id);
    records.removeWhere((e) => e.id == id);
  }

  /// 実績を1件挿入する
  ///
  /// 本物はINSERT直後からSELECTの対象になるため、Fakeも [records] へ反映して
  /// 以後の取得系メソッドから見えるようにする。idはAUTOINCREMENT相当で採番し、
  /// 戻り値は採番されたid（本実装と同じ）。
  @override
  Future<int> insert(FixedCostExpenseEntity entity) async {
    insertedEntities.add(entity);
    final id = _nextId++;
    records.add(entity.copyWith(id: id));
    return id;
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
    confirmedTotalPeriods.add(period);
    final byPeriod =
        confirmedTotalByPeriodStart[periodKeyOf(period.startDatetime)];
    if (byPeriod != null) return byPeriod;
    return records
        .where((e) => _isDateInPeriod(e.date, period) && e.isConfirmed == 1)
        .fold<int>(0, (sum, e) => sum + e.price);
  }

  @override
  Future<int> fetchTotalUnconfirmedFixedCostEstimatedWithPeriod({
    required PeriodValue period,
  }) async {
    unconfirmedEstimatedTotalPeriods.add(period);
    return unconfirmedEstimatedTotalByPeriodStart[periodKeyOf(
          period.startDatetime,
        )] ??
        unconfirmedEstimatedTotalResult;
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

  /// 固定費IDと支払い日が一致する実績が既にあるか
  ///
  /// 本実装は fixed_cost_expense を COUNT(*) するだけなので、
  /// 現在のレコード状態 [records] に一致行があるかで判定する
  /// （insert済みのものも [records] に入っているため既存として数えられる）。
  @override
  Future<bool> existsByFixedCostIdAndDate({
    required int fixedCostId,
    required String date,
  }) async {
    return records.any((e) => e.fixedCostId == fixedCostId && e.date == date);
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
  FakeExpenseRepository({
    List<ExpenseEntity>? initialRecords,
    Map<DateTime, int>? dailyExpenseTotalByDate,
    Map<DateTime, List<ExpenseEntity>>? dailyExpenseListByDate,
  }) : records = List.of(initialRecords ?? []),
       dailyExpenseTotalByDate = _dateKeyedMap(dailyExpenseTotalByDate),
       dailyExpenseListByDate = _dateKeyedMap(dailyExpenseListByDate);

  /// 検索対象の支出レコード（fetchWithSourceCategory が参照する。insert/update/deleteで変化する）
  final List<ExpenseEntity> records;

  /// 次に採番するid（本物のAUTOINCREMENT相当）
  late int _nextId =
      records.fold<int>(0, (max, e) => e.id > max ? e.id : max) + 1;

  /// 日付 → その日の一般支出合計（fetchDailyExpenseByPeriod の返却値）
  ///
  /// 本物は「その日・拠出元が給与」の支出をSUMするが、
  /// Fakeでは日付ごとの合計そのものを設定する方式にしている。
  /// 未設定の日付は0を返す（本実装の該当なし相当）。
  final Map<DateTime, int> dailyExpenseTotalByDate;

  /// 日付 → その日の一般支出リスト（fetchDailyExpenseListByDate の返却値）
  ///
  /// 未設定の日付は空リストを返す。
  final Map<DateTime, List<ExpenseEntity>> dailyExpenseListByDate;

  /// fetchDailyExpenseByPeriod に渡された日付の記録（検証用）
  final List<DateTime> dailyExpenseTotalDates = [];

  /// fetchDailyExpenseListByDate に渡された日付の記録（検証用）
  final List<DateTime> dailyExpenseListDates = [];

  final List<ExpenseEntity> insertedEntities = [];
  final List<ExpenseEntity> updatedEntities = [];
  final List<int> deletedIds = [];

  /// fetchTotalExpenseByPeriodWithBigCategory が返す合計額（テストで設定する）
  ///
  /// 本物は支出テーブルを期間と拠出元大カテゴリーで絞ってSUMするが、
  /// Fakeでは合計額そのものを設定する方式にしている。
  int totalExpenseByPeriodWithBigCategoryResult = 0;

  /// 期間別の合計額（キーは期間開始日のyyyyMMdd）
  ///
  /// キーが無い期間は [totalExpenseByPeriodWithBigCategoryResult] を返す。
  final Map<String, int>
  totalExpenseByPeriodWithBigCategoryResultByPeriodStart = {};

  /// fetchTotalExpenseByPeriod が返す合計額（拠出元の指定なし）
  int totalExpenseByPeriodResult = 0;

  /// 期間別の合計額（キーは期間開始日のyyyyMMdd）
  ///
  /// キーが無い期間は [totalExpenseByPeriodResult] を返す。
  final Map<String, int> totalExpenseByPeriodResultByPeriodStart = {};

  /// 合計取得メソッドに渡された期間の記録（検証用）
  final List<({DateTime fromDate, DateTime toDate})>
  totalExpenseByPeriodRanges = [];

  /// fetchWithSourceCategory に渡された条件の記録（検証用）
  final List<({int incomeSourceBigId, PeriodValue period})>
  fetchWithSourceCategoryCalls = [];

  /// fetchWithSmallCategory に渡された条件の記録（検証用）
  final List<({int incomeSourceBigId, PeriodValue period, int smallCategoryId})>
  fetchWithSmallCategoryCalls = [];

  /// fetchTotalExpenseByPeriodWithSmallCategoryAndSource に渡された条件の記録（検証用）
  final List<
    ({
      int incomeSourceBigCategory,
      int smallCategoryId,
      DateTime fromDate,
      DateTime toDate,
    })
  >
  totalExpenseWithSmallCategoryAndSourceCalls = [];

  @override
  Future<int> fetchTotalExpenseByPeriodWithBigCategory({
    required int incomeSourceBigCategory,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    return totalExpenseByPeriodWithBigCategoryResultByPeriodStart[periodKeyOf(
          fromDate,
        )] ??
        totalExpenseByPeriodWithBigCategoryResult;
  }

  @override
  Future<int> fetchTotalExpenseByPeriod({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    totalExpenseByPeriodRanges.add((fromDate: fromDate, toDate: toDate));
    return totalExpenseByPeriodResultByPeriodStart[periodKeyOf(fromDate)] ??
        totalExpenseByPeriodResult;
  }

  @override
  Future<List<ExpenseEntity>> fetchWithSourceCategory({
    required int incomeSourceBigId,
    required PeriodValue period,
  }) async {
    fetchWithSourceCategoryCalls.add((
      incomeSourceBigId: incomeSourceBigId,
      period: period,
    ));
    final matched = records
        .where(
          (e) =>
              _isDateInPeriod(e.date, period) &&
              e.incomeSourceBigCategory == incomeSourceBigId,
        )
        .toList();
    // 本実装のSQLの ORDER BY id DESC に合わせる
    matched.sort((a, b) => b.id.compareTo(a.id));
    return matched;
  }

  @override
  Future<List<ExpenseEntity>> fetchWithSmallCategory({
    required int incomeSourceBigId,
    required PeriodValue period,
    required int smallCategoryId,
  }) async {
    fetchWithSmallCategoryCalls.add((
      incomeSourceBigId: incomeSourceBigId,
      period: period,
      smallCategoryId: smallCategoryId,
    ));
    final matched = records
        .where(
          (e) =>
              _isDateInPeriod(e.date, period) &&
              e.incomeSourceBigCategory == incomeSourceBigId &&
              e.paymentCategoryId == smallCategoryId,
        )
        .toList();
    // 本実装のSQLの ORDER BY id DESC に合わせる
    matched.sort((a, b) => b.id.compareTo(a.id));
    return matched;
  }

  @override
  Future<int> fetchTotalExpenseByPeriodWithSmallCategoryAndSource({
    required int incomeSourceBigCategory,
    required int smallCategoryId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    totalExpenseWithSmallCategoryAndSourceCalls.add((
      incomeSourceBigCategory: incomeSourceBigCategory,
      smallCategoryId: smallCategoryId,
      fromDate: fromDate,
      toDate: toDate,
    ));
    final period = PeriodValue(startDatetime: fromDate, endDatetime: toDate);
    return records
        .where(
          (e) =>
              _isDateInPeriod(e.date, period) &&
              e.incomeSourceBigCategory == incomeSourceBigCategory &&
              e.paymentCategoryId == smallCategoryId,
        )
        .fold<int>(0, (sum, e) => sum + e.price);
  }

  @override
  Future<int> fetchDailyExpenseByPeriod({required DateTime date}) async {
    final key = _dateKeyOf(date);
    dailyExpenseTotalDates.add(key);
    return dailyExpenseTotalByDate[key] ?? 0;
  }

  @override
  Future<List<ExpenseEntity>> fetchDailyExpenseListByDate({
    required DateTime date,
  }) async {
    final key = _dateKeyOf(date);
    dailyExpenseListDates.add(key);
    return List.of(dailyExpenseListByDate[key] ?? const <ExpenseEntity>[]);
  }

  /// 支出を1件挿入する
  ///
  /// 本物はINSERT直後からSELECTの対象になるため、Fakeも [records] へ反映して
  /// 以後の取得系メソッドから見えるようにする（idはAUTOINCREMENT相当で採番）。
  /// [insertedEntities] には渡された内容そのものを記録する。
  @override
  void insert(ExpenseEntity expenseEntity) {
    insertedEntities.add(expenseEntity);
    records.add(expenseEntity.copyWith(id: _nextId++));
  }

  /// 支出を1件更新する
  ///
  /// 本物は `WHERE _id = ?` で該当行を UPDATE する（更新列はid以外の全カラム）ため、
  /// Fakeも同じidの行をエンティティごと差し替える。
  /// 該当行が無い場合は0行更新で例外を投げない実装なので、Fakeも何もしない。
  @override
  void update(ExpenseEntity expenseEntity) {
    updatedEntities.add(expenseEntity);
    final index = records.indexWhere((e) => e.id == expenseEntity.id);
    if (index >= 0) {
      records[index] = expenseEntity;
    }
  }

  /// 支出を1件削除する
  ///
  /// 本物は `DELETE FROM expense WHERE _id = ?` の物理削除で、直後のSELECTから
  /// 消えるため、Fakeも [records] から取り除く。
  @override
  void delete(int id) {
    deletedIds.add(id);
    records.removeWhere((e) => e.id == id);
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

  /// 集計対象の収入レコード（insertで増える）
  final List<IncomeEntity> records;

  /// 次に採番するid（本物のAUTOINCREMENT相当）
  late int _nextId =
      records.fold<int>(0, (max, e) => e.id > max ? e.id : max) + 1;

  /// 収入小カテゴリーID → 収入大カテゴリーID の対応
  ///
  /// 本物は income → income_small_category → income_big_category のJOINで
  /// 解決するが、Fakeではこのマップで代用する。
  final Map<int, int> smallCategoryToBigCategory;

  final List<IncomeEntity> insertedEntities = [];
  final List<IncomeEntity> updatedEntities = [];
  final List<int> deletedIds = [];

  /// 期間別の大カテゴリー収入合計（キーは期間開始日のyyyyMMdd）
  ///
  /// キーが無い期間は、これまで通りメモリ内レコードからの集計になる。
  final Map<String, int> sumWithBigCategoryAndPeriodResultByPeriodStart = {};

  /// 期間別の収入合計（キーは期間開始日のyyyyMMdd・カテゴリー指定なし）
  ///
  /// キーが無い期間は、これまで通りメモリ内レコードからの集計になる。
  final Map<String, int> sumWithPeriodResultByPeriodStart = {};

  /// calcurateSumWithPeriod に渡された期間の記録（検証用）
  final List<PeriodValue> sumWithPeriodPeriods = [];

  /// fetchWithCategoryAndPeriod に渡された条件の記録（検証用）
  final List<({int categoryId, PeriodValue period})>
  fetchWithCategoryAndPeriodCalls = [];

  @override
  Future<List<IncomeEntity>> fetchAll() async {
    // 本実装のSQLの ORDER BY id ASC に合わせる
    final all = List.of(records);
    all.sort((a, b) => a.id.compareTo(b.id));
    return all;
  }

  @override
  Future<int> calcurateSumWithBigCategoryAndPeriod({
    required PeriodValue period,
    required int bigCategoryId,
  }) async {
    final byPeriod =
        sumWithBigCategoryAndPeriodResultByPeriodStart[periodKeyOf(
          period.startDatetime,
        )];
    if (byPeriod != null) return byPeriod;
    return records
        .where(
          (e) =>
              _isDateInPeriod(e.date, period) &&
              smallCategoryToBigCategory[e.categoryId] == bigCategoryId,
        )
        .fold<int>(0, (sum, e) => sum + e.price);
  }

  @override
  Future<int> calcurateSumWithPeriod({required PeriodValue period}) async {
    sumWithPeriodPeriods.add(period);
    final byPeriod =
        sumWithPeriodResultByPeriodStart[periodKeyOf(period.startDatetime)];
    if (byPeriod != null) return byPeriod;
    return records
        .where((e) => _isDateInPeriod(e.date, period))
        .fold<int>(0, (sum, e) => sum + e.price);
  }

  @override
  Future<List<IncomeEntity>> fetchWithCategoryAndPeriod({
    required PeriodValue period,
    required int categoryId,
  }) async {
    fetchWithCategoryAndPeriodCalls.add((
      categoryId: categoryId,
      period: period,
    ));
    // 本実装は income → 小カテゴリー → 大カテゴリー のJOINで
    // 「大カテゴリーID = categoryId」を条件にしている
    return records
        .where(
          (e) =>
              _isDateInPeriod(e.date, period) &&
              smallCategoryToBigCategory[e.categoryId] == categoryId,
        )
        .toList();
  }

  @override
  Future<List<IncomeEntity>> fetchWithoutCategory({
    required PeriodValue period,
  }) async {
    return records.where((e) => _isDateInPeriod(e.date, period)).toList();
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

  /// 収入を1件挿入する
  ///
  /// 本物はINSERT直後からSELECTの対象になるため、Fakeも [records] へ反映する
  /// （idはAUTOINCREMENT相当で採番。[insertedEntities] は渡された内容そのもの）。
  @override
  void insert(IncomeEntity expenseEntity) {
    insertedEntities.add(expenseEntity);
    records.add(expenseEntity.copyWith(id: _nextId++));
  }

  /// 収入を1件更新する
  ///
  /// 本物は `WHERE _id = ?` で該当行を UPDATE する（更新列はid以外の全カラム）ため、
  /// Fakeも同じidの行をエンティティごと差し替える。
  /// 該当行が無い場合は0行更新で例外を投げない実装なので、Fakeも何もしない。
  @override
  void update(IncomeEntity expenseEntity) {
    updatedEntities.add(expenseEntity);
    final index = records.indexWhere((e) => e.id == expenseEntity.id);
    if (index >= 0) {
      records[index] = expenseEntity;
    }
  }

  /// 収入を1件削除する
  ///
  /// 本物は `DELETE FROM income WHERE _id = ?` の物理削除のため、
  /// Fakeも [records] から取り除く。
  @override
  void delete(int id) {
    deletedIds.add(id);
    records.removeWhere((e) => e.id == id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 予算のFake（書き込み系の呼び出し記録＋メモリ内の検索）
class FakeBudgetRepository implements BudgetRepository {
  FakeBudgetRepository({List<BudgetEntity>? initialRecords})
    : records = List.of(initialRecords ?? []);

  /// 検索対象の予算レコード（insertで増える）
  final List<BudgetEntity> records;

  /// 次に採番するid（本物のAUTOINCREMENT相当）
  late int _nextId =
      records.fold<int>(0, (max, e) => e.id > max ? e.id : max) + 1;

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

  /// 予算を1件挿入する
  ///
  /// 本物はINSERT直後からSELECTの対象になるため、Fakeも [records] へ反映する
  /// （idはAUTOINCREMENT相当で採番。[insertedEntities] は渡された内容そのもの）。
  @override
  void insert(BudgetEntity expenseEntity) {
    insertedEntities.add(expenseEntity);
    records.add(expenseEntity.copyWith(id: _nextId++));
  }

  /// 予算を1件更新する
  ///
  /// 本物は `WHERE _id = ?` で該当行を UPDATE する（更新列はid以外の全カラム）ため、
  /// Fakeも同じidの行をエンティティごと差し替える。
  /// 該当行が無い場合は0行更新で例外を投げない実装なので、Fakeも何もしない。
  @override
  void update(BudgetEntity expenseEntity) {
    updatedEntities.add(expenseEntity);
    final index = records.indexWhere((e) => e.id == expenseEntity.id);
    if (index >= 0) {
      records[index] = expenseEntity;
    }
  }

  /// 予算を1件削除する
  ///
  /// 本物は `DELETE FROM budget WHERE _id = ?` の物理削除のため、
  /// Fakeも [records] から取り除く。
  @override
  void delete(int id) {
    deletedIds.add(id);
    records.removeWhere((e) => e.id == id);
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

  /// add / update で渡された内容の記録（検証用）
  final List<IncomeSmallCategoryEntity> addedEntities = [];
  final List<IncomeSmallCategoryEntity> updatedEntities = [];

  /// delete / deleteByBigCategory で渡されたidの記録（検証用）
  final List<int> deletedIds = [];
  final List<int> deletedBigCategoryIds = [];

  /// getMaxSmallCategoryOrderKey に渡された大カテゴリーIDの記録（検証用）
  final List<int> getMaxOrderKeyBigCategoryIds = [];

  int _nextId = 1000;

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
  Future<List<int>> fetchSmallCategoryIdListByBigCategoryId({
    required int bigCategoryId,
  }) async {
    return records
        .where((e) => e.bigCategoryKey == bigCategoryId)
        .map((e) => e.id)
        .toList();
  }

  @override
  Future<int> getMaxSmallCategoryOrderKey({required int bigCategoryId}) async {
    getMaxOrderKeyBigCategoryIds.add(bigCategoryId);
    // 本実装は大カテゴリーで絞らず全件の最大値を返す（1件も無いときは0）
    return records.fold<int>(
      0,
      (max, e) => e.smallCategoryOrderKey > max ? e.smallCategoryOrderKey : max,
    );
  }

  @override
  Future<int> add({required IncomeSmallCategoryEntity entity}) async {
    final id = _nextId++;
    records.add(entity.copyWith(id: id));
    addedEntities.add(entity);
    return id;
  }

  @override
  Future<void> update({required IncomeSmallCategoryEntity entity}) async {
    updatedEntities.add(entity);
    final index = records.indexWhere((e) => e.id == entity.id);
    if (index >= 0) {
      records[index] = entity;
    }
  }

  @override
  Future<void> delete({required int id}) async {
    deletedIds.add(id);
    records.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<int>> deleteByBigCategory({required int bigCategoryId}) async {
    deletedBigCategoryIds.add(bigCategoryId);
    // 本実装は削除した小カテゴリーIDのリストを返す
    final ids = records
        .where((e) => e.bigCategoryKey == bigCategoryId)
        .map((e) => e.id)
        .toList();
    records.removeWhere((e) => e.bigCategoryKey == bigCategoryId);
    return ids;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 1日分の支出・収入サマリーのFake
///
/// 本物はSQLで日毎に集計するため、Fakeでは日付ごとの結果を直接持たせる。
/// 未設定の日付は「合計0」のエンティティを返す（本実装の該当なし相当）。
class FakeDailyExpenseRepository implements DailyExpenseRepository {
  FakeDailyExpenseRepository({Map<DateTime, DailyExpenseEntity>? dailyExpenses})
    : dailyExpenses = Map.of(dailyExpenses ?? {});

  /// 日付（時刻を持たないDateTime）→ その日の集計結果
  final Map<DateTime, DailyExpenseEntity> dailyExpenses;

  /// fetchWithCategory に渡された日付の記録（検証用）
  final List<DateTime> fetchedDates = [];

  @override
  Future<DailyExpenseEntity> fetchWithCategory({
    required int incomeSourceBigId,
    required DateTime dateTime,
  }) async {
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    fetchedDates.add(date);
    return dailyExpenses[date] ?? DailyExpenseEntity(date: date);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 支出小カテゴリーマスタのFake
///
/// [records] の並び順がそのまま fetchAll の順序になる。
class FakeExpenseSmallCategoryRepository
    implements ExpenseSmallCategoryRepository {
  FakeExpenseSmallCategoryRepository({
    List<ExpenseSmallCategoryEntity>? initialRecords,
  }) : records = List.of(initialRecords ?? []);

  /// 支出小カテゴリーマスタ
  final List<ExpenseSmallCategoryEntity> records;

  /// update / add で渡された内容の記録（検証用）
  final List<ExpenseSmallCategoryEntity> updatedEntities = [];
  final List<ExpenseSmallCategoryEntity> addedEntities = [];

  /// 次に採番するid（本物のAUTOINCREMENT相当）
  int _nextId = 1000;

  /// getMaxSmallCategoryOrderKey に渡された大カテゴリーIDの記録（検証用）
  final List<int> getMaxOrderKeyBigCategoryIds = [];

  @override
  Future<List<ExpenseSmallCategoryEntity>> fetchAll() async => List.of(records);

  @override
  Future<ExpenseSmallCategoryEntity> fetchBySmallCategory({
    required int smallCategoryId,
  }) async {
    return records.firstWhere((e) => e.id == smallCategoryId);
  }

  @override
  Future<List<ExpenseSmallCategoryEntity>> fetchByBigCategory({
    required int bigCategoryId,
  }) async {
    return records.where((e) => e.bigCategoryKey == bigCategoryId).toList();
  }

  @override
  Future<List<int>> fetchSmallCategoryIdListByBigCategoryId({
    required int bigCategoryId,
  }) async {
    return records
        .where((e) => e.bigCategoryKey == bigCategoryId)
        .map((e) => e.id)
        .toList();
  }

  @override
  Future<int> getMaxSmallCategoryOrderKey({required int bigCategoryId}) async {
    getMaxOrderKeyBigCategoryIds.add(bigCategoryId);
    // 本実装は大カテゴリーで絞らず全件の最大値を返す（1件も無いときは0）
    return records.fold<int>(
      0,
      (max, e) => e.smallCategoryOrderKey > max ? e.smallCategoryOrderKey : max,
    );
  }

  @override
  Future<void> update({required ExpenseSmallCategoryEntity entity}) async {
    updatedEntities.add(entity);
    final index = records.indexWhere((e) => e.id == entity.id);
    if (index >= 0) {
      records[index] = entity;
    }
  }

  /// 小カテゴリーを1件追加する
  ///
  /// 本物はAUTOINCREMENTでidが採番され、戻り値はそのidになる。
  /// [addedEntities] には渡された内容そのもの（採番前）を記録する。
  @override
  Future<int> add({required ExpenseSmallCategoryEntity entity}) async {
    addedEntities.add(entity);
    final id = _nextId++;
    records.add(entity.copyWith(id: id));
    return id;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 支出大カテゴリーマスタのFake
///
/// [records] の並び順がそのまま fetchAll の順序になる。
class FakeExpenseBigCategoryRepository implements ExpenseBigCategoryRepository {
  FakeExpenseBigCategoryRepository({
    List<ExpenseBigCategoryEntity>? initialRecords,
  }) : records = List.of(initialRecords ?? []);

  /// 支出大カテゴリーマスタ
  final List<ExpenseBigCategoryEntity> records;

  /// update / add で渡された内容の記録（検証用）
  final List<ExpenseBigCategoryEntity> updatedEntities = [];
  final List<ExpenseBigCategoryEntity> addedEntities = [];

  int _nextId = 1000;

  @override
  Future<List<ExpenseBigCategoryEntity>> fetchAll() async => List.of(records);

  @override
  Future<ExpenseBigCategoryEntity> fetchByBigCategory({
    required int bigCategoryId,
  }) async {
    return records.firstWhere((e) => e.id == bigCategoryId);
  }

  @override
  Future<void> update({required ExpenseBigCategoryEntity entity}) async {
    updatedEntities.add(entity);
    final index = records.indexWhere((e) => e.id == entity.id);
    if (index >= 0) {
      records[index] = entity;
    }
  }

  @override
  Future<int> add({required ExpenseBigCategoryEntity entity}) async {
    final id = _nextId++;
    records.add(entity.copyWith(id: id));
    addedEntities.add(entity);
    return id;
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

  /// add / update で渡された内容の記録（検証用）
  final List<IncomeBigCategoryEntity> addedEntities = [];
  final List<IncomeBigCategoryEntity> updatedEntities = [];

  /// delete で渡されたidの記録（検証用）
  final List<int> deletedIds = [];

  int _nextId = 1000;

  @override
  Future<List<IncomeBigCategoryEntity>> fetchAll() async => List.of(records);

  @override
  Future<IncomeBigCategoryEntity> fetchByBigCategory({
    required int bigCategoryId,
  }) async {
    return records.firstWhere((e) => e.id == bigCategoryId);
  }

  @override
  Future<int> add({required IncomeBigCategoryEntity entity}) async {
    final id = _nextId++;
    records.add(entity.copyWith(id: id));
    addedEntities.add(entity);
    return id;
  }

  @override
  Future<void> update({required IncomeBigCategoryEntity entity}) async {
    updatedEntities.add(entity);
    final index = records.indexWhere((e) => e.id == entity.id);
    if (index >= 0) {
      records[index] = entity;
    }
  }

  @override
  Future<void> delete({required int id}) async {
    // 本実装は id=1（月次収入）/ id=2（ボーナス）を削除させないため、それに合わせる
    if (id == 1 || id == 2) {
      throw StateError('id=1（月次収入）/ id=2（ボーナス）は削除できません');
    }
    deletedIds.add(id);
    records.removeWhere((e) => e.id == id);
  }

  @override
  Future<int> getMaxId() async {
    // 本実装は1件も無いとき0を返す
    return records.fold<int>(0, (max, e) => e.id > max ? e.id : max);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
