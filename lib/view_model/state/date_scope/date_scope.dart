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
    final selectedDate = ref.watch(selectedDatetimeNotifierProvider);
    final service = ref.read(monthPeriodServiceProvider);
    final monthPeriod = await service.fetchMonthPeriod(selectedDate);

    return DateScopeEntity(
      selectedDate: selectedDate,
      monthPeriod: monthPeriod,
    );
  }
}