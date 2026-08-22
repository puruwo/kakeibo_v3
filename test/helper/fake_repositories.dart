// テスト用のFakeリポジトリ群
//
// 本物のリポジトリIFのProviderを ProviderContainer の overrides で
// 差し替えて使う（リポジトリIF側のコメント「テスト時に本プロバイダーを
// override して使用してください」に対応する実装）。
// テストで使うメソッドのみ実装し、未実装メソッドは noSuchMethod 経由で
// NoSuchMethodError になる（呼ばれた時点でテストが落ちるので検知できる）。
import 'package:kakeibo/constant/sqf_constants.dart';
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
  FakeFixedCostRepository({
    List<FixedCostEntity>? initialRecords,
    this.expenseRepository,
  }) : records = List.of(initialRecords ?? []);

  /// 現在のマスタ状態（insert/updateで変化する）
  final List<FixedCostEntity> records;

  /// 連動する支出のFake（省略可）
  ///
  /// 本物は「マスタ更新＋expenseの固定費行の更新／削除」を1トランザクションで
  /// 実行する（deleteWithUnpaidExpenses・推定額の同期。仕様 §6.4・§6.5）。
  /// Fakeは別インスタンスなので、実績側にも効かせたいテストではここに
  /// [FakeExpenseRepository] を渡す。未指定のときは実績が0件のDBと同じ挙動になる。
  /// 生成順の都合で後から差し込めるよう、finalにしていない。
  FakeExpenseRepository? expenseRepository;

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
  /// マスタ側は論理削除（deleteFlag=1）。実績側は [expenseRepository] を
  /// 渡した場合のみ、本実装と同じ条件
  /// （fixed_cost_id 一致 かつ is_confirmed=0 または date > today）で削除する。
  /// SQLそのものの検証は
  /// test/db_integration/repository/fixed_cost_repository_test.dart で行う。
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
    await expenseRepository?.deleteUnpaidFixedCostExpenses(
      fixedCostId: id,
      today: today,
    );
  }

  /// 推定額の再計算・マスタ更新・未確定行の同期（本実装は1トランザクション）
  ///
  /// 確定行の平均は [expenseRepository] から取得する。
  /// 確定行が0件（＝平均がnull）のときは何も更新しない（仕様 §6.5）。
  @override
  Future<void> recalculateEstimatedPriceWithSync({
    required int fixedCostId,
  }) async {
    final average = await expenseRepository?.fetchConfirmedFixedCostPriceAverage(
      fixedCostId: fixedCostId,
    );
    if (average == null) return;

    final estimatedPrice = average.toInt();
    final index = records.indexWhere((e) => e.id == fixedCostId);
    if (index >= 0) {
      final updated = records[index].copyWith(estimatedPrice: estimatedPrice);
      records[index] = updated;
      updatedEntities.add(updated);
    }
    await expenseRepository?.updateEstimatedPriceOfUnconfirmedRows(
      fixedCostId: fixedCostId,
      estimatedPrice: estimatedPrice,
    );
  }

  /// マスタ更新と未確定行の予想額の同期（本実装は1トランザクション）
  @override
  Future<void> updateWithUnconfirmedRowsSync(FixedCostEntity entity) async {
    await update(entity);
    await expenseRepository?.updateEstimatedPriceOfUnconfirmedRows(
      fixedCostId: entity.id ?? -1,
      estimatedPrice: entity.estimatedPrice,
    );
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
        .fold<int>(0, (sum, e) => sum + e.effectivePrice);
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
  Future<void> update(ExpenseEntity expenseEntity) async {
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

  // -------------------------------------------------------------------------
  // 固定費系のクエリ（v10で fixed_cost_expense から移管）
  //
  // 固定費行の判定は fixedCostId != null の1条件（本実装の
  // fixed_cost_id IS NOT NULL と同じ）。書き込みは本物と同様 [records] に
  // 反映し、以後の取得系から見えるようにする。
  // -------------------------------------------------------------------------

  /// insertFixedCostExpense で渡された内容の記録（検証用）
  final List<ExpenseEntity> insertedFixedCostExpenses = [];

  /// confirmFixedCostExpense で渡された内容の記録（検証用）
  final List<({int id, int price})> confirmedExpenses = [];

  /// updateEstimatedPriceOfUnconfirmedRows で渡された内容の記録（検証用）
  final List<({int fixedCostId, int estimatedPrice})> syncedEstimatedPrices =
      [];

  /// deleteUnpaidFixedCostExpenses で渡された内容の記録（検証用）
  final List<({int fixedCostId, String today})> deletedUnpaidArgs = [];

  /// updateSmallCategoryByFixedCostId で渡された内容の記録（検証用）
  final List<({int fixedCostId, int expenseSmallCategoryId})>
  changedCategoryArgs = [];

  @override
  Future<ExpenseEntity?> fetchById({required int id}) async {
    for (final record in records) {
      if (record.id == id) return record;
    }
    return null;
  }

  /// 固定費の実績行を1件挿入する
  ///
  /// 本物はINSERT直後からSELECTの対象になるため [records] にも反映する。
  /// 戻り値は採番されたid（本実装と同じ）。
  @override
  Future<int> insertFixedCostExpense(ExpenseEntity expenseEntity) async {
    insertedFixedCostExpenses.add(expenseEntity);
    insertedEntities.add(expenseEntity);
    final id = _nextId++;
    records.add(expenseEntity.copyWith(id: id));
    return id;
  }

  /// 固定費IDと支払い日が一致する行が既にあるか
  ///
  /// 本実装は COUNT(*) するだけなので、現在のレコード状態で判定する
  /// （insert済みのものも [records] に入っているため既存として数えられる）。
  @override
  Future<bool> existsByFixedCostIdAndDate({
    required int fixedCostId,
    required String date,
  }) async {
    return records.any((e) => e.fixedCostId == fixedCostId && e.date == date);
  }

  /// 期間内の固定費行（確定・未確定を問わない）
  ///
  /// 本実装のSQLは `fixed_cost_id IS NOT NULL` で絞り、
  /// ORDER BY date ASC, _id ASC で返す。Fakeも同じ条件・同じ順序にする。
  @override
  Future<List<ExpenseEntity>> fetchFixedCostExpenseByPeriod({
    required PeriodValue period,
  }) async {
    final matched = records
        .where((e) => _isDateInPeriod(e.date, period) && e.fixedCostId != null)
        .toList();
    matched.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });
    return matched;
  }

  @override
  Future<List<ExpenseEntity>> fetchUnconfirmedFixedCostExpenseByPeriod({
    required PeriodValue period,
  }) async {
    final matched = records
        .where(
          (e) =>
              _isDateInPeriod(e.date, period) &&
              e.fixedCostId != null &&
              e.isConfirmed == 0,
        )
        .toList();
    // 本実装のSQLの ORDER BY date DESC に合わせる（同日はid昇順で安定させる）
    matched.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });
    return matched;
  }

  /// 未確定行を確定させる（price設定＋is_confirmed=1）
  ///
  /// 本実装は estimated_price を触らないため、Fakeも据え置く（仕様 §3）。
  @override
  Future<void> confirmFixedCostExpense({
    required int id,
    required int price,
  }) async {
    confirmedExpenses.add((id: id, price: price));
    final index = records.indexWhere((e) => e.id == id);
    if (index >= 0) {
      records[index] = records[index].copyWith(price: price, isConfirmed: 1);
    }
  }

  /// 確定済み固定費行のpriceの平均（対象0件はnull）
  ///
  /// 本実装は AVG(price) で、対象0件のときNULLが返る。
  /// price IS NOT NULL の条件も本実装に合わせる。
  @override
  Future<double?> fetchConfirmedFixedCostPriceAverage({
    required int fixedCostId,
  }) async {
    final prices = records
        .where(
          (e) =>
              e.fixedCostId == fixedCostId &&
              e.isConfirmed == 1 &&
              e.price != null,
        )
        .map((e) => e.price!)
        .toList();
    if (prices.isEmpty) return null;
    return prices.fold<int>(0, (sum, p) => sum + p) / prices.length;
  }

  @override
  Future<void> updateEstimatedPriceOfUnconfirmedRows({
    required int fixedCostId,
    required int estimatedPrice,
  }) async {
    syncedEstimatedPrices.add((
      fixedCostId: fixedCostId,
      estimatedPrice: estimatedPrice,
    ));
    for (var i = 0; i < records.length; i++) {
      final record = records[i];
      if (record.fixedCostId == fixedCostId && record.isConfirmed == 0) {
        records[i] = record.copyWith(estimatedPrice: estimatedPrice);
      }
    }
  }

  /// 未払い固定費行の一括削除
  ///
  /// 本実装の条件 `fixed_cost_id = ? AND (is_confirmed = 0 OR date > ?)` を模す。
  /// 日付は同形式のyyyyMMdd文字列なので辞書順比較で大小判定できる。
  @override
  Future<void> deleteUnpaidFixedCostExpenses({
    required int fixedCostId,
    required String today,
  }) async {
    deletedUnpaidArgs.add((fixedCostId: fixedCostId, today: today));
    records.removeWhere(
      (e) =>
          e.fixedCostId == fixedCostId &&
          (e.isConfirmed == 0 || e.date.compareTo(today) > 0),
    );
  }

  @override
  Future<void> updateSmallCategoryByFixedCostId({
    required int fixedCostId,
    required int expenseSmallCategoryId,
  }) async {
    changedCategoryArgs.add((
      fixedCostId: fixedCostId,
      expenseSmallCategoryId: expenseSmallCategoryId,
    ));
    for (var i = 0; i < records.length; i++) {
      final record = records[i];
      if (record.fixedCostId == fixedCostId) {
        records[i] = record.copyWith(
          paymentCategoryId: expenseSmallCategoryId,
        );
      }
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 収入のFake（書き込み系の呼び出し記録＋メモリ内の集計）
class FakeIncomeRepository implements IncomeRepository {
  FakeIncomeRepository({
    List<IncomeEntity>? initialRecords,
    Map<int, int>? smallCategoryToBigCategory,
    Map<int, int>? bigCategoryToAccountType,
  }) : records = List.of(initialRecords ?? []),
       smallCategoryToBigCategory = Map.of(smallCategoryToBigCategory ?? {}),
       bigCategoryToAccountType = Map.of(
         bigCategoryToAccountType ?? {1: 1, 2: 2},
       );

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

  /// 収入大カテゴリーID → 会計種別（1=生活収支, 2=特別枠）の対応
  ///
  /// 本物は income_big_category.account_type（v9で追加）で解決する。
  /// 既定は onCreate 初期データと同じ {1: 生活収支, 2: 特別枠}。
  final Map<int, int> bigCategoryToAccountType;

  final List<IncomeEntity> insertedEntities = [];
  final List<IncomeEntity> updatedEntities = [];
  final List<int> deletedIds = [];

  /// 期間別の収入合計スタブ（キーは期間開始日のyyyyMMdd。会計種別に依らない）
  ///
  /// キーが無い期間は、これまで通りメモリ内レコードからの集計になる。
  /// 同一開始日の期間で生活収支/特別枠に別の値を与えたい場合は
  /// [sumWithAccountTypeAndPeriodResult]（会計種別込みキー）を使う。
  final Map<String, int> sumWithAccountTypeAndPeriodResultByPeriodStart = {};

  /// 会計種別×期間開始日をキーにした収入合計スタブ
  ///
  /// キーは (accountType, 期間開始日yyyyMMdd)。
  /// [sumWithAccountTypeAndPeriodResultByPeriodStart] より優先して引かれる。
  final Map<(int, String), int> sumWithAccountTypeAndPeriodResult = {};

  /// 期間別の収入合計（キーは期間開始日のyyyyMMdd・カテゴリー指定なし）
  ///
  /// キーが無い期間は、これまで通りメモリ内レコードからの集計になる。
  final Map<String, int> sumWithPeriodResultByPeriodStart = {};

  /// calcurateSumWithPeriod に渡された期間の記録（検証用）
  final List<PeriodValue> sumWithPeriodPeriods = [];

  /// fetchWithAccountTypeAndPeriod に渡された条件の記録（検証用）
  final List<({int accountType, PeriodValue period})>
  fetchWithAccountTypeAndPeriodCalls = [];

  @override
  Future<List<IncomeEntity>> fetchAll() async {
    // 本実装のSQLの ORDER BY id ASC に合わせる
    final all = List.of(records);
    all.sort((a, b) => a.id.compareTo(b.id));
    return all;
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
  Future<List<IncomeEntity>> fetchWithoutCategory({
    required PeriodValue period,
  }) async {
    return records.where((e) => _isDateInPeriod(e.date, period)).toList();
  }

  /// 大カテゴリーIDから会計種別を解決する
  ///
  /// 本物は income_big_category.account_type を参照する。
  /// 小カテゴリーがマップに無い場合はJOIN不成立（=集計対象外）として null を返す。
  /// 大カテゴリーが [bigCategoryToAccountType] に未登録の場合は、
  /// 実DBの `account_type INTEGER NOT NULL DEFAULT 1` に合わせて生活収支(1)を返す
  /// （実DBでは会計種別が欠損した行は存在し得ないため）。
  int? _accountTypeOf(int smallCategoryId) {
    final bigId = smallCategoryToBigCategory[smallCategoryId];
    if (bigId == null) return null;
    return bigCategoryToAccountType[bigId] ?? 1;
  }

  @override
  Future<List<IncomeEntity>> fetchWithAccountTypeAndPeriod({
    required PeriodValue period,
    required int accountType,
  }) async {
    fetchWithAccountTypeAndPeriodCalls.add((
      accountType: accountType,
      period: period,
    ));
    // 本実装は income → 小カテゴリー → 大カテゴリー のJOINで
    // 「income_big_category.account_type = accountType」を条件にしている
    return records
        .where(
          (e) =>
              _isDateInPeriod(e.date, period) &&
              _accountTypeOf(e.categoryId) == accountType,
        )
        .toList();
  }

  @override
  Future<int> calcurateSumWithAccountTypeAndPeriod({
    required PeriodValue period,
    required int accountType,
  }) async {
    // 合計額系はテストが集計結果を所与として与えられるスタブ値方式（§4-7）。
    // 会計種別込みキー → 期間開始日のみのキー の順で引く
    final periodKey = periodKeyOf(period.startDatetime);
    final byTypeAndPeriod =
        sumWithAccountTypeAndPeriodResult[(accountType, periodKey)];
    if (byTypeAndPeriod != null) return byTypeAndPeriod;
    final byPeriod = sumWithAccountTypeAndPeriodResultByPeriodStart[periodKey];
    if (byPeriod != null) return byPeriod;
    // 本実装は fetchWithAccountTypeAndPeriod と同じJOIN条件のSUM
    return records
        .where(
          (e) =>
              _isDateInPeriod(e.date, period) &&
              _accountTypeOf(e.categoryId) == accountType,
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
    // 本実装は fetchMonthlyByBigCategory（最新行採用・該当なしはprice 0）への委譲（ADR-024）
    final budget = await fetchMonthlyByBigCategory(
      month: month,
      expenseBigCategoryId: id,
    );
    return budget.price;
  }

  @override
  Future<int> fetchMonthlyAll({required MonthValue month}) async {
    // 本実装は月のカテゴリーごと最新行（MAX(_id)）のみを合計する（該当なしは0。ADR-024）
    final latestByCategory = <int, BudgetEntity>{};
    for (final e in records.where((e) => e.month == month.month)) {
      final current = latestByCategory[e.expenseBigCategoryId];
      if (current == null || e.id > current.id) {
        latestByCategory[e.expenseBigCategoryId] = e;
      }
    }
    return latestByCategory.values.fold<int>(0, (sum, e) => sum + e.price);
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
/// 本実装は期間内をGROUP BY dateで返し、データの無い日は結果に含まれない
/// （0埋めは呼び出し元の責務）ため、Fakeも期間内の設定済み日付だけを返す。
class FakeDailyExpenseRepository implements DailyExpenseRepository {
  FakeDailyExpenseRepository({Map<DateTime, DailyExpenseEntity>? dailyExpenses})
    : dailyExpenses = Map.of(dailyExpenses ?? {});

  /// 日付（時刻を持たないDateTime）→ その日の集計結果
  final Map<DateTime, DailyExpenseEntity> dailyExpenses;

  /// fetchDailyTotalsByPeriod に渡された期間の記録（検証用）
  final List<({DateTime fromDate, DateTime toDate})> fetchedPeriods = [];

  @override
  Future<List<DailyExpenseEntity>> fetchDailyTotalsByPeriod({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final from = DateTime(fromDate.year, fromDate.month, fromDate.day);
    final to = DateTime(toDate.year, toDate.month, toDate.day);
    fetchedPeriods.add((fromDate: from, toDate: to));
    return [
      for (final entry in dailyExpenses.entries)
        if (!entry.key.isBefore(from) && !entry.key.isAfter(to)) entry.value,
    ];
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
    // 本実装は既定カテゴリー（月次収入・ボーナス）を削除させないため、それに合わせる
    if (IncomeBigCategoryConstants.isDefaultCategory(id)) {
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
