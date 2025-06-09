import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/income_history/income_history_service.dart';
import 'package:kakeibo/application/income_history/request_income_history_usecase.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/ui_value/income_history_tile_value/income_history_tile_value.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final incomeHistoryNotifierProvider = AsyncNotifierProvider.family<
    IncomeHistoryUsecaseNotifier,
    List<IncomeHistoryTileValue>,
    RequestIncomeHistoryUsecase>(
  IncomeHistoryUsecaseNotifier.new,
);

class IncomeHistoryUsecaseNotifier extends FamilyAsyncNotifier<
    List<IncomeHistoryTileValue>, RequestIncomeHistoryUsecase> {
  // 収入履歴に関するリポジトリ
  late IncomeRepository _incomeRepositoryProvider;

  // 小カテゴリーに関するリポジトリ
  late IncomeSmallCategoryRepository _smallCategoryRepository;

  // 大カテゴリーに関するリポジトリ
  late IncomeBigCategoryRepository _bigCategoryRepository;

  @override
  Future<List<IncomeHistoryTileValue>> build(
      RequestIncomeHistoryUsecase request) async {
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _incomeRepositoryProvider = ref.read(incomeRepositoryProvider);

    _smallCategoryRepository = ref.read(incomeSmallCategoryRepositoryProvider);

    _bigCategoryRepository = ref.read(incomeBigCategoryRepositoryProvider);

    return fetch(
        bigId: request.bigId, selectedMonthPeriod: request.selectedMonthPeriod);
  }

  // 期間指定でタイルデータを取得する
  Future<List<IncomeHistoryTileValue>> fetch(
      {required int bigId, required PeriodValue selectedMonthPeriod}) async {
    final service = IncomeHistoryService(
        bigCategoryRepo: _bigCategoryRepository,
        incomeRepo: _incomeRepositoryProvider,
        smallCategoryRepo: _smallCategoryRepository);

    final result = await service.fetchTileList(bigId, selectedMonthPeriod);

    return result;
  }
}
