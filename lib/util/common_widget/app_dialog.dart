import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';

/// メニューダイアログの各項目を表すデータクラス
class MenuDialogItem {
  /// メニュー項目のラベル
  final String label;

  /// メニュー項目のアイコン
  final IconData icon;

  /// アイコンの色（指定しない場合はテーマカラー）
  final Color? iconColor;

  /// タップ時のコールバック
  final VoidCallback onPressed;

  const MenuDialogItem({
    required this.label,
    required this.icon,
    this.iconColor,
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
            Container(
              decoration: BoxDecoration(
                color: MyColors.tirtiarySystemBackground,
                borderRadius: BorderRadius.circular(12),
              ),
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
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: MyColors.separater,
                      ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // キャンセルボタン（固定・別枠）
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: MyColors.tirtiarySystemBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        cancelLabel,
                        style: MyFonts.dialogList.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
      borderRadius =
          const BorderRadius.only(bottomLeft: radius, bottomRight: radius);
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
                color: item.iconColor ?? MyColors.themeColor,
              ),
              const SizedBox(width: 16),
              // ラベル
              Expanded(
                child: Text(
                  item.label,
                  style: MyFonts.dialogList,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
