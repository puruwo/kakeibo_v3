import 'package:intl/intl.dart';

// Local Import
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/tableNameKey.dart';
import 'package:kakeibo/model/db_read_impl.dart';

DatabaseHelper db = DatabaseHelper.instance;

void categoryBedgetInsert(String date, int bigCategoryId, int price) async {

  // 直近の予算を取得
  final int latestBudget = await querySpecificCategoryBudget(bigCategoryId);

  // 直近の予算と比較して同じ出なければ挿入を実行
  if (latestBudget != price) {
    db.insert(TBL003RecordKey().tableName, {
      TBL003RecordKey().date: date,
      TBL003RecordKey().bigCategoryId: bigCategoryId,
      TBL003RecordKey().price: price,
    });
  }
}
