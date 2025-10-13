import 'package:kakeibo/domain_service/month_period_service/aggregation_representative_month_service.dart';
import 'package:kakeibo/domain_service/month_period_service/month_index_service.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/domain_service/year_period_service/aggregation_representative_year_service.dart';
import 'package:kakeibo/domain_service/year_period_service/month_period_service.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kakeibo/domain_service/month_period_service/month_period_service.dart';

final systemDateScopeEntityProvider = AsyncNotifierProvider<SystemDateScopeNotifier,DateScopeEntity>(
  SystemDateScopeNotifier.new,
);

class SystemDateScopeNotifier extends AsyncNotifier<DateScopeEntity> {
  @override
  Future<DateScopeEntity> build() async {

    // 選択期間を取得する
    final selectedDate = ref.watch(systemDatetimeNotifierProvider);

    // 月の期間を取得する
    final monthService = ref.read(monthPeriodServiceProvider);
    final monthPeriod = await monthService.fetchMonthPeriod(selectedDate);

    // 集計期間内の代表月を取得する
    final aRMService = ref.read(aggregationRepresentativeMonthServiceProvider);
    final representativeMonth = await aRMService.fetchMonth(selectedDate);

    // 年の期間を取得する
    final yearService = ref.read(yearPeriodServiceProvider);
    final yearPeriod = await yearService.fetchYearPeriod(selectedDate);

    // 集計期間内の代表年を取得する
    final aRYService = ref.read(aggregationRepresentativeYearServiceProvider);
    final representativeYear = await aRYService.fetchYear(selectedDate);

    // 選択している日付の月が、何番目の月かを取得する
    final monthIndex = await ref.read(monthIndexServiceProvider).fetchMonthIndex(selectedDate);

    return DateScopeEntity(
      selectedDate: selectedDate,
      monthPeriod: monthPeriod,
      monthIndex: monthIndex,
      representativeMonth: representativeMonth,
      yearPeriod: yearPeriod,
      representativeYear: representativeYear,
    );
  }
}