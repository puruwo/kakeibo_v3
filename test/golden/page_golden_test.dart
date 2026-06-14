import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view/year_page/fixed_cost_button_area/fixed_cost_registration_list_page/fixed_cost_registration_list_page.dart';

import 'db_harness.dart';
import 'golden_helper.dart';
import 'page_harness.dart';

const _pageTimeout = Timeout(Duration(seconds: 90));

void main() {
  setUpAll(() {
    initDbHarness();
  });

  Future<void> pumpPage(WidgetTester tester, Widget page, String name) async {
    await loadAppFonts();
    tester.view.physicalSize = const Size(375 * 3.0, 812 * 3.0);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: repoOverrides(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(extensions: const [AppColors.light]),
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData.dark().copyWith(
            appBarTheme: const AppBarTheme(
              scrolledUnderElevation: 0,
              elevation: 0,
            ),
            extensions: const [AppColors.dark],
          ),
          home: page,
        ),
      ),
    );
    // 実DB I/O(ffi)は runAsync でないと完了しない。runAsync で実非同期を
    // 進め、pump で再描画する、を数サイクル繰り返す（ネスト非同期を解決）。
    // pumpAndSettle はグラフ/スピナーのアニメで止まらないため使わない。
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/page_$name.png'),
    );
  }

  testWidgets('FixedCostRegistrationListPage', timeout: _pageTimeout, (tester) async {
    await pumpPage(tester, const FixedCostRegistrationListPage(), 'fixed_cost_list');
  });

  testWidgets('CategorySettingPage', timeout: _pageTimeout, (tester) async {
    await pumpPage(tester, const CategorySettingPage(), 'category_setting');
  });
}
