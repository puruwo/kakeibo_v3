// test/implements_daily_expense_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/domain/daily_expense_entity/daily_expense_entity.dart';
import 'package:kakeibo/repository/daily_expense_repository.dart';
import 'fake_datebase_helper/fake_database_helper.dart';

void main() {
  // テスト前にグローバルな db をフェイクに差し替え
  setUp(() {
    db = FakeDatabaseHelper();
  });

  group('ImplementsDailyExpenseRepository.fetch', () {
    test('should return DailyExpenseEntity from the fake database', () async {
      // テスト用の日付を設定
      final testDate = DateTime(2025, 03, 15);
      // 日付をyyyyMMdd形式に変換
      final expectedDateStr = DateFormat('yyyyMMdd').format(testDate);

      // Repositoryのインスタンスを作成
      final repository = ImplementsDailyExpenseRepository();

      // fetchメソッドの呼び出し
      final DailyExpenseEntity result = await repository.fetch(dateTime: testDate);

      // 結果の検証（DailyExpenseEntityのフィールドに合わせて調整してください）
      expect(result.dateTime, equals(testDate));
      expect(result.totalExpense, equals(100)); 
    });
  });
}