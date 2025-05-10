import 'package:kakeibo/domain/db/month_basis_entity/month_basis_entity.dart';
import 'package:kakeibo/domain/db/month_basis_entity/month_basis_repository.dart';
import 'package:kakeibo/model/database_helper.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsMonthBasisRepository implements MonthBasisRepository {

  @override
  Future<MonthBasisEntity> fetch() async {

    return const MonthBasisEntity(monthBasis: MonthBasis.start);
  }
}