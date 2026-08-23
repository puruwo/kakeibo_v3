import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost/active_fixed_cost_count_provider.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  const rent = FixedCostEntity(
    id: 10,
    name: '家賃',
    variable: 0,
    price: 80000,
    intervalNumber: 1,
    intervalUnit: 1,
    firstPaymentDate: '20250101',
  );
  const electricity = FixedCostEntity(
    id: 20,
    name: '電気代',
    variable: 1,
    estimatedPrice: 6000,
    intervalNumber: 1,
    intervalUnit: 1,
    firstPaymentDate: '20250101',
  );
  // 削除済み（deleteFlag=1）なので件数に含まれない
  const deletedSubscription = FixedCostEntity(
    id: 30,
    name: '解約済みサブスク',
    variable: 0,
    price: 500,
    intervalNumber: 1,
    intervalUnit: 1,
    firstPaymentDate: '20250101',
    deleteFlag: 1,
  );

  group('activeFixedCostCountProvider', () {
    test('削除されていない固定費の件数を返す', () async {
      final container = createContainer(
        overrides: [
          fixedCostRepositoryProvider.overrideWithValue(
            FakeFixedCostRepository(
              initialRecords: const [rent, electricity, deletedSubscription],
            ),
          ),
        ],
      );

      final count = await container.read(activeFixedCostCountProvider.future);

      expect(count, 2);
    });

    test('DBの更新回数がインクリメントされると再評価されて新しい件数を返す', () async {
      final fakeFixedCostRepository = FakeFixedCostRepository(
        initialRecords: const [rent],
      );
      final container = createContainer(
        overrides: [
          fixedCostRepositoryProvider.overrideWithValue(
            fakeFixedCostRepository,
          ),
        ],
      );

      expect(await container.read(activeFixedCostCountProvider.future), 1);

      // 固定費を1件追加してDBの更新回数をインクリメントする
      await fakeFixedCostRepository.insert(electricity);
      container.read(updateDBCountNotifierProvider.notifier).incrementState();

      expect(await container.read(activeFixedCostCountProvider.future), 2);
    });
  });
}
