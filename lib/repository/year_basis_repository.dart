import 'package:kakeibo/domain/db/year_basis_entity/year_basis_entity.dart';
import 'package:kakeibo/domain/db/year_basis_entity/year_basis_entity_repository.dart';
import 'package:kakeibo/model/database_helper.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsYearBasisRepository implements YearBasisRepository {

  @override
  Future<YearBasisEntity> fetch() async {

    return const YearBasisEntity(monthBasis: YearBasis.start);
  }
}