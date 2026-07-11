import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/aggregation_settings/aggregation_settings_usecase.dart';
import 'package:kakeibo/application/data_management/data_management_usecase.dart';
import 'package:kakeibo/application/export/export_provider.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/component/app_contents_header.dart';
import 'package:kakeibo/view/component/failure_snackbar.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/component/success_snackbar.dart';
import 'package:kakeibo/view/config/aggregation_setting_dialog.dart';

class ConfigTop extends ConsumerWidget {
  const ConfigTop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('設定', style: AppTextStyles.pageHeaderText),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: const GlassAppBarBackground(),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppContentsHeader(
              type: AppContentsHeaderType.appCardSectionTitle,
              title: '設定画面',
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.colors.fillTertiary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _ConfigRow(
                    label: '入力履歴をエクスポートする',
                    isFirst: true,
                    onTap: () {
                      // 設定画面からエクスポートを実行
                      ref
                          .read(exportProvider)
                          .when(
                            data: (data) => null,
                            error: (e, _) => null,
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    color: context.colors.separator,
                  ),
                  _ConfigRow(
                    label: '集計期間を設定する',
                    isLast: true,
                    onTap: () => _showAggregationSettingDialog(context, ref),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const AppContentsHeader(
              type: AppContentsHeaderType.appCardSectionTitle,
              title: 'データ管理',
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.colors.fillTertiary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _ConfigRow(
                    label: 'データベースを書き出す',
                    isFirst: true,
                    onTap: () => _exportDatabase(context, ref),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    color: context.colors.separator,
                  ),
                  _ConfigRow(
                    label: 'すべてのデータを削除する',
                    textColor: context.colors.expense,
                    isLast: true,
                    onTap: () => _confirmAndDeleteAllData(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// データベースファイルを共有シートで書き出す
  Future<void> _exportDatabase(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(dataManagementUsecaseProvider).exportDatabaseFile();
    } catch (e) {
      FailureSnackBar.show(
        scaffoldMessenger,
        message: '書き出しに失敗しました: $e',
      );
    }
  }

  /// 確認ダイアログで承認されたら全データを削除する
  Future<void> _confirmAndDeleteAllData(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final isApproved = await showConfirmationDialog(
      context,
      title: 'すべてのデータを削除',
      message: '支出・収入・固定費・予算などすべての記録を削除します。\nこの操作は取り消せません。本当に削除しますか？',
    );
    if (!isApproved) return;

    try {
      await ref.read(dataManagementUsecaseProvider).deleteAllData();
      SuccessSnackBar.show(
        scaffoldMessenger,
        message: 'すべてのデータを削除しました',
      );
    } catch (e) {
      FailureSnackBar.show(
        scaffoldMessenger,
        message: '削除に失敗しました: $e',
      );
    }
  }

  /// 現在の設定値を取得してから集計期間の設定ダイアログを表示する
  Future<void> _showAggregationSettingDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final settings = await ref.read(aggregationSettingsUsecaseProvider).fetch();
    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (context) => AggregationSettingDialog(
        originalStartDay: settings.startDay,
        originalStartMonth: settings.startMonth,
      ),
    );
  }
}

/// 設定画面の1行メニュー
class _ConfigRow extends StatelessWidget {
  const _ConfigRow({
    required this.label,
    required this.onTap,
    this.textColor,
    this.isFirst = false,
    this.isLast = false,
  });

  final String label;
  final VoidCallback onTap;

  /// ラベル色の上書き（破壊的操作の行を赤系にする用途）
  final Color? textColor;

  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(8);
    final borderRadius = BorderRadius.only(
      topLeft: isFirst ? radius : Radius.zero,
      topRight: isFirst ? radius : Radius.zero,
      bottomLeft: isLast ? radius : Radius.zero,
      bottomRight: isLast ? radius : Radius.zero,
    );

    return AppInkWell(
      borderRadius: borderRadius,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                label,
                style: textColor != null
                    ? AppTextStyles.oneLineButtonText.copyWith(color: textColor)
                    : AppTextStyles.oneLineButtonText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
