import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/model/database_helper.dart';

import 'db_harness.dart';

void main() {
  test('DB opens via ffi and reports tables/seed', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    initDbHarness();
    final db = await DatabaseHelper.instance.database;
    expect(db, isNotNull);
    final tables = await db!.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
    );
    // ignore: avoid_print
    print('TABLES: ${tables.map((t) => t['name']).join(', ')}');
    // 既定カテゴリが入っているか
    for (final t in ['expense_big_category', 'fixed_cost_category', 'income_big_category']) {
      final exists = tables.any((row) => row['name'] == t);
      if (exists) {
        final rows = await db.rawQuery('SELECT COUNT(*) c FROM $t');
        // ignore: avoid_print
        print('$t rows: ${rows.first['c']}');
      }
    }
  });
}
