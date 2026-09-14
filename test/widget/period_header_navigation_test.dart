// 3タブの期間ヘッダーの操作（KP-025）のWidget結合テスト
//
// - 全体・月間分析: 矢印で1期間ずつ送れること
// - 履歴: ラベルのタップで暦月ピッカーが開き、適用でその月へ飛ぶこと
// - タブの再タップで現在の期間へ戻ること（下層ページが無いとき）
// 基準シナリオのシステム日時は 2025/7/6（開始日25日・開始月4月）。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/view/component/app_period_header.dart';
import 'package:kakeibo/view/foundation.dart';
import 'package:kakeibo/view/historical_calendar_page/expense_history_page.dart';
import 'package:kakeibo/view/monthly_page/monthly_page.dart';
import 'package:kakeibo/view/year_page/year_page.dart';

import '../helper/fake_repositories.dart';
import '../helper/widget_test_helper.dart';

/// 画面に出ている期間ヘッダー（IndexedStack の非表示タブは除く）
Finder _header({String? subLabel, bool matchSubLabel = true}) =>
    find.byWidgetPredicate(
      (w) =>
          w is AppPeriodHeader &&
          (!matchSubLabel || w.subLabel == subLabel),
    );

AppPeriodHeader _headerWidget(WidgetTester tester, Finder header) =>
    tester.widget<AppPeriodHeader>(header);

Future<void> _tapArrow(WidgetTester tester, Finder header, String key) async {
  await tester.tap(
    find.descendant(of: header, matching: find.byKey(ValueKey(key))),
  );
  await pumpTimes(tester);
}

