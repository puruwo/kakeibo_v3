// 設定画面（lib/view/config/）のWidget結合テスト
//
// 設定項目の一覧表示と、集計期間の設定ページへの遷移（ページ自体の検証は
// aggregation_setting_page_test.dart）、データ削除の確認ダイアログまでを見る。
// 実削除・エクスポートは実DBやプラットフォーム機能に繋がるため実行しない。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/view/config/aggregation_setting_page.dart';
import 'package:kakeibo/view/config/config_top.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/widget_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // 集計設定はSharedPreferencesに保存されるためモックを初期化する
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('設定項目が2つのグループに分かれて並ぶ', (tester) async {
    await pumpApp(tester, home: const ConfigTop());
    await pumpTimes(tester);

    expect(find.text('設定'), findsOneWidget); // AppBar
    // AppContentsHeader はアイコン無しのとき見出し頭に半角スペースを足す
    expect(find.text(' 設定画面'), findsOneWidget);
    expect(find.text('入力履歴をエクスポートする'), findsOneWidget);
    expect(find.text('集計期間を設定する'), findsOneWidget);

    expect(find.text(' データ管理'), findsOneWidget);
    expect(find.text('データベースを書き出す'), findsOneWidget);
    expect(find.text('すべてのデータを削除する'), findsOneWidget);
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
