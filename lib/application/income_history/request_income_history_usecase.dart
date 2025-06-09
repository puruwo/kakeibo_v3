import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';

class RequestIncomeHistoryUsecase {
  final int bigId;
  final PeriodValue selectedMonthPeriod;

  RequestIncomeHistoryUsecase({
    required this.bigId,
    required this.selectedMonthPeriod,
  });
}