void main() {
  group('ヘッダーの中央揃え', () {
    // 全体タブは3タブで最も長いラベル。幅の狭い端末でも左へずれずに画面中央に置かれること
    testWidgets('全体タブの長いラベルでも、幅390の画面の中央に置かれる', (tester) async {
      await pumpApp(tester, home: const YearPage());
      await pumpTimes(tester);

      final center = tester.getCenter(_header(matchSubLabel: false)).dx;
      expect(center, closeTo(kTestScreenSize.width / 2, 0.5));
    });

    testWidgets('月間分析・履歴のヘッダーも画面の中央に置かれる', (tester) async {
      await pumpApp(tester, home: const MonthlyPage());
      await pumpTimes(tester);
      expect(
        tester.getCenter(_header(subLabel: '生活収支')).dx,
        closeTo(kTestScreenSize.width / 2, 0.5),
      );

      await pumpApp(tester, home: const ExpenseHistoryPage());
      await pumpTimes(tester);
      expect(
        tester.getCenter(_header()).dx,
        closeTo(kTestScreenSize.width / 2, 0.5),
      );
    });
  });

  group('全体タブ', () {
    testWidgets('矢印で1年度ずつ送り、逆向きで元の年度に戻る', (tester) async {
      await pumpApp(tester, home: const YearPage());
      await pumpTimes(tester);

      final header = _header(matchSubLabel: false);
      final initial = _headerWidget(tester, header);
      expect(initial.subLabelIsNumeric, isTrue);

      await _tapArrow(tester, header, 'period_header_next');
      final next = _headerWidget(tester, header);
      expect(next.label, isNot(initial.label));
      expect(next.subLabel, isNot(initial.subLabel));

      await _tapArrow(tester, header, 'period_header_previous');
      final back = _headerWidget(tester, header);
      expect(back.label, initial.label);
      expect(back.subLabel, initial.subLabel);
    });

    testWidgets('期間移動の読み込み中もヘッダーは消えない（前の期間を出したままフェードで切り替える）', (
      tester,
    ) async {
      await pumpApp(tester, home: const YearPage());
      await pumpTimes(tester);

      final header = _header(matchSubLabel: false);
      await tester.tap(
        find.descendant(
          of: header,
          matching: find.byKey(const ValueKey('period_header_next')),
        ),
      );
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(header, findsOneWidget, reason: '再読み込み中に空のヘッダーへ切り替えない');
      }
      await pumpTimes(tester);
    });

    testWidgets('年度の途中の日付でも、ピッカーは表示中の年度で開き、次の年度を適用すると切り替わる', (
      tester,
    ) async {
      // 開始月4月なので、2026/2/10 は 2025年度の途中。選択日付の年（2026）と表示中の年度がずれる
      await pumpApp(
        tester,
        home: const YearPage(),
        systemDate: DateTime(2026, 2, 10),
      );
      await pumpTimes(tester);

      final header = _header(matchSubLabel: false);
      final initial = _headerWidget(tester, header);

      await tester.tap(find.text(initial.label));
      await pumpTimes(tester);
      expect(
        find.text(initial.subLabel!),
        findsNWidgets(2),
        reason: 'ヘッダーの2段目とピッカーの見出しが同じ年度（表示中の年度で開く）',
      );

      await tester.tap(find.byKey(const ValueKey('year_month_picker_next')));
      await pumpTimes(tester);
      await tester.tap(find.text('適用'));
      await pumpTimes(tester);

      final applied = _headerWidget(tester, header);
      expect(applied.subLabel, isNot(initial.subLabel));
      expect(applied.label, isNot(initial.label));
    });
  });

  group('月間分析タブ', () {
    testWidgets('矢印で1月度ずつ送り、逆向きで元の月度に戻る', (tester) async {
      await pumpApp(tester, home: const MonthlyPage());
      await pumpTimes(tester);

      final header = _header(subLabel: '生活収支');
      final initial = _headerWidget(tester, header).label;

      await _tapArrow(tester, header, 'period_header_previous');
      expect(_headerWidget(tester, header).label, isNot(initial));

      await _tapArrow(tester, header, 'period_header_next');
      expect(_headerWidget(tester, header).label, initial);
    });

    testWidgets('期間移動の読み込み中もラベルは空にならない', (tester) async {
      await pumpApp(tester, home: const MonthlyPage());
      await pumpTimes(tester);

      final header = _header(subLabel: '生活収支');
      final initial = _headerWidget(tester, header).label;
      await tester.tap(
        find.descendant(
          of: header,
          matching: find.byKey(const ValueKey('period_header_previous')),
        ),
      );
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        final label = _headerWidget(tester, header).label;
        expect(
          label == initial || label.isNotEmpty,
          isTrue,
          reason: '再読み込み中は前の月度のラベルを出したままにする',
        );
        expect(label, isNotEmpty);
      }
      await pumpTimes(tester);
    });
  });

  group('履歴タブ', () {
    testWidgets('ラベルのタップで暦月ピッカーが開き、次へ→適用で翌月へ飛ぶ', (tester) async {
      await pumpApp(tester, home: const ExpenseHistoryPage());
      await pumpTimes(tester);

      expect(find.text('2025年 7月'), findsOneWidget);

      await tester.tap(find.text('2025年 7月'));
      await pumpTimes(tester);
      expect(find.text('今月に戻す'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('year_month_picker_next')));
      await pumpTimes(tester);
      await tester.tap(find.text('適用'));
      await pumpTimes(tester);

      expect(find.text('今月に戻す'), findsNothing);
      expect(find.text('2025年 8月'), findsOneWidget);
    });

    testWidgets('ピッカーで数か月先を選んでも、その月へ一度に飛ぶ', (tester) async {
      await pumpApp(tester, home: const ExpenseHistoryPage());
      await pumpTimes(tester);

      await tester.tap(find.text('2025年 7月'));
      await pumpTimes(tester);
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const ValueKey('year_month_picker_next')));
        await pumpTimes(tester, times: 3);
      }
      await tester.tap(find.text('適用'));
      await pumpTimes(tester);

      expect(find.text('2025年 10月'), findsOneWidget);
    });
  });

  group('タブの再タップ（Foundation）', () {
    // 起動時に自動表示される記録モーダルがカテゴリーを引くため、最低限のマスタを積む
    TestFakes buildFakes() => TestFakes(
      expenseSmallCategory: FakeExpenseSmallCategoryRepository(
        initialRecords: const [
          ExpenseSmallCategoryEntity(
            id: 10,
            smallCategoryOrderKey: 1,
            bigCategoryKey: 1,
            displayedOrderInBig: 1,
            smallCategoryName: '食費',
            defaultDisplayed: 1,
          ),
        ],
      ),
      expenseBigCategory: FakeExpenseBigCategoryRepository(
        initialRecords: const [
          ExpenseBigCategoryEntity(
            id: 1,
            colorCode: 'FFAA00',
            bigCategoryName: '生活費',
            resourcePath: 'assets/images/icon_meal.svg',
            displayOrder: 1,
            isDisplayed: 1,
          ),
        ],
      ),
    );

    testWidgets('月間分析: 別の月度を表示中に再タップすると今月度に戻る', (tester) async {
      await pumpApp(tester, home: const Foundation(), fakes: buildFakes());
      await pumpTimes(tester);
      await closeRegisterModal(tester);

      await tester.tap(find.text('月間分析'));
      await pumpTimes(tester);

      final header = _header(subLabel: '生活収支');
      final current = _headerWidget(tester, header).label;

      await _tapArrow(tester, header, 'period_header_previous');
      expect(_headerWidget(tester, header).label, isNot(current));

      await tester.tap(find.text('月間分析'));
      await pumpTimes(tester);
      expect(_headerWidget(tester, header).label, current);
    });

    testWidgets('履歴: 別の月を表示中に再タップすると今月に戻る', (tester) async {
      await pumpApp(tester, home: const Foundation(), fakes: buildFakes());
      await pumpTimes(tester);
      await closeRegisterModal(tester);

      await tester.tap(find.text('履歴'));
      await pumpTimes(tester);
      expect(find.text('2025年 7月'), findsOneWidget);

      await _tapArrow(tester, _header(), 'period_header_next');
      expect(find.text('2025年 8月'), findsOneWidget);

      await tester.tap(find.text('履歴'));
      await pumpTimes(tester);
      expect(find.text('2025年 7月'), findsOneWidget);
    });
  });
}
