import 'package:flutter/material.dart';
import 'package:kakeibo/constant/strings.dart';

/// 画面内セクションヘッダーの統一ウィジェット
///
/// 各セクションの見出し（例: 「支出グラフ」「今月の計画」「カテゴリー別」）を統一表示
///
/// レイアウト:
/// ```
/// | [icon] タイトル               [サブラベル] |
/// ```
class AppContentsHeader extends StatelessWidget {
  const AppContentsHeader({
    super.key,
    this.icon,
    this.iconWidget,
    required this.title,
    this.subLabel,
    this.isLinkable = false,
    this.onTap,
  }) : assert(
          !isLinkable || onTap != null,
          'onTap must be provided when isLinkable is true',
        );

  /// セクションアイコン（IconData）
  final IconData? icon;

  /// カスタムアイコンウィジェット（SVGなど）
  final Widget? iconWidget;

  /// セクションタイトル
  final String title;

  /// 右側のサブラベル（オプション）
  final String? subLabel;

  /// サブラベルをリンク化するかどうか
  final bool isLinkable;

  /// リンク化時のタップコールバック
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveTitleStyle = AppTextStyles.cardSectionTitle;

    return SizedBox(
      height: 35,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左側: アイコン + タイトル
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // カスタムアイコンウィジェット
              if (iconWidget != null) ...[
                iconWidget!,
                const SizedBox(width: 8),
              ]
              // IconDataアイコン
              else if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: effectiveTitleStyle.color,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                icon == null && iconWidget == null ? ' $title' : title,
                style: effectiveTitleStyle,
              ),
            ],
          ),

          // 右側: サブラベル（リンク化対応）
          if (subLabel != null)
            isLinkable
                ? TextButton(
                    onPressed: onTap,
                    child: Text(
                      subLabel!,
                      style: AppTextStyles.textButtonTextStyle,
                    ),
                  )
                : Text(
                    subLabel!,
                    style: AppTextStyles.listCardSecondaryTitle,
                  ),
        ],
      ),
    );
  }
}
