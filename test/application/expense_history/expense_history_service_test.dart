import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/expense_history/expense_history_service.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';

import '../../helper/fake_repositories.dart';

void main() {
  // 集計期間は2025/6/25〜2025/7/24
  final period = PeriodValue(
    startDatetime: DateTime(2025, 6, 25),
    endDatetime: DateTime(2025, 7, 24),
  );

  // 支出小カテゴリー（10:食費→大1 / 12:旅行→大2）
  const smallCategories = [
    ExpenseSmallCategoryEntity(
      id: 10,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 1,
      displayedOrderInBig: 1,
      smallCategoryName: '食費',
      defaultDisplayed: 1,
    ),
    ExpenseSmallCategoryEntity(
      id: 12,
      smallCategoryOrderKey: 2,
      bigCategoryKey: 2,
      displayedOrderInBig: 1,
      smallCategoryName: '旅行',
      defaultDisplayed: 1,
    ),
  ];

  // 支出大カテゴリー（1:生活費 / 2:レジャー）
  const bigCategories = [
    ExpenseBigCategoryEntity(
      id: 1,
      colorCode: 'FFAA00',
      bigCategoryName: '生活費',
      resourcePath: 'assets/images/icon_life.svg',
      displayOrder: 1,
      isDisplayed: 1,
    ),
    ExpenseBigCategoryEntity(
      id: 2,
      colorCode: '00AAFF',
      bigCategoryName: 'レジャー',
      resourcePath: 'assets/images/icon_leisure.svg',
      displayOrder: 2,
      isDisplayed: 1,
    ),
  ];

  late FakeExpenseRepository fakeExpenseRepository;

  ExpenseHistoryService buildService({
    List<ExpenseEntity> expenses = const [],
  }) {
    fakeExpenseRepository = FakeExpenseRepository(initialRecords: expenses);
    return ExpenseHistoryService(
      expenseRepo: fakeExpenseRepository,
      smallCategoryRepo: FakeExpenseSmallCategoryRepository(
        initialRecords: smallCategories,
      ),
      bigCategoryRepo: FakeExpenseBigCategoryRepository(
        initialRecords: bigCategories,
      ),
    );
  }

  group('ExpenseHistoryService.fetchTileList', () {
    test('smallIdを指定しない場合は拠出元と期間だけで取得する', () async {
      final service = buildService(
        expenses: const [
          ExpenseEntity(
            id: 1,
            date: '20250701',
            price: 1000,
            paymentCategoryId: 10,
          ),
          ExpenseEntity(
            id: 2,
            date: '20250702',
            price: 2000,
            paymentCategoryId: 12,
          ),
        ],
      );

      final result = await service.fetchTileList(1, period);

      // 小カテゴリー指定なしのメソッドだけが呼ばれる
      expect(fakeExpenseRepository.fetchWithSourceCategoryCalls, hasLength(1));
      expect(
        fakeExpenseRepository
            .fetchWithSourceCategoryCalls
            .single
            .incomeSourceBigId,
        1,
      );
      expect(
        fakeExpenseRepository.fetchWithSourceCategoryCalls.single.period,
        period,
      );
      expect(fakeExpenseRepository.fetchWithSmallCategoryCalls, isEmpty);
      // 拠出元1の支出2件が対象
      expect(result.map((e) => e.id), [2, 1]);
    });

    test('smallIdを指定した場合は小カテゴリー指定の取得になる', () async {
      final service = buildService(
        expenses: const [
          ExpenseEntity(
            id: 1,
            date: '20250701',
            price: 1000,
            paymentCategoryId: 10,
          ),
          ExpenseEntity(
            id: 2,
            date: '20250702',
            price: 2000,
            paymentCategoryId: 12,
          ),
        ],
      );

      final result = await service.fetchTileList(1, period, smallId: 12);

      expect(fakeExpenseRepository.fetchWithSourceCategoryCalls, isEmpty);
      expect(fakeExpenseRepository.fetchWithSmallCategoryCalls, hasLength(1));
      final call = fakeExpenseRepository.fetchWithSmallCategoryCalls.single;
      expect(call.incomeSourceBigId, 1);
      expect(call.smallCategoryId, 12);
      expect(call.period, period);
      expect(result.map((e) => e.id), [2]);
    });

    test('日付が変換され、小/大カテゴリーの名前・色・アイコンが結合される', () async {
      final service = buildService(
        expenses: const [
          ExpenseEntity(
            id: 1,
            date: '20250701',
            price: 1000,
            paymentCategoryId: 10,
            memo: 'スーパー',
          ),
        ],
      );

      final result = await service.fetchTileList(1, period);

      final tile = result.single;
      // 'yyyyMMdd'の文字列からDateTimeへ変換される
      expect(tile.date, DateTime(2025, 7, 1));
      expect(tile.id, 1);
      expect(tile.price, 1000);
      expect(tile.memo, 'スーパー');
      expect(tile.paymentCategoryId, 10);
      expect(tile.smallCategoryName, '食費');
      expect(tile.bigCategoryName, '生活費');
      expect(tile.colorCode, 'FFAA00');
      expect(tile.iconPath, 'assets/images/icon_life.svg');
    });

    test('支出レコードのincomeSourceBigCategoryがタイルへ引き継がれる', () async {
      final service = buildService(
        expenses: const [
          ExpenseEntity(
            id: 5,
            date: '20250703',
            price: 50000,
            paymentCategoryId: 12,
            incomeSourceBigCategory: 2,
          ),
        ],
      );

      final result = await service.fetchTileList(2, period);

      expect(result.single.incomeSourceBigCategory, 2);
      expect(result.single.bigCategoryName, 'レジャー');
    });

    test('対象の支出が0件なら空リストを返す', () async {
      final service = buildService();

      expect(await service.fetchTileList(1, period), isEmpty);
    });
  });
}
