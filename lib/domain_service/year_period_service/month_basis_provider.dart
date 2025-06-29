import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/year_basis_entity/year_basis_entity.dart';
import 'package:kakeibo/domain/db/year_basis_entity/year_basis_entity_repository.dart';

// 集計期間の代表月は初月か最終月のどっちか
final yearBasisProvider =
    Provider<YearBasisService>(YearBasisService.new);

class YearBasisService {
  YearBasisService(this._ref);

  final Ref _ref;
  YearBasisRepository get yearBasesRepository =>
      _ref.read(yearBasisRepositoryProvider);

  // ユーザ設定を取得する
  Future<YearBasisEntity> fetch() async {
    YearBasisEntity yearBasisEntity =
        await yearBasesRepository.fetch();
    return yearBasisEntity;
  }
}
