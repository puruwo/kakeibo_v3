// packegeImport
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// localImport
import 'package:kakeibo/application/aggregation_settings/aggregation_settings_usecase.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/component/failure_snackbar.dart';
import 'package:kakeibo/view/component/success_snackbar.dart';

/// 集計期間（開始日・開始月）の設定ダイアログ
///
/// 設定画面の「集計期間を設定する」から表示される。
/// 保存時は確認ダイアログで、過去の記録も新しい区切りで再計算されることを告知する。
class AggregationSettingDialog extends ConsumerStatefulWidget {
  const AggregationSettingDialog({
    super.key,
    required this.originalStartDay,
    required this.originalStartMonth,
  });

  /// 表示時点の集計開始日
  final int originalStartDay;

  /// 表示時点の集計開始月
  final int originalStartMonth;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AggregationSettingDialogState();
}

class _AggregationSettingDialogState
    extends ConsumerState<AggregationSettingDialog> {
  late int selectedStartDay;
  late int selectedStartMonth;

  @override
  void initState() {
    super.initState();
    selectedStartDay = widget.originalStartDay;
    selectedStartMonth = widget.originalStartMonth;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // タイトル
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '集計期間を設定',
              style: AppTextStyles.dialogTitle,
              textAlign: TextAlign.center,
            ),
          ),

          // 月の集計開始日
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('毎月'),
              _buildNumberDropdown(
                initial: selectedStartDay,
                count: 28,
                onSelected: (value) {
                  setState(() {
                    selectedStartDay = value;
                  });
                },
              ),
              const Text('日はじまり'),
            ],
          ),

          // 年度の集計開始月
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('年度は'),
              _buildNumberDropdown(
                initial: selectedStartMonth,
                count: 12,
                onSelected: (value) {
                  setState(() {
                    selectedStartMonth = value;
                  });
                },
              ),
              const Text('月から'),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                // キャンセルボタン
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.fill,
                  ),
                  child: Text(
                    'キャンセル',
                    style: AppTextStyles.secondaryButtonText,
                  ),
                ),

                // 保存ボタン
                MainButton(
                  buttonType: ButtonColorType.main,
                  buttonText: '保存',
                  onPressed: () {
                    _confirmAndSave(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 数値選択のドロップダウン（1〜count）
  DropdownMenu<int> _buildNumberDropdown({
    required int initial,
    required int count,
    required ValueChanged<int> onSelected,
  }) {
    return DropdownMenu<int>(
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      textStyle: RegisterPageStyles.pickerLargeNumber,
      trailingIcon: Icon(
        Icons.arrow_drop_down_rounded,
        color: context.colors.textSecondary,
      ),
      width: 80,
      initialSelection: initial,
      onSelected: (value) {
        if (value != null) {
          onSelected(value);
        }
      },
      dropdownMenuEntries: List.generate(
          count, (i) => DropdownMenuEntry(value: i + 1, label: (i + 1).toString())),
    );
  }

  /// 確認ダイアログで承認されたら保存する
  Future<void> _confirmAndSave(BuildContext context) async {
    // 変更時は過去も新しい区切りで再計算されるため、保存前に必ず告知する
    final isApproved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '集計期間を変更しますか？',
                style: AppTextStyles.dialogTitle,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '過去の記録もすべて新しい区切りで再計算されます。',
                style: AppTextStyles.dialogLabel,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dialogContext.colors.fill,
                    ),
                    child: Text(
                      'キャンセル',
                      style: AppTextStyles.secondaryButtonText,
                    ),
                  ),
                  MainButton(
                    buttonType: ButtonColorType.main,
                    buttonText: '変更する',
                    onPressed: () {
                      Navigator.of(dialogContext).pop(true);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (isApproved != true) return;
    if (!context.mounted) return;

    // スナックバー表示用にpop前へ取得しておく
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await ref.read(aggregationSettingsUsecaseProvider).save(
            startDay: selectedStartDay,
            startMonth: selectedStartMonth,
          );

      if (context.mounted) {
        Navigator.of(context).pop();
      }
      SuccessSnackBar.show(
        scaffoldMessenger,
        message: '集計期間の設定を変更しました',
      );
    } catch (e) {
      FailureSnackBar.show(
        scaffoldMessenger,
        message: '設定の変更に失敗しました: $e',
      );
    }
  }
}
