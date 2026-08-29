// 集計期間設定ページ（lib/view/config/aggregation_setting_page.dart）のWidget結合テスト（KP-005 B群）
//
// 初期表示・ステッパー操作とプレビュー連動・保存フロー（確認ダイアログ→ユースケース）を見る。
// 期間計算の正しさは AggregationPeriodRule のUTが担当なので、ここでは表示文字列の連動だけを見る。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/aggregation_settings/aggregation_settings_usecase.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/config/aggregation_setting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/widget_test_helper.dart';

/// ページを push で開くための起点画面（pop・スナックバー表示を本番と同じ経路で見るため）
class _Launcher extends StatelessWidget {
  const _Launcher();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AggregationSettingPage(
                originalStartDay: 25,
                originalStartMonth: 4,
              ),
            ),
          ),
          child: const Text('開く'),
        ),
      ),
    );
  }
}

/// 保存が必ず失敗するユースケース（B-3-4）
class _FailingAggregationSettingsUsecase extends AggregationSettingsUsecase {
  _FailingAggregationSettingsUsecase(super.ref);

  @override
  Future<void> save({required int startDay, required int startMonth}) async {
    throw Exception('保存失敗');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // 今日=2026/8/29・保存値=25日/4月 → 今月 8/25〜9/24・今年度 2026/4/25〜2027/4/24
  final systemDate = DateTime(2026, 8, 29);

  const dayValue = ValueKey('aggregation_day_value');
  const dayInc = ValueKey('aggregation_day_increment');
  const dayDec = ValueKey('aggregation_day_decrement');
  const monthValue = ValueKey('aggregation_month_value');
  const monthInc = ValueKey('aggregation_month_increment');
  const monthDec = ValueKey('aggregation_month_decrement');
  const previewMonth = ValueKey('aggregation_preview_month');
  const previewYear = ValueKey('aggregation_preview_year');

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> openPage(
    WidgetTester tester, {
    List<Override> overrides = const [],
  }) async {
    await pumpApp(
      tester,
      home: const _Launcher(),
      systemDate: systemDate,
      overrides: overrides,
    );
    await pumpTimes(tester);
    await tester.tap(find.text('開く'));
    await pumpTimes(tester);
  }

  /// 表示中の文字列。ステッパーの値は入力欄（TextField）、プレビューは Text
  String textOf(WidgetTester tester, Key key) {
    final finder = find.byKey(key);
    final widget = tester.widget(finder);
    if (widget is TextField) return widget.controller!.text;
    return (widget as Text).data!;
  }

  /// 増減ボタンが非活性（IgnorePointer）か
  bool isStepDisabled(WidgetTester tester, Key key) {
    final ignore = tester.widget<IgnorePointer>(
      find.descendant(
        of: find.byKey(key),
        matching: find.byType(IgnorePointer),
      ),
    );
    return ignore.ignoring;
  }

  bool isSaveEnabled(WidgetTester tester) =>
      tester.widget<MainButton>(find.byType(MainButton)).onPressed != null;

  Future<void> tapTimes(WidgetTester tester, Key key, int times) async {
    for (var i = 0; i < times; i++) {
      await tester.tap(find.byKey(key), warnIfMissed: false);
      await tester.pump();
    }
  }

  group('初期表示（B-1）', () {
    testWidgets('AppBarのタイトルとサブテキスト・保存値・プレビュー・注意文が表示される', (tester) async {
      await openPage(tester);

      expect(find.text('集計期間'), findsOneWidget);
      expect(find.text('家計の区切りを決めます'), findsOneWidget);
      expect(find.text('月の開始日'), findsOneWidget);
      expect(find.text('年度の開始月'), findsOneWidget);
      expect(textOf(tester, dayValue), '25');
      expect(textOf(tester, monthValue), '4');
      expect(textOf(tester, previewMonth), '8/25 〜 9/24');
      expect(textOf(tester, previewYear), '2026/4/25 〜 2027/4/24');
      expect(find.text('変更すると過去の記録もすべて新しい区切りで再計算されます'), findsOneWidget);
    });

    testWidgets('変更がなければ保存ボタンは非活性', (tester) async {
      await openPage(tester);

      expect(isSaveEnabled(tester), isFalse);
    });
  });

  group('ステッパー操作（B-2）', () {
    testWidgets('日の＋で26になりプレビューが更新され保存ボタンが活性になる', (tester) async {
      await openPage(tester);

      await tapTimes(tester, dayInc, 1);

      expect(textOf(tester, dayValue), '26');
      expect(textOf(tester, previewMonth), '8/26 〜 9/25');
      // 年度の基準日にも開始日が効く
      expect(textOf(tester, previewYear), '2026/4/26 〜 2027/4/25');
      expect(isSaveEnabled(tester), isTrue);
    });

    testWidgets('日の−で24になりプレビューは前月始まりに変わる', (tester) async {
      await openPage(tester);

      await tapTimes(tester, dayDec, 1);

      expect(textOf(tester, dayValue), '24');
      // 8/29 は 24日以降なので 8/24〜9/23（開始日以降の分岐）
      expect(textOf(tester, previewMonth), '8/24 〜 9/23');
    });

    testWidgets('日を28まで上げると＋が非活性になりそれ以上増えない', (tester) async {
      await openPage(tester);

      await tapTimes(tester, dayInc, 3);
      expect(textOf(tester, dayValue), '28');
      expect(isStepDisabled(tester, dayInc), isTrue);
      expect(isStepDisabled(tester, dayDec), isFalse);

      await tapTimes(tester, dayInc, 1);
      expect(textOf(tester, dayValue), '28');
      expect(textOf(tester, previewMonth), '8/28 〜 9/27');
    });

    testWidgets('日を1まで下げると−が非活性になりプレビューは暦月になる', (tester) async {
      await openPage(tester);

      await tapTimes(tester, dayDec, 24);
      expect(textOf(tester, dayValue), '1');
      expect(isStepDisabled(tester, dayDec), isTrue);
      expect(textOf(tester, previewMonth), '8/1 〜 8/31');

      await tapTimes(tester, dayDec, 1);
      expect(textOf(tester, dayValue), '1');
    });

    testWidgets('月の＋で5になり年度プレビューだけが変わる', (tester) async {
      await openPage(tester);

      await tapTimes(tester, monthInc, 1);

      expect(textOf(tester, monthValue), '5');
      expect(textOf(tester, previewYear), '2026/5/25 〜 2027/5/24');
      expect(textOf(tester, previewMonth), '8/25 〜 9/24');
    });

    testWidgets('月を12まで上げると＋が非活性になり年度は前年12月始まりになる', (tester) async {
      await openPage(tester);

      await tapTimes(tester, monthInc, 8);
      expect(textOf(tester, monthValue), '12');
      expect(isStepDisabled(tester, monthInc), isTrue);
      // 8/29 は 12/25 より前なので前年度（2025/12/25〜2026/12/24）
      expect(textOf(tester, previewYear), '2025/12/25 〜 2026/12/24');

      await tapTimes(tester, monthInc, 1);
      expect(textOf(tester, monthValue), '12');
    });

    testWidgets('月を1まで下げると−が非活性になる', (tester) async {
      await openPage(tester);

      await tapTimes(tester, monthDec, 3);
      expect(textOf(tester, monthValue), '1');
      expect(isStepDisabled(tester, monthDec), isTrue);

      await tapTimes(tester, monthDec, 1);
      expect(textOf(tester, monthValue), '1');
    });

    testWidgets('日を26にして25に戻すと保存ボタンは再び非活性になる', (tester) async {
      await openPage(tester);

      await tapTimes(tester, dayInc, 1);
      expect(isSaveEnabled(tester), isTrue);
      await tapTimes(tester, dayDec, 1);

      expect(textOf(tester, dayValue), '25');
      expect(isSaveEnabled(tester), isFalse);
    });
  });

  group('直接入力（B-2 追加）', () {
    testWidgets('日の入力欄に15と入力するとプレビューが即時更新される', (tester) async {
      await openPage(tester);

      await tester.enterText(find.byKey(dayValue), '15');
      await tester.pump();

      expect(textOf(tester, dayValue), '15');
      expect(textOf(tester, previewMonth), '8/15 〜 9/14');
      expect(isSaveEnabled(tester), isTrue);
    });

    testWidgets('日の入力欄に31と入力すると上限28に丸められる', (tester) async {
      await openPage(tester);

      await tester.enterText(find.byKey(dayValue), '31');
      await tester.pump();

      expect(textOf(tester, dayValue), '28');
      expect(textOf(tester, previewMonth), '8/28 〜 9/27');
      expect(isStepDisabled(tester, dayInc), isTrue);
    });

    testWidgets('日の入力欄に0と入力してフォーカスを外すと下限1になる', (tester) async {
      await openPage(tester);

      await tester.enterText(find.byKey(dayValue), '0');
      await tester.pump();
      // 入力途中なので 0 のまま保留される
      expect(textOf(tester, dayValue), '0');
      expect(textOf(tester, previewMonth), '8/25 〜 9/24');

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(textOf(tester, dayValue), '1');
      expect(textOf(tester, previewMonth), '8/1 〜 8/31');
    });

    testWidgets('日の入力欄を空にしてフォーカスを外すと元の値に戻る', (tester) async {
      await openPage(tester);

      await tester.enterText(find.byKey(dayValue), '');
      await tester.pump();
      // 別の場所をタップしてフォーカスを外す
      await tester.tap(find.text('月の開始日'));
      await tester.pump();

      expect(textOf(tester, dayValue), '25');
      expect(isSaveEnabled(tester), isFalse);
    });

    testWidgets('月の入力欄に13と入力すると上限12に丸められる', (tester) async {
      await openPage(tester);

      await tester.enterText(find.byKey(monthValue), '13');
      await tester.pump();

      expect(textOf(tester, monthValue), '12');
      expect(textOf(tester, previewYear), '2025/12/25 〜 2026/12/24');
    });

    testWidgets('入力で変えた値はボタン操作にも引き継がれる', (tester) async {
      await openPage(tester);

      await tester.enterText(find.byKey(dayValue), '10');
      await tester.pump();
      await tapTimes(tester, dayInc, 1);

      expect(textOf(tester, dayValue), '11');
      expect(textOf(tester, previewMonth), '8/11 〜 9/10');
    });
  });

  group('保存フロー（B-3）', () {
    testWidgets('保存するで確認ダイアログが開き、キャンセルすると保存されずページに留まる', (tester) async {
      await openPage(tester);
      await tapTimes(tester, dayInc, 1);

      await tester.tap(find.text('保存する'));
      await pumpTimes(tester);

      expect(find.text('集計期間の変更'), findsOneWidget);
      expect(find.text('過去の記録もすべて新しい区切りで再計算されます。\n変更しますか？'), findsOneWidget);

      await tester.tap(find.text('キャンセル'));
      await pumpTimes(tester);

      expect(find.byType(AggregationSettingPage), findsOneWidget);
      expect(textOf(tester, dayValue), '26');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('aggregation_start_day'), isNull);
    });

    testWidgets('確認を承認すると26日/4月で保存され、前の画面に戻って成功スナックバーが出る', (tester) async {
      await openPage(tester);
      await tapTimes(tester, dayInc, 1);

      await tester.tap(find.text('保存する'));
      await pumpTimes(tester);
      await tester.tap(find.text('OK'));
      await pumpTimes(tester);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('aggregation_start_day'), 26);
      // 開始月は触っていないので既定値のまま保存される
      expect(prefs.getInt('aggregation_start_month'), 4);
      expect(find.byType(AggregationSettingPage), findsNothing);
      expect(find.text('集計期間の設定を変更しました'), findsOneWidget);

      await waitForSnackBarDismissed(tester);
    });

    testWidgets('保存が失敗したらページに留まり失敗スナックバーが出る', (tester) async {
      await openPage(
        tester,
        overrides: [
          aggregationSettingsUsecaseProvider.overrideWith(
            _FailingAggregationSettingsUsecase.new,
          ),
        ],
      );
      await tapTimes(tester, dayInc, 1);

      await tester.tap(find.text('保存する'));
      await pumpTimes(tester);
      await tester.tap(find.text('OK'));
      await pumpTimes(tester);

      expect(find.byType(AggregationSettingPage), findsOneWidget);
      expect(find.textContaining('設定の変更に失敗しました'), findsOneWidget);

      await waitForSnackBarDismissed(tester);
    });

    testWidgets('戻るボタンは変更があっても確認なしで破棄して戻る', (tester) async {
      await openPage(tester);
      await tapTimes(tester, dayInc, 1);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await pumpTimes(tester);

      expect(find.byType(AggregationSettingPage), findsNothing);
      expect(find.text('集計期間の変更'), findsNothing);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('aggregation_start_day'), isNull);
    });
  });
}
