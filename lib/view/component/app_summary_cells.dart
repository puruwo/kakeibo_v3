import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// サマリーの1セル（上段＝ラベル、下段＝値）
class AppSummaryCell {
  const AppSummaryCell({
    required this.label,
    required this.value,
    this.labelTrailing,
  });

  final String label;
  final String value;

  /// ラベルの右に添える小さな要素（情報アイコン等）。無ければラベルのみ
  final Widget? labelTrailing;
}

/// ラベル＋値のセルを等幅で横に並べ、縦の区切り線で仕切るサマリー行
///
/// 外枠（カードの地・枠線・角丸）は持たない。呼び出し側のカードの中に置く。
/// 支払い履歴ページ・固定費登録リストページのサマリーカードで共用する。
class AppSummaryCells extends StatelessWidget {
  const AppSummaryCells({super.key, required this.cells});

  final List<AppSummaryCell> cells;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++) ...[
            if (i > 0)
              VerticalDivider(
                width: 0.5,
                thickness: 0.5,
                color: context.colors.separator,
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                  horizontal: AppSpacing.sm,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cells[i].label,
                          style: context.textStyles.insetGroupNote,
                        ),
                        if (cells[i].labelTrailing != null) ...[
                          const SizedBox(width: 2),
                          cells[i].labelTrailing!,
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    // 桁の大きい金額でもセル幅からはみ出さないよう縮小して収める
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        cells[i].value,
                        style: context.textStyles.listTilePriceLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
