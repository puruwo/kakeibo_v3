import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// 月次固定費ビュー（案A）のタイル2行目
///
/// 「小カテゴリー › 日付」を1行で表示する。
/// 小カテゴリーは通常のテキスト色、区切りの `›` は textTertiary、日付は textSecondary。
class FixedCostTileSubtitle extends StatelessWidget {
  const FixedCostTileSubtitle({
    super.key,
    required this.smallCategoryName,
    required this.dateLabel,
  });

  /// 小カテゴリー名（未解決のときは空文字）
  final String smallCategoryName;

  /// 支払日のラベル（例: 2026/8/25）
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTextStyles.listCardSecondaryTitle;

    return Text.rich(
      TextSpan(
        children: [
          if (smallCategoryName.isNotEmpty) ...[
            TextSpan(
              text: smallCategoryName,
              style: baseStyle.copyWith(color: context.colors.text),
            ),
            TextSpan(
              text: ' › ',
              style: baseStyle.copyWith(color: context.colors.textTertiary),
            ),
          ],
          TextSpan(text: dateLabel, style: baseStyle),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
