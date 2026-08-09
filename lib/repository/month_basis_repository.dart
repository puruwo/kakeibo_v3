import 'package:kakeibo/domain/db/month_basis_entity/month_basis_entity.dart';
import 'package:kakeibo/domain/db/month_basis_entity/month_basis_repository.dart';
import 'package:kakeibo/model/aggregation_settings_store.dart';

class ImplementsMonthBasisRepository implements MonthBasisRepository {

  @override
  Future<MonthBasisEntity> fetch() async {
    // 代表月の基準を設定ストアから取得する（変更UIのない内部設定・既定は開始日側）
    final basis = await AggregationSettingsStore().fetchMonthBasis();
    return MonthBasisEntity(
      monthBasis: basis == AggregationSettingsStore.basisEnd
          ? MonthBasis.end
          : MonthBasis.start,
    );
  }
}
