import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/view/register_page/common_input_field/date_input_field.dart';
import 'package:kakeibo/view/register_page/common_input_field/memo_input_field.dart';

/// 日付とメモを1行に統合した入力フィールド
///
/// 画像デザイン: [📅 2/29](ダークボタン) | [📝 メモ] [すき焼き用鍋]
class DateMemoRow extends ConsumerWidget {
  const DateMemoRow({
    super.key,
    required this.originalDate,
    required this.originalMemo,
  });

  final String originalDate;
  final String originalMemo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // 日付セクション（ダークボタン）
        DateInputField(originalDate: originalDate),

        const SizedBox(width: 16),

        // メモセクション（MemoInputFieldを流用）
        Expanded(
          child: MemoInputField(
            originalMemo: originalMemo,
            showIcon: true,
          ),
        ),
      ],
    );
  }
}
