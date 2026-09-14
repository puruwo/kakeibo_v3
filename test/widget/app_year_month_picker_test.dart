// 年月度・年度ピッカー（showAppYearMonthPicker）のWidget結合テスト
//
// KP-022 で見た目をボタンルール・カード語彙へ揃えた。ここでは
// - ボタン行が MainButton（左 secondary・右 main）であること
// - 月送りが IconOnlyButton で、選択範囲の端では非活性（onTap: null）になること
// - 暗幕が scrim トークンの色であること
// - 「適用」「今月度に戻す」「次へ」の挙動が置換前と変わっていないこと
// を固定する。
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/component/app_year_month_picker.dart';
import 'package:kakeibo/view/component/button_util.dart';

import '../helper/widget_test_helper.dart';

/// ピッカーの戻り値を受け取る入れ物
class _PickerResult {
  DateTime? value;
  bool closed = false;
}

/// ピッカーを開くボタンだけを置いた画面を描画し、ピッカーを開く
///
/// システム日時は基準シナリオ（2025/7/6・開始日25日）なので、
/// 今月度は 2025/6/25〜2025/7/24（6月度）になる。
Future<_PickerResult> _pumpAndOpenPicker(
  WidgetTester tester, {
  required AppYearMonthPickerMode mode,
  required DateTime initialDateTime,
  ThemeMode themeMode = ThemeMode.light,
}) async {
  final result = _PickerResult();
  await pumpApp(
    tester,
    themeMode: themeMode,
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () async {
              result.value = await showAppYearMonthPicker(
                context: context,
                mode: mode,
                initialDateTime: initialDateTime,
              );
              result.closed = true;
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  // スライドイン（200ms）と期間の非同期取得を待つ
  await pumpTimes(tester);
  return result;
}

void main() {
  group('showAppYearMonthPicker（月度モード）', () {
    testWidgets('ボタン行は左に secondary「今月度に戻す」、右に main「適用」の MainButton', (
      tester,
    ) async {
      await _pumpAndOpenPicker(
        tester,
        mode: AppYearMonthPickerMode.yearMonth,
        initialDateTime: DateTime(2025, 6, 25),
      );

      final reset = tester.widget<MainButton>(
        find.widgetWithText(MainButton, '今月度に戻す'),
      );
      final confirm = tester.widget<MainButton>(
        find.widgetWithText(MainButton, '適用'),
      );
      expect(reset.buttonType, ButtonColorType.secondary);
      expect(confirm.buttonType, ButtonColorType.main);
      expect(
        tester.getCenter(find.text('今月度に戻す')).dx,
        lessThan(tester.getCenter(find.text('適用')).dx),
        reason: '並列2ボタンは左 Secondary・右 Primary（ボタンルール §4）',
      );
      expect(find.byType(CupertinoButton), findsNothing);
    });

    testWidgets('暗幕は scrim トークンの色で描く', (tester) async {
      await _pumpAndOpenPicker(
        tester,
        mode: AppYearMonthPickerMode.yearMonth,
        initialDateTime: DateTime(2025, 6, 25),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Container && w.color == AppColors.light.scrim,
        ),
        findsOneWidget,
      );
    });

    testWidgets('月送りは IconOnlyButton で、範囲の先頭（2000年1月度）では前へだけ非活性', (
      tester,
    ) async {
      await _pumpAndOpenPicker(
        tester,
        mode: AppYearMonthPickerMode.yearMonth,
        initialDateTime: DateTime(2000, 1, 31),
      );

      final previous = tester.widget<IconOnlyButton>(
        find.byKey(const ValueKey('year_month_picker_previous')),
      );
      final next = tester.widget<IconOnlyButton>(
        find.byKey(const ValueKey('year_month_picker_next')),
      );
      expect(previous.onTap, isNull, reason: '非活性は onTap: null で表す（ボタンルール §3）');
      expect(next.onTap, isNotNull);
    });

    testWidgets('範囲の末尾（maxYear の12月度）では次へだけ非活性', (tester) async {
      await _pumpAndOpenPicker(
        tester,
        mode: AppYearMonthPickerMode.yearMonth,
        // maxYear の既定は「今年＋10」
        initialDateTime: DateTime(DateTime.now().year + 10, 12, 31),
      );

      final previous = tester.widget<IconOnlyButton>(
        find.byKey(const ValueKey('year_month_picker_previous')),
      );
      final next = tester.widget<IconOnlyButton>(
        find.byKey(const ValueKey('year_month_picker_next')),
      );
      expect(previous.onTap, isNotNull);
      expect(next.onTap, isNull);
    });

    testWidgets('ダークではパネルの地が不透明の surfaceElevated2（半透明の cardSurface にしない）', (
      tester,
    ) async {
      await _pumpAndOpenPicker(
        tester,
        mode: AppYearMonthPickerMode.yearMonth,
        initialDateTime: DateTime(2025, 6, 25),
        themeMode: ThemeMode.dark,
      );

      final panel = find.byWidgetPredicate((w) {
        if (w is! Container) return false;
        final decoration = w.decoration;
        return decoration is BoxDecoration &&
            decoration.color == AppColors.dark.surfaceElevated2;
      });
      expect(
        panel,
        findsOneWidget,
        reason: 'ダークの cardSurface は半透明で、暗幕越しに下の画面が透けるため',
      );
      expect(AppColors.dark.surfaceElevated2.a, 1.0);
      expect(
        find.byWidgetPredicate(
          (w) => w is Container && w.color == AppColors.dark.scrim,
        ),
        findsOneWidget,
      );
    });

    testWidgets('「適用」で選択中の月度の月末日を返して閉じる', (tester) async {
      final result = await _pumpAndOpenPicker(
        tester,
        mode: AppYearMonthPickerMode.yearMonth,
        initialDateTime: DateTime(2025, 6, 25),
      );

      await tester.tap(find.text('適用'));
      await pumpTimes(tester);

      expect(result.closed, isTrue);
      expect(result.value, DateTime(2025, 6, 30));
      expect(find.text('適用'), findsNothing);
    });

    testWidgets('次へで1月度進めてから「適用」すると翌月の月末日を返す', (tester) async {
      final result = await _pumpAndOpenPicker(
        tester,
        mode: AppYearMonthPickerMode.yearMonth,
        initialDateTime: DateTime(2025, 6, 25),
      );

      await tester.tap(find.byKey(const ValueKey('year_month_picker_next')));
      await pumpTimes(tester);
      await tester.tap(find.text('適用'));
      await pumpTimes(tester);

      expect(result.value, DateTime(2025, 7, 31));
    });

    testWidgets('「今月度に戻す」でシステム日時の月度（6月度）に戻る', (tester) async {
      final result = await _pumpAndOpenPicker(
        tester,
        mode: AppYearMonthPickerMode.yearMonth,
        initialDateTime: DateTime(2024, 1, 31),
      );

      await tester.tap(find.text('今月度に戻す'));
      await pumpTimes(tester);
      await tester.tap(find.text('適用'));
      await pumpTimes(tester);

      expect(result.value, DateTime(2025, 6, 30));
    });
  });

  group('showAppYearMonthPicker（年度モード）', () {
    testWidgets('戻すボタンの文言は「今年度に戻す」の secondary', (tester) async {
      await _pumpAndOpenPicker(
        tester,
        mode: AppYearMonthPickerMode.year,
        initialDateTime: DateTime(2025, 1, 1),
      );

      final reset = tester.widget<MainButton>(
        find.widgetWithText(MainButton, '今年度に戻す'),
      );
      expect(reset.buttonType, ButtonColorType.secondary);
      expect(find.text('今月度に戻す'), findsNothing);
    });
  });
}
