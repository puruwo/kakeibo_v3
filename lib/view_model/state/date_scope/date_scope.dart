import 'package:kakeibo/domain_service/month_period_service/aggregation_representative_month_service.dart';
import 'package:kakeibo/view_model/state/date_scope/entity/date_scope_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kakeibo/domain_service/month_period_service/month_period_service.dart';
import 'package:kakeibo/view_model/state/date_scope/selected_datetime/selected_datetime.dart';

final dateScopeEntityProvider = AsyncNotifierProvider<DateScopeNotifier,DateScopeEntity>(
  DateScopeNotifier.new,
);

class DateScopeNotifier extends AsyncNotifier<DateScopeEntity> {
  @override
  Future<DateScopeEntity> build() async {

    // 選択期間を取得する
    final selectedDate = ref.watch(selectedDatetimeNotifierProvider);

    // 月の期間を取得する
    final service = ref.read(monthPeriodServiceProvider);
    final monthPeriod = await service.fetchMonthPeriod(selectedDate);

    // 集計期間内の代表月を取得する
    final aRMService = ref.read(aggregationRepresentativeMonthServiceProvider);
    final representativeMonth = await aRMService.fetchMonth(monthPeriod);

    return DateScopeEntity(
      selectedDate: selectedDate,
      monthPeriod: monthPeriod,
      representativeMonth: representativeMonth
    );
  }
}