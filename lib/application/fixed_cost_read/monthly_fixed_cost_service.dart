import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';

class MonthlyFixedCostService {
  // 次の支払い日を設定しentityを返す
  frequencyLabelGetter(FixedCostEntity value) {
    if (value.intervalUnit == 1) {
      if(value.intervalNumber == 1){
        return '毎月';
      }else if(value.intervalNumber == 2){
        return '隔月';
      }else{
      return '${value.intervalNumber}ヶ月毎';
      }
    } else if (value.intervalUnit == 2) {
      if(value.intervalNumber == 1){
        return '毎年';
      }else if(value.intervalNumber == 2){
        return '隔年';
      }else{
        return '${value.intervalNumber}年毎';
      }
    } else  {
      return '';
    }

  }
}
