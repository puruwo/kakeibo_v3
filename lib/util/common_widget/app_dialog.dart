// ダイアログのアクション項目データクラス
import 'package:flutter/material.dart';

class DialogActionItem {
  final String label;
  Color? labelColor;
  final VoidCallback onPressed;
  DialogActionItem({required this.label, required this.onPressed});
}

// 汎用カスタムダイアログを表示する関数
Future<void> showCustomListDialog(
  BuildContext context, {
  String? title,
  String? content,
  required List<DialogActionItem> actions,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true, // 外側タップで閉じるか
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)), // 角丸などスタイル
        child: Column(
          mainAxisSize: MainAxisSize.min, // 子の高さに合わせる
          children: [
            title == null && content == null
                ? Column(
                    children: [
                      // タイトル
                      title != null
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(title,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            )
                          : const SizedBox.shrink(),
                      // 本文テキスト（任意で表示）
                      content != null
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(content),
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 8),
                    ],
                  )
                : const SizedBox.shrink(),

            // アクション項目リスト
            for (int i = 0; i < actions.length; i++) ...[
              Column(
                children: [
                  InkWell(
                    onTap: () {
                      actions[i].onPressed(); // コールバック実行
                    },
                    child: SizedBox(
                      height: 58,
                      child: Center(
                          child: Text(actions[i].label,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: actions[i].labelColor,
                                  fontWeight: FontWeight.w500))),
                    ),
                  ),
                ],
              ),
              if (i != actions.length - 1) const Divider(height: 1),
            ]
          ],
        ),
      );
    },
  );
}
