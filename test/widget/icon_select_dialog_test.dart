// カテゴリーアイコン選択シート（icon_select_dialog.dart）のWidget結合テスト
//
// KP-023 アイコンの一覧化: 支出40種・収入15種を分類付きで全提示し、
// 提示するアセットはすべて assets/images に実在する（DB に保存されるパスの実在性）。
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/dialog/icon_select_dialog.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';

import '../helper/widget_test_helper.dart';

void main() {
  List<String> namesOf(List<IconSection> sections) =>
      [for (final s in sections) ...s.assetNames];

  group('アイコン分類リスト', () {
    test('支出は40種・収入は15種で、重複がない', () {
      final expense = namesOf(expenseIconSections);
      final income = namesOf(incomeIconSections);
      expect(expense, hasLength(40));
      expect(income, hasLength(15));
      expect(expense.toSet(), hasLength(40));
      expect(income.toSet(), hasLength(15));
    });

    test('提示するアセットはすべて assets/images に実在する', () {
      final names = [
        ...namesOf(expenseIconSections),
        ...namesOf(incomeIconSections),
      ];
      final missing = names
          .where((n) => !File('assets/images/$n.svg').existsSync())
          .toList();
      expect(missing, isEmpty, reason: '存在しないアセット: $missing');
    });

    test('新規インストールの初期カテゴリーのアイコンは選択シートに含まれる', () {
      final seed = File('lib/model/sql_on_create.dart').readAsStringSync();
      final used = RegExp(r"assets/images/(icon_[a-z_]+)\.svg")
          .allMatches(seed)
          .map((m) => m.group(1)!)
          .toSet();
      final selectable = {
        ...namesOf(expenseIconSections),
        ...namesOf(incomeIconSections),
      };
      expect(used, isNotEmpty);
      expect(used.difference(selectable), isEmpty);
    });

    test('lib 配下で Icons.* を直書きしているのは AppIcons 台帳だけ', () {
      final offenders = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => !f.path.endsWith('lib/constant/icon.dart'))
          .where((f) => RegExp(r'(?<![A-Za-z_])Icons\.').hasMatch(f.readAsStringSync()))
          .map((f) => f.path)
          .toList();
      expect(offenders, isEmpty, reason: 'AppIcons の意味名を使うこと: $offenders');
    });

    test('DB に残り得る旧アセット名も実在する（論点5-A: ファイル名据え置き）', () {
      const legacy = [
        'icon_apartment',
        'icon_domain',
        'icon_energy_savings_leaf',
        'icon_cell_tower',
        'icon_autorenew',
      ];
      for (final n in legacy) {
        expect(File('assets/images/$n.svg').existsSync(), isTrue, reason: n);
      }
    });
  });

  group('IconSelectDialog', () {
    Future<void> pumpDialog(WidgetTester tester, CategoryType type) async {
      await pumpApp(
        tester,
        home: Scaffold(
          body: SingleChildScrollView(
            child: IconSelectDialog(categoryType: type),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('支出は5分類・40個のアイコンを提示する', (tester) async {
      await pumpDialog(tester, CategoryType.expense);

      for (final s in expenseIconSections) {
        expect(find.text(s.title), findsOneWidget);
      }
      expect(find.bySemanticsLabel('categoryIcon'), findsNWidgets(40));
    });

    testWidgets('収入は2分類・15個のアイコンを提示する', (tester) async {
      await pumpDialog(tester, CategoryType.income);

      for (final s in incomeIconSections) {
        expect(find.text(s.title), findsOneWidget);
      }
      expect(find.bySemanticsLabel('categoryIcon'), findsNWidgets(15));
    });
  });
}
