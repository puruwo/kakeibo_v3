import 'package:flutter/material.dart';

Future<bool> showDeleteConfirmationDialog(
  BuildContext context, {
  VoidCallback? onConfirm,
}) async {
  return await showDialog(
    // ダイアログの外側をタップしても閉じないようにする
    // 外側をタップして閉じるとヒストリカルリストのUIが崩れるので
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("登録履歴の削除"), // ダイアログのタイトル
        content: const Text("削除したデータは戻せません。\n本当に削除しますか？"), // ダイアログのメッセージ
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(false), // キャンセルボタンを押したときの処理
            child: const Text("戻る"),
          ),
          TextButton(
            onPressed: () {
              onConfirm?.call(); // 確認ボタンを押したときの処理
              Navigator.of(context).pop(true);
            }, // 削除ボタンを押したときの処理
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}
