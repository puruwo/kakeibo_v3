import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';

import 'fake_repositories.dart';

/// Fakeの書き込み系が「本物と同じように取得系へ反映されるか」の回帰テスト。
///
/// 本物のDBは書き込み直後からSELECTの対象になる（消えた／変わったが見える）ため、
/// Fakeが記録用リストへ積むだけだと本物より甘くなり、
/// 「削除したら一覧から消える」類の検証が素通りする。
///
/// ここでは usecase 経由のテストでは見えない「状態への反映」を扱う
/// （FixedCostUsecase.delete のテストは deleteWithUnpaidExpenses へ渡した
/// 引数の記録しか検証しないため、論理削除が取得系に効くかはここで押さえる）。
void main() {
  // 固定費マスタの雛形。id と deleteFlag だけをテストごとに変える
  const template = FixedCostEntity(
    id: 0,
    name: '家賃',
    variable: 0,
    price: 80000,
    fixedCostCategoryId: 1,
    intervalNumber: 1,
    intervalUnit: 0,
    firstPaymentDate: '20250625',
    recentPaymentDate: null,
    nextPaymentDate: null,
    deleteFlag: 0,
  );

  group('FakeFixedCostRepository.deleteWithUnpaidExpenses', () {
    // 運用日付。Fakeは実績を持たないためマスタ側の論理削除だけに効く
    const today = '20250706';

    test('削除したマスタは fetchAllActive に含まれない（論理削除）', () async {
      // ID=10（削除対象）とID=11（残る方）を区別できるよう2件置く
      final repository = FakeFixedCostRepository(
        initialRecords: [
          template.copyWith(id: 10),
          template.copyWith(id: 11, name: '通信費'),
        ],
      );

      await repository.deleteWithUnpaidExpenses(id: 10, today: today);

      final active = await repository.fetchAllActive();
      expect(active.map((e) => e.id), [11]);
    });

    test('論理削除なのでレコード自体は残り deleteFlag が1になる', () async {
      // 本物は DELETE ではなく delete_flag=1 の UPDATE のため、行は消えない
      final repository = FakeFixedCostRepository(
        initialRecords: [template.copyWith(id: 10)],
      );

      await repository.deleteWithUnpaidExpenses(id: 10, today: today);

      expect(repository.records, hasLength(1));
      expect(repository.records.single.deleteFlag, 1);
      // 検証用の記録リストは従来どおり残す
      expect(repository.deletedWithUnpaidExpensesArgs, [
        (id: 10, today: today),
      ]);
    });
  });
}
