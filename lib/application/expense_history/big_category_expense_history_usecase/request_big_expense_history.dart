import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';

class RequestBigExpenseHistory {
  final int bigId;
  final PeriodValue monthPeriodValue;
  RequestBigExpenseHistory({
    required this.bigId,
    required this.monthPeriodValue,
  });
}