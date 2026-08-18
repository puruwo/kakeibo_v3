import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/income_history/income_history_service.dart';
import 'package:kakeibo/application/income_history/income_history_usecase.dart';
import 'package:kakeibo/application/income_history/request_income_history_usecase.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  // 集計期間は2025/6/25〜2025/7/24
  final period = PeriodValue(
    startDatetime: DateTime(2025, 6, 25),
    endDatetime: DateTime(2025, 7, 24),
  );

  // 収入小カテゴリー（10:基本給→大1 / 11:残業代→大1 / 20:賞与→大2）
  const smallCategories = [
    IncomeSmallCategoryEntity(
      id: 10,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 1,
      displayedOrderInBig: 1,
      smallCategoryName: '基本給',
      defaultDisplayed: 1,
    ),
    IncomeSmallCategoryEntity(
      id: 11,
      smallCategoryOrderKey: 2,
      bigCategoryKey: 1,
      displayedOrderInBig: 2,
      smallCategoryName: '残業代',
      defaultDisplayed: 1,
    ),
    IncomeSmallCategoryEntity(
      id: 20,
      smallCategoryOrderKey: 3,
      bigCategoryKey: 2,
      displayedOrderInBig: 1,
      smallCategoryName: '賞与',
      defaultDisplayed: 1,
    ),
  ];

  // 収入大カテゴリー（1:給与 / 2:ボーナス）
  const bigCategories = [
    IncomeBigCategoryEntity(
      id: 1,
      name: '給与',
      colorCode: '0000FF',
      iconPath: 'assets/images/icon_salary.svg',
    ),
    IncomeBigCategoryEntity(
      id: 2,
      name: 'ボーナス',
      colorCode: 'FF00FF',
      iconPath: 'assets/images/icon_bonus.svg',
    ),
  ];

  // 収入小カテゴリーID → 収入大カテゴリーID
  const smallCategoryToBigCategory = {10: 1, 11: 1, 20: 2};

  late FakeIncomeRepository fakeIncomeRepository;

  IncomeHistoryService buildService({List<IncomeEntity> incomes = const []}) {
    fakeIncomeRepository = FakeIncomeRepository(
      initialRecords: incomes,
      smallCategoryToBigCategory: smallCategoryToBigCategory,
    );
    return IncomeHistoryService(
      incomeRepo: fakeIncomeRepository,
      smallCategoryRepo: FakeIncomeSmallCategoryRepository(
        initialRecords: smallCategories,
      ),
      bigCategoryRepo: FakeIncomeBigCategoryRepository(
        initialRecords: bigCategories,
      ),
    );
  }

  ProviderContainer createUsecaseContainer({
    List<IncomeEntity> incomes = const [],
  }) {
    fakeIncomeRepository = FakeIncomeRepository(
      initialRecords: incomes,
      smallCategoryToBigCategory: smallCategoryToBigCategory,
    );
    return createContainer(
      overrides: [
        incomeRepositoryProvider.overrideWithValue(fakeIncomeRepository),
        incomeSmallCategoryRepositoryProvider.overrideWithValue(
          FakeIncomeSmallCategoryRepository(initialRecords: smallCategories),
        ),
        incomeBigCategoryRepositoryProvider.overrideWithValue(
          FakeIncomeBigCategoryRepository(initialRecords: bigCategories),
        ),
      ],
    );
  }

  group('IncomeHistoryService.fetchTileList', () {
    test('大カテゴリーIDと期間で取得し、日付変換とカテゴリー結合が行われる', () async {
      final service = buildService(
        incomes: const [
          IncomeEntity(
            id: 1,
            categoryId: 10,
            date: '20250625',
            price: 300000,
            memo: '6月分',
          ),
          // 大カテゴリーが異なるので対象外
          IncomeEntity(id: 2, categoryId: 20, date: '20250710', price: 500000),
          // 期間外なので対象外
          IncomeEntity(id: 3, categoryId: 11, date: '20250624', price: 20000),
        ],
      );

      final result = await service.fetchTileList(1, period);

      // 大カテゴリーIDと期間がそのままリポジトリへ渡る
      expect(
        fakeIncomeRepository.fetchWithCategoryAndPeriodCalls,
        hasLength(1),
      );
      final call = fakeIncomeRepository.fetchWithCategoryAndPeriodCalls.single;
      expect(call.categoryId, 1);
      expect(call.period, period);

      final tile = result.single;
      expect(tile.id, 1);
      // 'yyyyMMdd'の文字列からDateTimeへ変換される
      expect(tile.date, DateTime(2025, 6, 25));
      expect(tile.price, 300000);
      expect(tile.memo, '6月分');
      expect(tile.paymentCategoryId, 10);
      expect(tile.smallCategoryName, '基本給');
      expect(tile.bigCategoryName, '給与');
      expect(tile.colorCode, '0000FF');
      expect(tile.iconPath, 'assets/images/icon_salary.svg');
    });

    test('対象の収入が0件なら空リストを返す', () async {
      final service = buildService();

      expect(await service.fetchTileList(1, period), isEmpty);
    });

    test('タイルの並びはリポジトリの返却順を保持する', () async {
      final service = buildService(
        incomes: const [
          IncomeEntity(id: 5, categoryId: 11, date: '20250720', price: 20000),
          IncomeEntity(id: 1, categoryId: 10, date: '20250625', price: 300000),
          IncomeEntity(id: 3, categoryId: 10, date: '20250701', price: 10000),
        ],
      );

      final result = await service.fetchTileList(1, period);

      // 並べ替えは行わないため、リポジトリが返した順のまま
      expect(result.map((e) => e.id), [5, 1, 3]);
    });
  });

  group('IncomeHistoryUsecaseNotifier.build', () {
    test('bigId=1（給与）のリクエストで月次収入が取得される', () async {
      final container = createUsecaseContainer(
        incomes: const [
          IncomeEntity(id: 1, categoryId: 10, date: '20250625', price: 300000),
          IncomeEntity(id: 2, categoryId: 20, date: '20250710', price: 500000),
        ],
      );

      final result = await container.read(
        incomeHistoryNotifierProvider(
          RequestIncomeHistoryUsecase(bigId: 1, selectedMonthPeriod: period),
        ).future,
      );

      expect(result.map((e) => e.id), [1]);
      expect(result.single.bigCategoryName, '給与');
    });

    test('bigId=2（ボーナス）のリクエストでボーナス収入が取得される', () async {
      final container = createUsecaseContainer(
        incomes: const [
          IncomeEntity(id: 1, categoryId: 10, date: '20250625', price: 300000),
          IncomeEntity(id: 2, categoryId: 20, date: '20250710', price: 500000),
        ],
      );

      final result = await container.read(
        incomeHistoryNotifierProvider(
          RequestIncomeHistoryUsecase(bigId: 2, selectedMonthPeriod: period),
        ).future,
      );

      expect(result.map((e) => e.id), [2]);
      expect(result.single.smallCategoryName, '賞与');
      expect(result.single.bigCategoryName, 'ボーナス');
    });
  });
}
