import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/component/card_container.dart';

/// ADR-022: 「次アクションがある空状態」の共通カード。
///
/// 記録がゼロで、そのセクションから登録導線を出せる場合に使う
/// （CardContainer + アイコン + 見出し + 説明1行 + Primaryボタン）。
/// 次アクションが無い従属領域（グラフ・サブリスト・絞り込み結果）の空状態は
/// [AppTextStyles.listEmptyMessage] の1行テキスト、取得失敗は `AppErrorState` を使うこと。
/// カード形式の空状態は1画面につき原則1つまで。
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
  });

  /// 見出しの上に表示するアイコン
  final IconData icon;

  /// 見出し（例: 「家計簿をはじめましょう」）
  final String title;

  /// 説明1行（例: 「毎日の収支を記録するとグラフが表示されます」）
  final String description;

  /// Primaryボタンのラベル（例: 「＋ 記録を追加する」）
  final String buttonLabel;

  /// Primaryボタン押下時の処理
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: context.colors.textSecondary),
            const SizedBox(height: 8),
            Text(title, style: AppTextStyles.appCardTitleLabel),
            const SizedBox(height: 4),
            Text(
              description,
              style: AppTextStyles.listCardSecondaryTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: MainButton(buttonText: buttonLabel, onPressed: onPressed),
            ),
          ],
        ),
      ),
    );
  }
}
