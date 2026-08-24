import 'package:flutter/material.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// 選択肢グリッド用のボトムシート共通シェル（案件 UIデザイン改修 §8）
///
/// アイコン選択・カラー選択のような「一覧から1つ選んで即決定」するUIを
/// 中央ダイアログではなく下端シートで出すための共通枠。
/// 上端角丸24・fillOpaque地・ハンドル・タイトル＋スクロール可能な中身を持つ。
class AppSelectionSheet extends StatelessWidget {
  const AppSelectionSheet({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  /// シートとして表示する。タップ即決定のため戻り値は持たない
  static Future<void> show(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => AppSelectionSheet(title: title, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.75;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: context.colors.fillOpaque,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ハンドル
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.handle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // タイトル
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
            child: Text(title, style: AppTextStyles.dialogTitle),
          ),
          // 中身（あふれる場合はスクロール）
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
