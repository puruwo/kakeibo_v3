// FixedCostUsecase.addExpenseForFixedCost の「取り残し回収」のテスト
//
// 過去のバッチが失敗するなどでnext_payment_dateが過去日のまま固定されたマスタは、
// 下限のない取得条件（next_payment_date <= 期間終了日）で拾われる。
// そこから期間終了日を超えるまで周期を回し、複数周期ぶんの実績をまとめて
// 生成して追いつかせる（→ ADR-007）。
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_usecase.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  late FakeFixedCostRepository fakeFixedCostRepository;
  late FakeFixedCostExpenseRepository fakeFixedCostExpenseRepository;

  /// 基準シナリオの集計期間（システム日時2025/7/6・開始日25日設定）
  final period = PeriodValue(
    startDatetime: DateTime(2025, 6, 25),
    endDatetime: DateTime(2025, 7, 24),
  );

  ProviderContainer createUsecaseContainer({
    List<FixedCostEntity>? initialRecords,
    List<FixedCostExpenseEntity>? initialExpenses,
  }) {
    fakeFixedCostRepository = FakeFixedCostRepository(
      initialRecords: initialRecords,
    );
    fakeFixedCostExpenseRepository = FakeFixedCostExpenseRepository(
      initialRecords: initialExpenses,
    );
    return createContainer(
      overrides: [
        ...aggregationSettingOverrides(systemDate: DateTime(2025, 7, 6)),
        fixedCostRepositoryProvider.overrideWithValue(fakeFixedCostRepository),
        fixedCostExpenseRepositoryProvider.overrideWithValue(
          fakeFixedCostExpenseRepository,
        ),
      ],
    );
  }

  /// 月次（毎月1回）の固定費マスタ
  FixedCostEntity monthly({
    required int id,
    required String nextPaymentDate,
    String name = 'サブスク',
    int price = 1000,
  }) => FixedCostEntity(
    id: id,
    name: name,
    variable: 0,
    price: price,
    fixedCostCategoryId: 1,
    intervalNumber: 1,
    intervalUnit: 1,
    firstPaymentDate: '20250101',
    nextPaymentDate: nextPaymentDate,
  );

  List<String> insertedDates() => fakeFixedCostExpenseRepository
      .insertedEntities
      .map((e) => e.date)
      .toList();

  group('addExpenseForFixedCost の通常ケース', () {
    test('次回支払日が期間内なら1周期ぶんだけ生成し支払日が1周期進む', () async {
      final container = createUsecaseContainer(
        initialRecords: [monthly(id: 1, nextPaymentDate: '20250701')],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.addExpenseForFixedCost(period);

      expect(insertedDates(), ['20250701']);
      // 8/1は期間終了日(7/24)を超えるのでループはここで止まる
      expect(fakeFixedCostRepository.records.first.nextPaymentDate, '20250801');
    });

    test('支払日が期間終了日ちょうどでも生成される（境界値）', () async {
      final container = createUsecaseContainer(
        initialRecords: [monthly(id: 1, nextPaymentDate: '20250724')],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.addExpenseForFixedCost(period);

      expect(insertedDates(), ['20250724']);
      expect(fakeFixedCostRepository.records.first.nextPaymentDate, '20250824');
    });
  });

  group('addExpenseForFixedCost の取り残し回収', () {
    test('数ヶ月前で取り残されたマスタは複数周期ぶんまとめて生成される', () async {
      // 3/1で止まっていた月次固定費。3/1〜7/1の5回分が生成され、
      // 次回支払日が期間終了日(7/24)を超える8/1になるまで追いつく
      final container = createUsecaseContainer(
        initialRecords: [monthly(id: 1, nextPaymentDate: '20250301')],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.addExpenseForFixedCost(period);

      expect(insertedDates(), [
        '20250301',
        '20250401',
        '20250501',
        '20250601',
        '20250701',
      ]);
      expect(fakeFixedCostRepository.records.first.nextPaymentDate, '20250801');
    });

    test('年次固定費も期間終了日を超えるまで追いつく', () async {
      // 2022/5/10で止まっていた年次固定費 → 2022〜2025の4回分
      final container = createUsecaseContainer(
        initialRecords: const [
          FixedCostEntity(
            id: 1,
            name: '年会費',
            variable: 0,
            price: 10000,
            fixedCostCategoryId: 1,
            intervalNumber: 1,
            intervalUnit: 2,
            firstPaymentDate: '20220510',
            nextPaymentDate: '20220510',
          ),
        ],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.addExpenseForFixedCost(period);

      expect(insertedDates(), ['20220510', '20230510', '20240510', '20250510']);
      expect(fakeFixedCostRepository.records.first.nextPaymentDate, '20260510');
    });

    test('マスタの更新はループ後に1回だけ行われる', () async {
      // 周期ごとにupdateすると、途中で失敗したとき中途半端な日付が残る
      final container = createUsecaseContainer(
        initialRecords: [monthly(id: 1, nextPaymentDate: '20250301')],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.addExpenseForFixedCost(period);

      // 実績は5件生成されるが、マスタ更新は1回だけ
      expect(fakeFixedCostExpenseRepository.insertedEntities, hasLength(5));
      expect(fakeFixedCostRepository.updatedEntities, hasLength(1));
      expect(
        fakeFixedCostRepository.updatedEntities.first.nextPaymentDate,
        '20250801',
      );
    });

    test('周期上限（240回）で打ち切られる', () async {
      // 1900年から止まっている月次固定費。無限ループにならず240件で止まる
      final container = createUsecaseContainer(
        initialRecords: [monthly(id: 1, nextPaymentDate: '19000101')],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.addExpenseForFixedCost(period);

      expect(fakeFixedCostExpenseRepository.insertedEntities, hasLength(240));
      // 打ち切られてもマスタは進んだところまで保存される（次回起動で続きから回収する）
      expect(fakeFixedCostRepository.updatedEntities, hasLength(1));
      expect(insertedDates().first, '19000101');
      expect(insertedDates().last, '19191201');
    });
  });

  group('addExpenseForFixedCost の重複スキップ', () {
    test('既に実績がある周期はスキップされるが支払日は進む', () async {
      // 5/1の実績だけ既に存在する取り残しマスタ。5/1は作り直さないが日付は進む
      final container = createUsecaseContainer(
        initialRecords: [monthly(id: 1, nextPaymentDate: '20250301')],
        initialExpenses: const [
          FixedCostExpenseEntity(
            id: 100,
            fixedCostId: 1,
            fixedCostCategoryId: 1,
            date: '20250501',
            price: 1000,
            name: 'サブスク',
            confirmedCostType: 0,
            isConfirmed: 1,
          ),
        ],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.addExpenseForFixedCost(period);

      // 5/1だけが抜ける
      expect(insertedDates(), ['20250301', '20250401', '20250601', '20250701']);
      // スキップしても日付は進み切る
      expect(fakeFixedCostRepository.records.first.nextPaymentDate, '20250801');
    });

    test('別マスタの同じ日付の実績は重複とみなさない', () async {
      // 固定費ID違いなら別物なので生成される
      final container = createUsecaseContainer(
        initialRecords: [monthly(id: 1, nextPaymentDate: '20250701')],
        initialExpenses: const [
          FixedCostExpenseEntity(
            id: 100,
            fixedCostId: 2,
            fixedCostCategoryId: 1,
            date: '20250701',
            price: 500,
            name: '別の固定費',
            confirmedCostType: 0,
            isConfirmed: 1,
          ),
        ],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.addExpenseForFixedCost(period);

      expect(insertedDates(), ['20250701']);
    });
  });

  group('addExpenseForFixedCost の対象外・不正データ', () {
    test('論理削除済みのマスタは対象外', () async {
      final container = createUsecaseContainer(
        initialRecords: [
          monthly(id: 1, nextPaymentDate: '20250701').copyWith(deleteFlag: 1),
        ],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.addExpenseForFixedCost(period);

      expect(fakeFixedCostExpenseRepository.insertedEntities, isEmpty);
      expect(fakeFixedCostRepository.updatedEntities, isEmpty);
    });

    test('次回支払日がnullのマスタはスキップされる', () async {
      // 周期計算の起点が無く日付が前進しないため、無限ループを避けて飛ばす
      final container = createUsecaseContainer(
        initialRecords: const [
          FixedCostEntity(
            id: 1,
            name: '起点なし',
            variable: 0,
            price: 1000,
            fixedCostCategoryId: 1,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20250101',
          ),
        ],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.addExpenseForFixedCost(period);

      expect(fakeFixedCostExpenseRepository.insertedEntities, isEmpty);
      expect(fakeFixedCostRepository.updatedEntities, isEmpty);
    });

    test('支払い周期の単位が不正なマスタはスキップし、他のマスタは処理を続ける', () async {
      // intervalUnitは1（月）か2（年）のみ。3では次の支払い日を計算できない
      final container = createUsecaseContainer(
        initialRecords: [
          monthly(
            id: 1,
            nextPaymentDate: '20250701',
            name: '単位不正',
          ).copyWith(intervalUnit: 3),
          monthly(id: 2, nextPaymentDate: '20250705', name: '正常'),
        ],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.addExpenseForFixedCost(period);

      // 不正なid=1は飛ばし、id=2の処理は継続する
      expect(insertedDates(), ['20250705']);
      expect(fakeFixedCostRepository.updatedEntities, hasLength(1));
      expect(fakeFixedCostRepository.updatedEntities.first.id, 2);
    });

    test('支払い周期の回数が0以下のマスタはスキップし、他のマスタは処理を続ける', () async {
      // intervalNumber=0では日付が前進せず、無限ループになる
      final container = createUsecaseContainer(
        initialRecords: [
          monthly(
            id: 1,
            nextPaymentDate: '20250701',
            name: '回数0',
          ).copyWith(intervalNumber: 0),
          monthly(id: 2, nextPaymentDate: '20250705', name: '正常'),
        ],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.addExpenseForFixedCost(period);

      expect(insertedDates(), ['20250705']);
      expect(fakeFixedCostRepository.updatedEntities.single.id, 2);
    });

    test('支払い周期の回数が負のマスタもスキップされる', () async {
      // 日付が逆行して永久に期間終了日を超えない
      final container = createUsecaseContainer(
        initialRecords: [
          monthly(
            id: 1,
            nextPaymentDate: '20250701',
          ).copyWith(intervalNumber: -1),
        ],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.addExpenseForFixedCost(period);

      expect(fakeFixedCostExpenseRepository.insertedEntities, isEmpty);
      expect(fakeFixedCostRepository.updatedEntities, isEmpty);
    });
  });

  group('addExpenseForFixedCost の例外伝播', () {
    test('マスタ取得の例外は握りつぶさず呼び出し元へ伝播する', () async {
      // 空リストを返すと「対象0件で成功」と誤記録され、その月の固定費が二度と生成されない
      final container = createUsecaseContainer();
      fakeFixedCostRepository.fetchNextPeriodPaymentError = Exception('DBエラー');
      final usecase = container.read(fixedCostUsecaseProvider);

      await expectLater(
        usecase.addExpenseForFixedCost(period),
        throwsA(isA<Exception>()),
      );
    });
  });
}
