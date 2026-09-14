// 期間ヘッダー（AppPeriodHeader）のWidgetテスト（KP-025）
//
// - 移動範囲の判定（2000年〜今年＋10年）が端で false になること
// - 端では矢印が非活性（IconOnlyButton の onTap: null）になること
// - ラベル・矢印（円の内側・外側）のタップで各コールバックが呼ばれること
// を固定する。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/view/component/app_period_header.dart';
import 'package:kakeibo/view/component/button_util.dart';

import '../helper/widget_test_helper.dart';

/// コールバックの呼び出し回数
class _Calls {
  int label = 0;
  int previous = 0;
  int next = 0;
}

Future<_Calls> _pumpHeader(
  WidgetTester tester, {
  String? subLabel,
  bool enablePrevious = true,
  bool enableNext = true,
}) async {
  final calls = _Calls();
  await pumpApp(
    tester,
    home: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AppPeriodHeader(
          label: '2026年 8 - 9月',
          subLabel: subLabel,
          onTapLabel: () => calls.label++,
          onPrevious: enablePrevious ? () => calls.previous++ : null,
          onNext: enableNext ? () => calls.next++ : null,
        ),
      ),
    ),
  );
  await pumpTimes(tester, times: 3);
  return calls;
}

IconOnlyButton _arrow(WidgetTester tester, String key) =>
    tester.widget<IconOnlyButton>(
      find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.byType(IconOnlyButton),
      ),
    );

void main() {
  group('移動範囲の判定', () {
    test('月: 2000年1月からは前へ進めず、2月からは進める', () {
      expect(
        canShiftPeriodMonth(year: 2000, month: 1, delta: -1, maxYear: 2035),
        isFalse,
      );
      expect(
        canShiftPeriodMonth(year: 2000, month: 2, delta: -1, maxYear: 2035),
        isTrue,
      );
    });

    test('月: 最大年の12月からは次へ進めず、11月からは進める', () {
      expect(
        canShiftPeriodMonth(year: 2035, month: 12, delta: 1, maxYear: 2035),
        isFalse,
      );
      expect(
        canShiftPeriodMonth(year: 2035, month: 11, delta: 1, maxYear: 2035),
        isTrue,
      );
    });

    test('年度: 2000年からは前へ、最大年からは次へ進めない', () {
      expect(canShiftPeriodYear(year: 2000, delta: -1, maxYear: 2035), isFalse);
      expect(canShiftPeriodYear(year: 2001, delta: -1, maxYear: 2035), isTrue);
      expect(canShiftPeriodYear(year: 2035, delta: 1, maxYear: 2035), isFalse);
      expect(canShiftPeriodYear(year: 2034, delta: 1, maxYear: 2035), isTrue);
    });

    test('最大年の既定は今年＋10年（ピッカーと同じ）', () {
      expect(appPeriodMaxYear(), DateTime.now().year + 10);
    });
  });

  group('AppPeriodHeader', () {
    testWidgets('ラベルと2段目が出て、▼（プルダウン）は出ない', (tester) async {
      await _pumpHeader(tester, subLabel: '生活収支');

      expect(find.text('2026年 8 - 9月'), findsOneWidget);
      expect(find.text('生活収支'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_down_rounded), findsNothing);
    });

    testWidgets('2段目が無いときはラベル1段だけ', (tester) async {
      await _pumpHeader(tester);

      final column = tester.widget<Column>(
        find.ancestor(
          of: find.text('2026年 8 - 9月'),
          matching: find.byType(Column),
        ).first,
      );
      expect(column.children, hasLength(1));
    });

    testWidgets('矢印は円の IconOnlyButton（直径24・枠なし）', (tester) async {
      await _pumpHeader(tester);

      final previous = _arrow(tester, 'period_header_previous');
      expect(previous.size, 24);
      expect(previous.iconSize, 16);
      expect(previous.bordered, isFalse);
      expect(previous.onTap, isNotNull);
    });

    testWidgets('端では onPrevious / onNext が null で矢印が非活性になる', (tester) async {
      await _pumpHeader(tester, enablePrevious: false);

      expect(_arrow(tester, 'period_header_previous').onTap, isNull);
      expect(_arrow(tester, 'period_header_next').onTap, isNotNull);
    });

    testWidgets('ラベルのタップで onTapLabel、矢印のタップで onPrevious / onNext が呼ばれる', (
      tester,
    ) async {
      final calls = await _pumpHeader(tester, subLabel: '生活収支');

      await tester.tap(find.text('2026年 8 - 9月'));
      await tester.tap(find.byKey(const ValueKey('period_header_previous')));
      await tester.tap(find.byKey(const ValueKey('period_header_next')));
      await tester.pump();

      expect(calls.label, 1);
      expect(calls.previous, 1);
      expect(calls.next, 1);
    });

    testWidgets('円の外側（タップ領域 40×48 の端）のタップでも矢印の操作になる', (tester) async {
      final calls = await _pumpHeader(tester);

      final area = find.byKey(const ValueKey('period_header_next'));
      await tester.tapAt(tester.getTopLeft(area) + const Offset(2, 2));
      await tester.pump();

      expect(calls.next, 1);
    });

    testWidgets('非活性の矢印はタップしても呼ばれない', (tester) async {
      final calls = await _pumpHeader(tester, enableNext: false);

      await tester.tap(find.byKey(const ValueKey('period_header_next')));
      await tester.pump();

      expect(calls.next, 0);
    });
  });
}
