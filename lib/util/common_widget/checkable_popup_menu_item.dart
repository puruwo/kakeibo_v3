import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';

/// アプリ共通のPopupMenuButton
///
/// 統一されたデザイン（背景色、角丸、オフセット）でPopupMenuを表示する。
/// 使用例:
/// ```dart
/// AppPopupMenu<TransactionMode>(
///   onSelected: (mode) => print(mode),
///   itemBuilder: (context) => [
///     buildCheckableMenuItem(value: TransactionMode.expense, label: '支出', isSelected: true),
///   ],
///   child: Text('メニューを開く'),
/// )
/// ```
class AppPopupMenu<T> extends StatelessWidget {
  const AppPopupMenu({
    super.key,
    this.enabled = true,
    required this.itemBuilder,
    required this.onSelected,
    required this.child,
    this.offset = const Offset(0, 40),
    this.borderRadius = 12.0,
  });

  /// モードを変更できるかどうか
  final bool enabled;

  /// メニューアイテムを構築するビルダー
  final List<PopupMenuEntry<T>> Function(BuildContext) itemBuilder;

  /// アイテムが選択された時のコールバック
  final ValueChanged<T> onSelected;

  /// ボタンとして表示する子ウィジェット
  final Widget child;

  /// メニューの表示オフセット
  final Offset offset;

  /// メニューの角丸
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.black.withOpacity(0.1)),
      child: PopupMenuButton<T>(
        enabled: enabled,
        offset: offset,
        color: MyColors.tertiarySystemBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        onSelected: onSelected,
        itemBuilder: itemBuilder,
        child: child,
      ),
    );
  }
}

/// チェックマーク付きのPopupMenuItemを構築するヘルパー
///
/// 選択状態に応じてチェックマークを表示し、太字でハイライトする共通コンポーネント。
/// 使用例:
/// ```dart
/// PopupMenuButton<String>(
///   itemBuilder: (context) => [
///     buildCheckableMenuItem(value: 'option1', label: 'オプション1', isSelected: selected == 'option1'),
///     buildCheckableMenuItem(value: 'option2', label: 'オプション2', isSelected: selected == 'option2'),
///   ],
/// )
/// ```
PopupMenuItem<T> buildCheckableMenuItem<T>({
  required T value,
  required String label,
  required bool isSelected,
  Color? selectedColor,
  Color? textColor,
  EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
}) {
  return PopupMenuItem<T>(
    value: value,
    padding: EdgeInsets.zero, // リップルエフェクトを全体に広げるため
    child: Ink(
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            if (isSelected)
              Icon(Icons.check,
                  color: selectedColor ?? MyColors.themeColor, size: 20)
            else
              const SizedBox(width: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor ?? MyColors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// チェックマーク付きのPopupMenuItemを構築するウィジェット版
///
/// 関数版よりカスタマイズ性が高い。子要素を自由に設定可能。
class CheckablePopupMenuItem<T> extends PopupMenuItem<T> {
  CheckablePopupMenuItem({
    super.key,
    required T super.value,
    required String label,
    required bool isSelected,
    Color? selectedColor,
    Color? textColor,
  }) : super(
          child: Row(
            children: [
              if (isSelected)
                Icon(Icons.check,
                    color: selectedColor ?? MyColors.themeColor, size: 20)
              else
                const SizedBox(width: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: textColor ?? MyColors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
}
