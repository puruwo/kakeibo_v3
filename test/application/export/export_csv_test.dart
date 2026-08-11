import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/export/export_usecase.dart';

void main() {
  // 各セクション1行ずつのサンプルデータ
  const expenseRow = [
    1,
    '20250701',
    1000,
    'ランチ',
    '食費',
    1,
    '外食',
    12,
    'FF0000',
    'food',
    '給与',
    1,
  ];
  const incomeRow = [1, '20250625', 300000, '給料', '月次収入', 1, '基本給', 11];
  const fixedCostRow = [
    1,
    '20250701',
    80000,
    '家賃',
    '住居',
    1,
    '0000FF',
    'home',
    '確定',
    0,
    '確定済み',
    1,
  ];

  /// CSV文字列を行単位に分解する（ListToCsvConverterの既定の改行は CRLF）
  List<String> linesOf(String csv) => const LineSplitter().convert(csv);

  group('buildExportCsvString', () {
    test('支出・収入・固定費の3セクションが空行区切りで並ぶ', () {
      final csv = buildExportCsvString(
        expenseRows: const [expenseRow],
        incomeRows: const [incomeRow],
        fixedCostRows: const [fixedCostRow],
      );

      final lines = linesOf(csv);

      // 見出し→ヘッダー→行→空行 を3セクション分（最後のセクションの後に空行は付かない）
      expect(lines, hasLength(11));
      expect(lines[0], '【支出データ】');
      expect(lines[2], startsWith('1,20250701,1000,ランチ'));
      expect(lines[3], isEmpty);
      expect(lines[4], '【収入データ】');
      expect(lines[6], startsWith('1,20250625,300000,給料'));
      expect(lines[7], isEmpty);
      expect(lines[8], '【固定費データ】');
      expect(lines[10], startsWith('1,20250701,80000,家賃'));
    });

    test('各セクションのヘッダー列が仕様どおりに並ぶ', () {
      final csv = buildExportCsvString(
        expenseRows: const [expenseRow],
        incomeRows: const [incomeRow],
        fixedCostRows: const [fixedCostRow],
      );

      final lines = linesOf(csv);

      // 支出は12列
      expect(lines[1].split(','), [
        'ID',
        '日付',
        '購入金額',
        'メモ',
        '大カテゴリー名',
        '大カテゴリーID',
        'カテゴリー名',
        'カテゴリーID',
        '色コード',
        'アイコン情報',
        '拠出元',
        '拠出元ID',
      ]);
      // 収入は8列
      expect(lines[5].split(','), [
        'ID',
        '日付',
        '金額',
        'メモ',
        '大カテゴリー名',
        '大カテゴリーID',
        'カテゴリー名',
        'カテゴリーID',
      ]);
      // 固定費は12列
      expect(lines[9].split(','), [
        'ID',
        '日付',
        '金額',
        '名称',
        'カテゴリー名',
        'カテゴリーID',
        '色コード',
        'アイコン情報',
        '金額タイプ',
        '金額タイプID',
        '確定状態',
        '確定状態ID',
      ]);
    });
  });

  group('extractIconName', () {
    test('リソースパスからアイコン名を取り出す', () {
      expect(extractIconName('assets/images/icon_food.svg'), 'food');
    });

    test('アンダースコアが複数あっても末尾のセグメントを返す', () {
      // ディレクトリ→拡張子→アンダースコアの順に切り出すため末尾だけが残る
      expect(extractIconName('assets/images/icon_credit_card.svg'), 'card');
      // 拡張子が違っても・ディレクトリが無くても同じ結果になる
      expect(extractIconName('assets/images/icon_credit_card.png'), 'card');
      expect(extractIconName('icon_credit_card.svg'), 'card');
    });
  });
}
