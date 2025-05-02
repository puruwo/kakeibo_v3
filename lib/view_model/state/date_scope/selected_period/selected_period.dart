
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain_service/month_period_service/month_period_service.dart';

final selectedPeriodProvider = FutureProvider.family<MonthPeriodValue, DateTime>((ref, selectedDate) async {
final monthPeriodService = ref.read(monthPeriodServiceProvider);
return monthPeriodService.fetchMonthPeriod(selectedDate);
});