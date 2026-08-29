import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';
import 'package:kakeibo/domain/ui_value/income_history_tile_value/income_history_tile_value.dart';

// 収入履歴を取得するサービス
// usecaseに渡す前に1次データを取得するための処理
class IncomeHistoryService {
  final IncomeRepository incomeRepo;
  final IncomeSmallCategoryRepository smallCategoryRepo;
  final IncomeBigCategoryRepository bigCategoryRepo;

  IncomeHistoryService({
    required this.incomeRepo,
    required this.smallCategoryRepo,
    required this.bigCategoryRepo,
  });

  Future<List<IncomeHistoryTileValue>> fetchTileList(
    int accountType,
    PeriodValue period,
  ) async {
    // 期間と会計種別（1=生活収支, 2=特別枠）を指定して収入情報を取得する（ADR-025）
    final incomeList = await incomeRepo.fetchWithAccountTypeAndPeriod(
      accountType: accountType,
      period: period,
    );

    // 取得した支出データから、それぞれカテゴリーなどの情報を取得し、タイルのデータを作成する
    List<IncomeHistoryTileValue> tileList = [];

    for (var income in incomeList) {
      // 支出のレコードからカテゴリーidを取得し、小カテゴリーの情報を取得する
      final small = await smallCategoryRepo.fetchBySmallCategory(
        smallCategoryId: income.categoryId,
      );

      // 小カテゴリーのレコードから大カテゴリーidを取得し、大カテゴリーの情報を取得する
      final big = await bigCategoryRepo.fetchByBigCategory(
        bigCategoryId: small.bigCategoryKey,
      );

      tileList.add(
        IncomeHistoryTileValue(
          id: income.id,
          date: DateTime.parse(
            '${income.date.substring(0, 4)}-${income.date.substring(4, 6)}-${income.date.substring(6, 8)}',
          ),
          price: income.price,
          paymentCategoryId: income.categoryId,
          memo: income.memo,
          smallCategoryName: small.smallCategoryName,
          bigCategoryId: big.id,
          bigCategoryName: big.name,
          colorCode: big.colorCode,
          iconPath: big.iconPath,
        ),
      );
    }
    return tileList;
  }
}
