// UnconfirmedFixedCostPromptUsecase（未確定固定費の促しの対象取得・予想額で確定）のテスト
//
// 基準シナリオ: 開始日25日・今日 2025/7/6 → 現在の月度は 6/25〜7/24（KP-028）。
// 対象判定の境界値は UnconfirmedFixedCostPromptRule のテストが担当する。
// ここは「行の取得範囲・並び・Valueへの組み立て・確定の配線」を検証する。
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/unconfirmed_fixed_cost_prompt/unconfirmed_fixed_cost_prompt_usecase.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/view/component/app_exception.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';
import '../fixed_cost_read/fixed_cost_read_fixtures.dart';

void main() {
  late FakeExpenseRepository fakeExpenseRepository;

  ProviderContainer createUsecaseContainer({
    required List<ExpenseEntity> expenses,
    DateTime? systemDate,
  }) {
    fakeExpenseRepository = FakeExpenseRepository(initialRecords: expenses);
    return createContainer(
      overrides: [
        ...aggregationSettingOverrides(
          systemDate: systemDate ?? DateTime(2025, 7, 6),
        ),
        expenseRepositoryProvider.overrideWithValue(fakeExpenseRepository),
        expenseSmallCategoryRepositoryProvider.overrideWithValue(
          FakeExpenseSmallCategoryRepository(
            initialRecords: fixtureSmallCategories,
          ),
        ),
        expensebigCategoryRepositoryProvider.overrideWithValue(
          FakeExpenseBigCategoryRepository(
            initialRecords: fixtureBigCategories,
          ),
        ),
        fixedCostRepositoryProvider.overrideWithValue(
          FakeFixedCostRepository(
            initialRecords: fixtureFixedCosts,
            expenseRepository: fakeExpenseRepository,
          ),
        ),
      ],
    );
  }

  /// 電気代（マスタ30・変動）の未確定行を作る
  ExpenseEntity unconfirmedElectricity({
    required int id,
    required String date,
    int? estimatedPrice = 6000,
  }) => ExpenseEntity(
    id: id,
    date: date,
    price: null,
    paymentCategoryId: 21,
    memo: '電気代',
    fixedCostId: 30,
    isConfirmed: 0,
    estimatedPrice: estimatedPrice,
  );

  group('fetchLaunchPromptTargets（起動時の促しの対象）', () {
    test('現在の月度より前の未確定行だけを、支払日の古い順に返す', () async {
      final container = createUsecaseContainer(
        expenses: [
          // 現在の月度（6/25〜7/24）の未確定行 → 対象外
          unconfirmedElectricity(id: 1, date: '20250705'),
          // 現在の月度の開始日ちょうど → 対象外
          unconfirmedElectricity(id: 2, date: '20250625'),
          // 開始日の前日 → 対象
          unconfirmedElectricity(id: 3, date: '20250624'),
          // 何か月も前 → 対象
          unconfirmedElectricity(id: 4, date: '20250305'),
          // 過去の月度だが確定済み → 対象外
          fixtureConfirmedInsurance.copyWith(id: 5, date: '20250530'),
          // 過去の月度の通常支出（固定費行ではない）→ 対象外
          const ExpenseEntity(
            id: 6,
            date: '20250601',
            price: 1200,
            paymentCategoryId: 21,
          ),
        ],
      );
      final usecase = container.read(unconfirmedFixedCostPromptUsecaseProvider);

      final targets = await usecase.fetchLaunchPromptTargets();

      expect(targets.map((t) => t.id), [4, 3]);
    });

    test('一覧に出す名前・カテゴリー・予想額が組み立てられる', () async {
      final container = createUsecaseContainer(
        expenses: [
          unconfirmedElectricity(id: 3, date: '20250605', estimatedPrice: 6500),
        ],
      );
      final usecase = container.read(unconfirmedFixedCostPromptUsecaseProvider);

      final target = (await usecase.fetchLaunchPromptTargets()).single;

      expect(target.name, '電気代');
      expect(target.date, DateTime(2025, 6, 5));
      // 予想額は行が持つ値を優先する（マスタは 6,000）
      expect(target.estimatedPrice, 6500);
      expect(target.categoryName, '光熱費');
      expect(target.colorCode, '00AAFF');
    });

    test('対象が無ければ空リストを返す', () async {
      final container = createUsecaseContainer(
        expenses: [unconfirmedElectricity(id: 1, date: '20250705')],
      );
      final usecase = container.read(unconfirmedFixedCostPromptUsecaseProvider);

      expect(await usecase.fetchLaunchPromptTargets(), isEmpty);
    });

    test('同じ支払日の行はid順に並ぶ', () async {
      final container = createUsecaseContainer(
        expenses: [
          unconfirmedElectricity(id: 9, date: '20250605'),
          unconfirmedElectricity(id: 7, date: '20250605'),
        ],
      );
      final usecase = container.read(unconfirmedFixedCostPromptUsecaseProvider);

      final targets = await usecase.fetchLaunchPromptTargets();

      expect(targets.map((t) => t.id), [7, 9]);
    });
  });

  group('fetchOverdueTargets（注意バナーの対象）', () {
    final shownPeriod = PeriodValue(
      startDatetime: DateTime(2025, 6, 25),
      endDatetime: DateTime(2025, 7, 24),
    );

    test('表示中の月度で支払日から3日経過した未確定行だけを、支払日の古い順に返す', () async {
      final container = createUsecaseContainer(
        expenses: [
          // 7/3 支払い → 今日 7/6 で3日経過ちょうど → 対象
          unconfirmedElectricity(id: 1, date: '20250703'),
          // 7/4 支払い → 2日経過 → 対象外
          unconfirmedElectricity(id: 2, date: '20250704'),
          // 6/26 支払い → 対象
          unconfirmedElectricity(id: 3, date: '20250626'),
          // 支払日が未来 → 対象外
          unconfirmedElectricity(id: 4, date: '20250720'),
          // 表示中の月度の外（前の月度）→ 対象外
          unconfirmedElectricity(id: 5, date: '20250610'),
          // 確定済み → 対象外
          fixtureConfirmedRent,
        ],
      );
      final usecase = container.read(unconfirmedFixedCostPromptUsecaseProvider);

      final targets = await usecase.fetchOverdueTargets(
        shownPeriod: shownPeriod,
      );

      expect(targets.map((t) => t.id), [3, 1]);
    });

    test('過去の月度を表示中でも、その月度の未確定行は対象になる', () async {
      final container = createUsecaseContainer(
        expenses: [unconfirmedElectricity(id: 5, date: '20250610')],
      );
      final usecase = container.read(unconfirmedFixedCostPromptUsecaseProvider);

      final targets = await usecase.fetchOverdueTargets(
        shownPeriod: PeriodValue(
          startDatetime: DateTime(2025, 5, 25),
          endDatetime: DateTime(2025, 6, 24),
        ),
      );

      expect(targets.map((t) => t.id), [5]);
    });
  });

  group('confirmWithEstimatedPrice（予想額で確定）', () {
    test('予想額を実額にして確定し、予想額は残し、DB更新を通知する', () async {
      final container = createUsecaseContainer(
        expenses: [
          unconfirmedElectricity(id: 3, date: '20250605', estimatedPrice: 6500),
        ],
      );
      final updateCount = listenUpdateDBCount(container);
      final usecase = container.read(unconfirmedFixedCostPromptUsecaseProvider);

      await usecase.confirmWithEstimatedPrice(
        expenseId: 3,
        estimatedPrice: 6500,
      );

      final updated = await fakeExpenseRepository.fetchById(id: 3);
      expect(updated?.price, 6500);
      expect(updated?.isConfirmed, 1);
      expect(updated?.estimatedPrice, 6500);
      // 通常の確定（FixedCostRecordUsecase.edit）と同じ経路を通るため、
      // 確定と推定額の再計算で2回通知される
      expect(updateCount.read(), 2);
      // 確定後は促しの対象から外れる
      expect(await usecase.fetchLaunchPromptTargets(), isEmpty);
    });

    test('すでに確定済みの行には何もしない', () async {
      final container = createUsecaseContainer(
        expenses: [fixtureConfirmedRent],
      );
      final updateCount = listenUpdateDBCount(container);
      final usecase = container.read(unconfirmedFixedCostPromptUsecaseProvider);

      await usecase.confirmWithEstimatedPrice(
        expenseId: fixtureConfirmedRent.id,
        estimatedPrice: 80000,
      );

      expect(fakeExpenseRepository.updatedEntities, isEmpty);
      expect(updateCount.read(), 0);
    });

    test('対象の行が無ければエラー', () async {
      final container = createUsecaseContainer(expenses: const []);
      final usecase = container.read(unconfirmedFixedCostPromptUsecaseProvider);

      await expectLater(
        () => usecase.confirmWithEstimatedPrice(
          expenseId: 999,
          estimatedPrice: 6000,
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '対象の固定費が見つかりませんでした',
          ),
        ),
      );
    });

    test('行に予想額が無くても、一覧に出した予想額（マスタの推定額）で確定できる', () async {
      final container = createUsecaseContainer(
        expenses: [
          unconfirmedElectricity(id: 3, date: '20250605', estimatedPrice: null),
        ],
      );
      final usecase = container.read(unconfirmedFixedCostPromptUsecaseProvider);

      // 一覧の予想額は「行の値 ?? マスタの推定額」（マスタ30は 6,000）
      final target = (await usecase.fetchLaunchPromptTargets()).single;
      expect(target.estimatedPrice, 6000);

      await usecase.confirmWithEstimatedPrice(
        expenseId: target.id,
        estimatedPrice: target.estimatedPrice,
      );

      final updated = await fakeExpenseRepository.fetchById(id: 3);
      expect(updated?.price, 6000);
      expect(updated?.isConfirmed, 1);
    });

    test('予想額が0円なら確定できずエラー', () async {
      final container = createUsecaseContainer(
        expenses: [unconfirmedElectricity(id: 3, date: '20250605')],
      );
      final usecase = container.read(unconfirmedFixedCostPromptUsecaseProvider);

      await expectLater(
        () =>
            usecase.confirmWithEstimatedPrice(expenseId: 3, estimatedPrice: 0),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '0円以上で入力してください',
          ),
        ),
      );
    });
  });
}
