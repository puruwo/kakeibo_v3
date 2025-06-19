import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';

class RequestExpenseHistory {
  final int bigId;
  final PeriodValue monthPeriodValue;
  RequestExpenseHistory({
    required this.bigId,
    required this.monthPeriodValue,
  });
}