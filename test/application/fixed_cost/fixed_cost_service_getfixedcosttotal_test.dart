import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_service.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

/// getFixedCostTotal をProviderのbuild内で実行するためのProvider
///
/// Refはbuildスコープの外へ持ち出さず、テストからはこのProviderをreadすることで
/// 実行をトリガーする。
final _getFixedCostTotalProvider = FutureProvider.family<int, DateScopeEntity>(
  (ref, dateScope) => FixedCostService().getFixedCostTotal(ref, dateScope),
);

void main() {
  // 集計期間は2025/6/25〜2025/7/24
  final dateScope = buildDateScope();

  // 固定費マスタ（30:想定額6000 / 40:想定額4000）
  const fixedCosts = [
    FixedCostEntity(
      id: 10,
      name: '家賃',
      variable: 0,
      price: 80000,
      fixedCostCategoryId: 1,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
    ),
    FixedCostEntity(
      id: 30,
      name: '電気代',
      variable: 1,
      estimatedPrice: 6000,
      fixedCostCategoryId: 2,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
    ),
    FixedCostEntity(
      id: 40,
      name: 'ガス代',
      variable: 1,
      estimatedPrice: 4000,
      fixedCostCategoryId: 2,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
    ),
  ];

  ProviderContainer createServiceContainer({
    List<FixedCostExpenseEntity> fixedCostExpenses = const [],
  }) {
    return createContainer(
      overrides: [
        fixedCostExpenseRepositoryProvider.overrideWithValue(
          FakeFixedCostExpenseRepository(initialRecords: fixedCostExpenses),
        ),
        fixedCostRepositoryProvider.overrideWithValue(
          FakeFixedCostRepository(initialRecords: fixedCosts),
        ),
      ],
    );
  }

  const confirmedRent = FixedCostExpenseEntity(
    id: 100,
    fixedCostId: 10,
    fixedCostCategoryId: 1,
    date: '20250701',
    price: 80000,
    name: '家賃',
  );
  const unconfirmedElectricity = FixedCostExpenseEntity(
    id: 200,
    fixedCostId: 30,
    fixedCostCategoryId: 2,
    date: '20250705',
    name: '電気代',
    confirmedCostType: 1,
    isConfirmed: 0,
  );
  const unconfirmedGas = FixedCostExpenseEntity(
    id: 201,
    fixedCostId: 40,
    fixedCostCategoryId: 2,
    date: '20250706',
    name: 'ガス代',
    confirmedCostType: 1,
    isConfirmed: 0,
  );

  group('FixedCostService.getFixedCostTotal', () {
    test('確定済みの合計と未確定分の推定額の合計を足して返す', () async {
      final container = createServiceContainer(
        fixedCostExpenses: const [confirmedRent, unconfirmedElectricity],
      );

      final total = await container.read(
        _getFixedCostTotalProvider(dateScope).future,
      );

      expect(total, 86000);
    });

    test('未確定が1件も無ければ確定済みの合計だけになる', () async {
      final container = createServiceContainer(
        fixedCostExpenses: const [
          confirmedRent,
          FixedCostExpenseEntity(
            id: 101,
            fixedCostId: 30,
            fixedCostCategoryId: 2,
            date: '20250705',
            price: 7200,
            name: '電気代',
            confirmedCostType: 1,
          ),
        ],
      );

      final total = await container.read(
        _getFixedCostTotalProvider(dateScope).future,
      );

      expect(total, 87200);
    });

    test('未確定が複数あれば全件の推定額が合算される', () async {
      final container = createServiceContainer(
        fixedCostExpenses: const [unconfirmedElectricity, unconfirmedGas],
      );

      final total = await container.read(
        _getFixedCostTotalProvider(dateScope).future,
      );

      expect(total, 10000);
    });
  });
}
