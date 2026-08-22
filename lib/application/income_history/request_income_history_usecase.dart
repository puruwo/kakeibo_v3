import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';

class RequestIncomeHistoryUsecase {
  // 会計種別（1=生活収支, 2=特別枠）。ADR-025で大カテゴリーID指定から変更
  final int accountType;
  final PeriodValue selectedMonthPeriod;

  RequestIncomeHistoryUsecase({
    required this.accountType,
    required this.selectedMonthPeriod,
  });
}
