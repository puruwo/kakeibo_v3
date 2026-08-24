import 'package:flutter/material.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// メニューダイアログの各項目を表すデータクラス
class MenuDialogItem {
  /// メニュー項目のラベル
  final String label;

  /// メニュー項目のアイコン
  final IconData icon;

  /// アイコンの色（指定しない場合はテーマカラー）
  final Color? iconColor;

  /// ADR-018: 削除等の不可逆操作の項目にtrueを指定する。
  /// アイコン・ラベルともdanger色になる（iconColorより優先）。
  final bool isDestructive;

  /// タップ時のコールバック
  final VoidCallback onPressed;

  const MenuDialogItem({
    required this.label,
    required this.icon,
    this.iconColor,
    this.isDestructive = false,
    required this.onPressed,
  });
}

/// 下からスライドアップするメニューダイアログを表示する
///
/// [items] - メニュー項目のリスト
/// [cancelLabel] - キャンセルボタンのラベル（デフォルト: "キャンセル"）
Future<void> showMenuDialog(
  BuildContext context, {
  required List<MenuDialogItem> items,
  String cancelLabel = "キャンセル",
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useRootNavigator: true, // グローバルナビゲーションにも被せる
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // メニュー項目リスト
            ActionSheetBlock(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    _MenuItemTile(
                      item: items[i],
                      isFirst: i == 0,
                      isLast: i == items.length - 1,
                    ),
                    if (i != items.length - 1)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: context.colors.separator,
                      ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // キャンセルボタン（固定・別枠）
            ActionSheetCancelButton(
              label: cancelLabel,
              onTap: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      );
    },
  );
}

/// メニュー項目の個別タイル
class _MenuItemTile extends StatelessWidget {
  final MenuDialogItem item;
  final bool isFirst;
  final bool isLast;

  const _MenuItemTile({
    required this.item,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = item.isDestructive
        ? context.colors.danger
        : (item.iconColor ?? context.colors.primary);

    // 最初と最後の項目に応じた角丸を計算
    const radius = Radius.circular(12);
    BorderRadius borderRadius;
    if (isFirst && isLast) {
      // 1つだけの場合は全角丸
      borderRadius = BorderRadius.all(radius);
    } else if (isFirst) {
      // 最初の項目は上部のみ角丸
      borderRadius = const BorderRadius.only(topLeft: radius, topRight: radius);
    } else if (isLast) {
      // 最後の項目は下部のみ角丸
      borderRadius = const BorderRadius.only(
        bottomLeft: radius,
        bottomRight: radius,
      );
    } else {
      // 中間の項目は角丸なし
      borderRadius = BorderRadius.zero;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () {
          Navigator.of(context).pop(); // ダイアログを閉じる
          item.onPressed(); // コールバック実行
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              // アイコン
              Icon(
                item.icon,
                size: 24,
                color: resolvedColor,
              ),
              const SizedBox(width: 16),
              // ラベル
              Expanded(
                child: Text(
                  item.label,
                  style: item.isDestructive
                      ? AppTextStyles.dialogList.copyWith(color: resolvedColor)
                      : AppTextStyles.dialogList,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// アクションシートの角丸ブロック（surfaceElevated2・角丸12）。
/// showMenuDialog と showConfirmationDialog（app_delete_dialog.dart）で
/// 外枠の見た目を共有するための部品。
class ActionSheetBlock extends StatelessWidget {
  const ActionSheetBlock({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

/// アクションシート下部の「キャンセル」別枠ボタン（共有部品）
class ActionSheetCancelButton extends StatelessWidget {
  const ActionSheetCancelButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionSheetBlock(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.dialogList.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
