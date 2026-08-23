// DataManagementUsecase のDB結合テスト
//
// 「全データ削除」はDBファイルごと消して次回アクセス時に onCreate から作り直す実装。
// 取引データが消えることと、カテゴリーマスタのシードが復活することの両方を本物のDBで確認する。
// 共有シート起動（Share.shareXFiles）はプラットフォーム依存なので対象外とし、
// 事前チェックのAppExceptionだけを検証する。
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/data_management/data_management_usecase.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/view/component/app_exception.dart';

import '../helper/db_test_helper.dart';
import '../helper/test_container.dart';

/// 取引系の全テーブルに1件ずつデータを入れる
Future<void> _seedTransactions() async {
  await insertExpenseRow(id: 1, date: '20250701', price: 1000);
  await insertIncomeRow(id: 1, date: '20250701', price: 300000);
  await insertBudgetRow(
    id: 1,
    expenseBigCategoryId: 1,
    month: '202506',
    price: 35000,
  );
  await insertFixedCostRow(
    id: 1,
    name: '家賃',
    price: 80000,
  );
  await insertExpenseRow(
    id: 100,
    fixedCostId: 1,
    date: '20250701',
    price: 80000,
    memo: '家賃',
    isConfirmed: 1,
  );
}

void main() {
  setUpDbTestEnvironment();

  group('deleteAllData', () {
    test('取引データが全て削除される', () async {
      await _seedTransactions();
      final container = createContainer();
      final usecase = container.read(dataManagementUsecaseProvider);

      await usecase.deleteAllData();

      // 次のアクセスで onCreate から作り直されるため、取引テーブルは空になる
      expect(
        await DatabaseHelper.instance.queryRowCount(SqfExpense.tableName),
        0,
      );
      expect(
        await DatabaseHelper.instance.queryRowCount(SqfIncome.tableName),
        0,
      );
      expect(
        await DatabaseHelper.instance.queryRowCount(SqfBudget.tableName),
        0,
      );
      expect(
        await DatabaseHelper.instance.queryRowCount(SqfFixedCost.tableName),
        0,
      );
    });

    test('カテゴリーマスタのシードが復活する', () async {
      await _seedTransactions();
      final container = createContainer();
      final usecase = container.read(dataManagementUsecaseProvider);

      await usecase.deleteAllData();

      expect(
        await DatabaseHelper.instance.queryRowCount(
          SqfExpenseBigCategory.tableName,
        ),
        12,
      );
      expect(
        await DatabaseHelper.instance.queryRowCount(
          SqfExpenseSmallCategory.tableName,
        ),
        20,
      );
      expect(
        await DatabaseHelper.instance.queryRowCount(
          SqfIncomeBigCategory.tableName,
        ),
        2,
      );
      expect(
        await DatabaseHelper.instance.queryRowCount(
          SqfIncomeSmallCategory.tableName,
        ),
        4,
      );
      // バッチ実行履歴の初期レコードも入り直す
      expect(
        await DatabaseHelper.instance.queryRowCount(SqfBatchHistory.tableName),
        1,
      );
    });

    test('DB更新カウンタがインクリメントされ、各画面が再取得される', () async {
      final container = createContainer();
      // autoDisposeなので購読を張ってから検証する
      final dbCount = listenUpdateDBCount(container);
      final usecase = container.read(dataManagementUsecaseProvider);
      expect(dbCount.read(), 0);

      await usecase.deleteAllData();

      expect(dbCount.read(), 1);
    });
  });

  group('exportDatabaseFile', () {
    test('DBファイルが存在しないならAppExceptionを投げる', () async {
      final container = createContainer();
      final usecase = container.read(dataManagementUsecaseProvider);
      // setUp の resetDatabase 直後はファイルが消えている（次のDBアクセスまで作られない）
      expect(File(await currentDatabasePath()).existsSync(), isFalse);

      await expectLater(
        () => usecase.exportDatabaseFile(),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            'データベースファイルが見つかりません',
          ),
        ),
      );
    });
  });
}
