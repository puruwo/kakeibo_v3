import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/export/export_usecase.dart';

void main() {
  // 各セクション1行ずつのサンプルデータ
  // 支出行は v10 で固定費3列（固定費ID / 確定状態ID / 予想額）が末尾に増えた
  const normalExpenseRow = [
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
    null, // 固定費ID（通常支出はNULL）
    1, // 確定状態ID（通常支出は常に1）
    null, // 予想額（通常支出はNULL）
  ];
  // 未確定の固定費行（実額なし・予想額あり）
  const unconfirmedFixedCostRecordRow = [
    2,
    '20250710',
    3000,
    '電気代',
    '光熱費',
    3,
    '光熱費',
    30,
    '8E8E93',
    'utility',
    '給与',
    1,
    30, // 固定費ID
    0, // 確定状態ID（未確定）
    3000, // 予想額
  ];
  const incomeRow = [1, '20250625', 300000, '給料', '月次収入', 1, '基本給', 11];

  /// CSV文字列を行単位に分解する（ListToCsvConverterの既定の改行は CRLF）
  List<String> linesOf(String csv) => const LineSplitter().convert(csv);

  group('buildExportCsvString', () {
    test('支出・収入の2セクションが空行区切りで並ぶ（固定費シートは廃止）', () {
      final csv = buildExportCsvString(
        expenseRows: const [normalExpenseRow, unconfirmedFixedCostRecordRow],
        incomeRows: const [incomeRow],
      );

      final lines = linesOf(csv);

      // 見出し→ヘッダー→行2件→空行→見出し→ヘッダー→行1件
      expect(lines, hasLength(8));
      expect(lines[0], '【支出データ】');
      expect(lines[2], startsWith('1,20250701,1000,ランチ'));
      expect(lines[3], startsWith('2,20250710,3000,電気代'));
      expect(lines[4], isEmpty);
      expect(lines[5], '【収入データ】');
      expect(lines[7], startsWith('1,20250625,300000,給料'));
      // 固定費専用シートは出力されない
      expect(csv.contains('【固定費データ】'), isFalse);
    });

    test('各セクションのヘッダー列が仕様どおりに並ぶ', () {
      final csv = buildExportCsvString(
        expenseRows: const [normalExpenseRow],
        incomeRows: const [incomeRow],
      );

      final lines = linesOf(csv);

      // 支出は15列（従来の12列＋固定費3列）
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
        '固定費ID',
        '確定状態ID',
        '予想額',
      ]);
      // 収入は8列（変更なし）
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
    });

    test('固定費行は固定費ID・確定状態ID・予想額が支出シートに出る', () {
      final csv = buildExportCsvString(
        expenseRows: const [unconfirmedFixedCostRecordRow],
        incomeRows: const [],
      );

      final lines = linesOf(csv);

      // 末尾3列が 固定費ID=30 / 確定状態ID=0 / 予想額=3000
      expect(lines[2], endsWith(',30,0,3000'));
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
