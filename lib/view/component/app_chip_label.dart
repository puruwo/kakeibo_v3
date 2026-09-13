import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// 明細行に添える補足のチップ（「固定費」「変動」等）
///
/// アプリ内のチップはこのWidgetに統一する（KP-019）。
/// 塗りのみ（fillTertiary）・角丸4px・枠なし・アイコンなし。文字は chipLabel（noto 10 w500 textSecondary）。
/// 外側の余白は持たない。隣の要素との間隔は並べる側が取る。
class AppChipLabel extends StatelessWidget {
  const AppChipLabel({super.key, required this.label});

  /// チップに表示する文言
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.fillTertiary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: context.textStyles.chipLabel),
    );
  }
}
