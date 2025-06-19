import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';

class RequestSmallExpenseHistory {
  final int smallId;
  final PeriodValue monthPeriodValue;
  RequestSmallExpenseHistory({
    required this.smallId,
    required this.monthPeriodValue,
  });
}