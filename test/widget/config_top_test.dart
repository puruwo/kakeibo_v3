// 設定画面（lib/view/config/）のWidget結合テスト
//
// 設定項目の一覧表示と、集計期間の設定ダイアログ（SharedPreferencesへの保存）、
// データ削除の確認ダイアログまでを見る。
// 実削除・エクスポートは実DBやプラットフォーム機能に繋がるため実行しない。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/view/config/config_top.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/widget_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // 集計設定はSharedPreferencesに保存されるためモックを初期化する
    SharedPreferences.setMockInitialValues({});
  });

  /// 集計期間の設定ダイアログを開く
  Future<void> openAggregationDialog(WidgetTester tester) async {
    await tester.tap(find.text('集計期間を設定する'));
    await pumpTimes(tester);
  }

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

  testWidgets('「集計期間を設定する」で現在の設定値入りのダイアログが開く', (tester) async {
    await pumpApp(tester, home: const ConfigTop());
    await pumpTimes(tester);

    await openAggregationDialog(tester);

    expect(find.text('集計期間を設定'), findsOneWidget);
    expect(find.text('毎月'), findsOneWidget);
    expect(find.text('日はじまり'), findsOneWidget);
    expect(find.text('年度は'), findsOneWidget);
    expect(find.text('月から'), findsOneWidget);
    // 未保存なので既定値（開始日25日・開始月4月）が入る
    expect(find.text('25'), findsWidgets);
    expect(find.text('4'), findsWidgets);
  });

  testWidgets('集計開始日を変えて保存→確認OKでSharedPreferencesへ保存される', (tester) async {
    await pumpApp(tester, home: const ConfigTop());
    await pumpTimes(tester);
    await openAggregationDialog(tester);

    // 開始日のドロップダウン（1つ目）を開いて「26」を選ぶ
    // （メニューは初期選択の25付近にスクロールした状態で開くため近い値を選ぶ）
    await tester.tap(find.byType(DropdownMenu<int>).at(0));
    await pumpTimes(tester);
    await tester.ensureVisible(find.text('26').last);
    await pumpTimes(tester);
    await tester.tap(find.text('26').last);
    await pumpTimes(tester);

    await tester.tap(find.text('保存'));
    await pumpTimes(tester);

    // 過去の記録も再計算される旨の確認ダイアログを挟む
    expect(find.text('集計期間の変更'), findsOneWidget);
    expect(find.text('過去の記録もすべて新しい区切りで再計算されます。\n変更しますか？'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await pumpTimes(tester);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('aggregation_start_day'), 26);
    // 開始月は触っていないので既定値のまま保存される
    expect(prefs.getInt('aggregation_start_month'), 4);
    expect(find.text('集計期間の設定を変更しました'), findsOneWidget);

    await waitForSnackBarDismissed(tester);
  });

  testWidgets('確認ダイアログをキャンセルすると集計設定は保存されない', (tester) async {
    await pumpApp(tester, home: const ConfigTop());
    await pumpTimes(tester);
    await openAggregationDialog(tester);

    await tester.tap(find.byType(DropdownMenu<int>).at(0));
    await pumpTimes(tester);
    await tester.ensureVisible(find.text('26').last);
    await pumpTimes(tester);
    await tester.tap(find.text('26').last);
    await pumpTimes(tester);

    await tester.tap(find.text('保存'));
    await pumpTimes(tester);
    // 確認ダイアログ側のキャンセル（設定ダイアログのキャンセルと同名なので最後を選ぶ）
    await tester.tap(find.text('キャンセル').last);
    await pumpTimes(tester);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('aggregation_start_day'), isNull);
    expect(prefs.getInt('aggregation_start_month'), isNull);
    // 設定ダイアログは開いたまま
    expect(find.text('集計期間を設定'), findsOneWidget);
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
