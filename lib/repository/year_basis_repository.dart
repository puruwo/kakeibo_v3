import 'package:kakeibo/domain/db/year_basis_entity/year_basis_entity.dart';
import 'package:kakeibo/domain/db/year_basis_entity/year_basis_entity_repository.dart';
import 'package:kakeibo/model/aggregation_settings_store.dart';

class ImplementsYearBasisRepository implements YearBasisRepository {

  @override
  Future<YearBasisEntity> fetch() async {
    // 代表年の基準を設定ストアから取得する（変更UIのない内部設定・既定は開始日側）
    final basis = await AggregationSettingsStore().fetchYearBasis();
    return YearBasisEntity(
      monthBasis: basis == AggregationSettingsStore.basisEnd
          ? YearBasis.end
          : YearBasis.start,
    );
  }
}
