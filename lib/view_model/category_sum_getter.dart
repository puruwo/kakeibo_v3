import 'package:kakeibo/model/assets_conecter/category_handler.dart';

import 'package:kakeibo/model/tableNameKey.dart';
import 'package:kakeibo/model/db_read_impl.dart';

import 'package:kakeibo/view_model/reference_day_impl.dart';
import 'package:kakeibo/view_model/provider/kaknin_page/kaknin_active_datetime.dart';


class BigCategorySumMapGetter{
  Future<List<Map<String,dynamic>>>build(DateTime dt){

    //集計スタートの日
    final fromDate = getReferenceDay(dt);

    //集計終了の日
    //次の基準日を取得しているので、そこから1引いて集計終了日を算出
    final dtBuff = getNextReferenceDay(dt);
    final toDate = dtBuff.add(const Duration(days: -1));

    return queryCrossMonthMutableRowsByBigCategory(fromDate, toDate);
  }
}

class AllPaymentGetter{
  Future<List<Map<String,dynamic>>>build(DateTime dt) async{

    //集計スタートの日
    final fromDate = getReferenceDay(dt);

    //集計終了の日
    //次の基準日を取得しているので、そこから1引いて集計終了日を算出
    final dtBuff = getNextReferenceDay(dt);
    final toDate = dtBuff.add(const Duration(days: -1));

    final AllPrice = queryMonthlyAllPriceSum(fromDate, toDate);

    return AllPrice;
}}

class AllBudgetGetter{
  Future<List<Map<String,dynamic>>>build(DateTime dt) async{
    final allBudget = queryMonthlyAllBudgetSum(dt);
    return allBudget;
}}


