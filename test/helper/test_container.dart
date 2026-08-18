// テスト用ProviderContainerの生成ヘルパー
//
// 本番の main.dart では ProviderScope.overrides で実装リポジトリを注入している。
// テストでは同じ仕組みで Fake リポジトリを注入する。
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/core/month_value/month_value.dart';
import 'package:kakeibo/domain/core/year_value/year_value.dart';
import 'package:kakeibo/domain/db/aggregation_start_day_entity/aggregation_start_day_repository.dart';
import 'package:kakeibo/domain/db/aggregation_start_month_entity/aggregation_start_month_repository.dart';
import 'package:kakeibo/domain/db/month_basis_entity/month_basis_entity.dart';
import 'package:kakeibo/domain/db/month_basis_entity/month_basis_repository.dart';
import 'package:kakeibo/domain/db/year_basis_entity/year_basis_entity.dart';
import 'package:kakeibo/domain/db/year_basis_entity/year_basis_entity_repository.dart';
import 'package:kakeibo/domain_service/month_period_service/period_status_service.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

import 'fake_repositories.dart';

/// テスト用のProviderContainerを生成する。テスト終了時に自動でdisposeされる。
ProviderContainer createContainer({List<Override> overrides = const []}) {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  return container;
}

/// システム日時を固定値で返すNotifier（テスト用）
///
/// 本番の SystemDatetimeNotifier は DateTime.now() を返すため、
/// 「今日」に依存するロジックのテストではこれで固定する。
class FixedSystemDatetimeNotifier extends SystemDatetimeNotifier {
  FixedSystemDatetimeNotifier(this._fixedDate);
  final DateTime _fixedDate;

  @override
  DateTime build() => _fixedDate;
}

/// 集計期間まわりの設定（開始日・開始月・代表月/年の基準）と
/// システム日時をまとめてoverrideする標準セット。
///
/// 既定値は本番の初期設定と同じ「開始日25日・開始月4月・基準はどちらもstart」。
List<Override> aggregationSettingOverrides({
  int startDay = 25,
  int startMonth = 4,
  MonthBasis monthBasis = MonthBasis.start,
  YearBasis yearBasis = YearBasis.start,
  DateTime? systemDate,
}) {
  return [
    aggregationStartDayRepositoryProvider.overrideWithValue(
      FakeAggregationStartDayRepository(day: startDay),
    ),
    aggregationStartMonthRepositoryProvider.overrideWithValue(
      FakeAggregationStartMonthRepository(month: startMonth),
    ),
    monthBasisRepositoryProvider.overrideWithValue(
      FakeMonthBasisRepository(basis: monthBasis),
    ),
    yearBasisRepositoryProvider.overrideWithValue(
      FakeYearBasisRepository(basis: yearBasis),
    ),
    if (systemDate != null)
      systemDatetimeNotifierProvider.overrideWith(
        () => FixedSystemDatetimeNotifier(systemDate),
      ),
  ];
}

/// DB更新回数のProviderに購読を張り、値を追跡できるようにする
///
/// [updateDBCountNotifierProvider] はautoDisposeなので、購読が無いと
/// read のたびに破棄・再生成されて0に戻ってしまう。
/// 戻り値の `read()` で現在のカウントを取得する。
ProviderSubscription<int> listenUpdateDBCount(ProviderContainer container) {
  return container.listen(
    updateDBCountNotifierProvider,
    (previous, next) {},
    fireImmediately: true,
  );
}

/// テスト用の[DateScopeEntity]を組み立てる
///
/// 集計期間のドメインサービスを通さず、期間と代表月を直接与える。
/// 既定値は「開始日25日・開始月4月」の設定で 2025/7/6 を選んだときの値
/// （集計期間 2025/6/25〜2025/7/24・代表月 202506・年度 2025）。
DateScopeEntity buildDateScope({
  DateTime? selectedDate,
  PeriodValue? aggregationMonthPeriod,
  String representativeMonth = '202506',
  String representativeYear = '2025',
  int monthIndex = 0,
  PeriodStatus periodStatus = PeriodStatus.current,
}) {
  final period =
      aggregationMonthPeriod ??
      PeriodValue(
        startDatetime: DateTime(2025, 6, 25),
        endDatetime: DateTime(2025, 7, 24),
      );
  return DateScopeEntity(
    selectedDate: selectedDate ?? DateTime(2025, 7, 6),
    aggregationMonthPeriod: period,
    displayMonthPeriod: period,
    monthIndex: monthIndex,
    representativeMonth: MonthValue(month: representativeMonth),
    yearPeriod: PeriodValue(
      startDatetime: DateTime(2025, 4, 25),
      endDatetime: DateTime(2026, 4, 24),
    ),
    representativeYear: YearValue(year: representativeYear),
    periodStatus: periodStatus,
  );
}
