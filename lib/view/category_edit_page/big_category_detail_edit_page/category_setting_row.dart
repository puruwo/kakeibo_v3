import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// カテゴリー編集画面の設定行（カテゴリーカラー・会計種別）
///
/// 「左ラベル・右に現在値＋シェブロン」のレイアウトで統一するピル型の行。
/// 枠線は surfaceBorderSubtle（弱い境界線）を使う。
/// タップ動作は持たないので、呼び出し側で GestureDetector や AppPopupMenu で包む。
class CategorySettingRow extends StatelessWidget {
  const CategorySettingRow({
    super.key,
    required this.label,
    this.trailing,
    this.locked = false,
  });

  /// 左側のラベル
  final String label;

  /// 右側の現在値（色ドットや選択値テキスト）
  final Widget? trailing;

  /// trueならシェブロンの代わりにロックアイコンを表示する（変更不可の行）
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: context.colors.fillQuaternary,
          border: Border.all(
            color: context.colors.surfaceBorderSubtle,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(label, style: AppTextStyles.listTileSecondaryTitle),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ?trailing,
                const SizedBox(width: 4),
                if (locked)
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: context.colors.textSecondary,
                  )
                else
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: context.colors.textSecondary,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
