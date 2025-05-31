import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/month_basis_entity/month_basis_entity.dart';
import 'package:kakeibo/domain/db/month_basis_entity/month_basis_repository.dart';

// 集計期間の代表月は初日か最終日のどっちか
final monthBasisProvider =
    Provider<MonthBasisService>(MonthBasisService.new);

class MonthBasisService {
  MonthBasisService(this._ref);

  final Ref _ref;
  MonthBasisRepository get monthBasesRepository =>
      _ref.read(monthBasisRepositoryProvider);

  // ユーザ設定の集計表示代表日の開始日 or 最終日の選択設定を取得
  Future<MonthBasisEntity> fetch() async {
    MonthBasisEntity monthBasisEntity =
        await monthBasesRepository.fetch();
    return monthBasisEntity;
  }
}
