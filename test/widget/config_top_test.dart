// 設定画面（lib/view/config/）のWidget結合テスト
//
// 設定項目の一覧表示と、集計期間の設定ページへの遷移（ページ自体の検証は
// aggregation_setting_page_test.dart）、データ削除の確認ダイアログまでを見る。
// 実削除・エクスポートは実DBやプラットフォーム機能に繋がるため実行しない。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view/config/aggregation_setting_page.dart';
import 'package:kakeibo/view/config/config_top.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthy_plan_home_page/monthly_plan_home_page.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/selected_datetime/analyze_page_selected_datetime.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/widget_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // 集計設定はSharedPreferencesに保存されるためモックを初期化する
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('設定項目が3つのグループに分かれて並ぶ', (tester) async {
    await pumpApp(tester, home: const ConfigTop());
    await pumpTimes(tester);

    expect(find.text('設定'), findsOneWidget); // AppBar
    // AppContentsHeader はアイコン無しのとき見出し頭に半角スペースを足す
    expect(find.text(' 設定画面'), findsOneWidget);
    expect(find.text('入力履歴をエクスポートする'), findsOneWidget);
    expect(find.text('集計期間を設定する'), findsOneWidget);
    expect(find.text('ダークモード'), findsOneWidget); // KP-013 のスイッチ行

    // KP-027: カテゴリー設定・毎月の予算への入口
    expect(find.text(' カテゴリーと予算'), findsOneWidget);
    expect(find.text('カテゴリーを設定する'), findsOneWidget);
    expect(find.text('毎月の予算を設定する'), findsOneWidget);

    expect(find.text(' データ管理'), findsOneWidget);
    expect(find.text('データベースを書き出す'), findsOneWidget);
    expect(find.text('すべてのデータを削除する'), findsOneWidget);
  });

  testWidgets('「カテゴリーを設定する」でカテゴリー設定が支出タブで開く', (tester) async {
    await pumpApp(tester, home: const ConfigTop());
    await pumpTimes(tester);

    await tester.tap(find.text('カテゴリーを設定する'));
    await pumpTimes(tester);

    expect(find.byType(CategorySettingPage), findsOneWidget);
    expect(
      tester
          .widget<CategorySettingPage>(find.byType(CategorySettingPage))
          .initialCategoryType,
      CategoryType.expense,
    );
  });

  testWidgets('「毎月の予算を設定する」は月間分析の選択月度を今月度へ戻してから開く', (tester) async {
    // 毎月の予算は月間分析の選択月度を対象にし、ページ内に月度の表示が無い。
    // 過去・未来の月度を選んだまま設定画面から開くと、どの月か分からないまま編集することになる
    await pumpApp(tester, home: const ConfigTop());
    await pumpTimes(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConfigTop)),
    );
    container
        .read(analyzePageSelectedDatetimeNotifierProvider.notifier)
        .updateState(DateTime(2025, 3, 1));

    await tester.tap(find.text('毎月の予算を設定する'));
    await pumpTimes(tester);

    expect(find.byType(MonthlyPlanHomePage), findsOneWidget);
    // システム日時（2025/7/6 固定）に戻っている
    expect(
      container.read(analyzePageSelectedDatetimeNotifierProvider),
      kTestSystemDate,
    );
  });

  testWidgets('「集計期間を設定する」で現在の設定値入りの設定ページへ遷移する（旧ダイアログは出ない）', (tester) async {
    // 保存済みの値がページの初期値として渡されることを見るため既定値以外を入れる
    SharedPreferences.setMockInitialValues({
      'aggregation_start_day': 10,
      'aggregation_start_month': 7,
    });
    await pumpApp(tester, home: const ConfigTop());
    await pumpTimes(tester);

    await tester.tap(find.text('集計期間を設定する'));
    await pumpTimes(tester);

    expect(find.byType(AggregationSettingPage), findsOneWidget);
    expect(find.text('集計期間'), findsOneWidget); // AppBar
    expect(find.byType(Dialog), findsNothing);
    expect(find.byKey(const ValueKey('aggregation_day_value')), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('「すべてのデータを削除する」で確認ダイアログが出てキャンセルで閉じる', (tester) async {
    await pumpApp(tester, home: const ConfigTop());
    await pumpTimes(tester);

    await tester.tap(find.text('すべてのデータを削除する'));
    await pumpTimes(tester);

    expect(find.text('すべてのデータを削除'), findsOneWidget);
    expect(
      find.text('支出・収入・固定費・予算などすべての記録を削除します。\nこの操作は取り消せません。本当に削除しますか？'),
      findsOneWidget,
    );

    // 実削除は実DBに繋がるため、キャンセルまでで確認する
    await tester.tap(find.text('キャンセル'));
    await pumpTimes(tester);

    expect(find.text('すべてのデータを削除'), findsNothing);
    // 削除は走っていないので完了スナックバーも出ない
    expect(find.text('すべてのデータを削除しました'), findsNothing);
  });
}
