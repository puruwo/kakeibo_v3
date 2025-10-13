import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';

class RequestMonthlyCateoryCard {
  final int bigId;
  final DateScopeEntity dateScope;
  RequestMonthlyCateoryCard({
    required this.bigId,
    required this.dateScope,
  });
}