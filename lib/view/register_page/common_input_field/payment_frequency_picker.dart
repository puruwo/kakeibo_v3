// packegeImport
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// localImport
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/domain/core/payment_frequency_value/payment_frequency_value.dart';

import 'package:kakeibo/view_model/state/register_page/payment_frequency_controller/payment_frequency_controller.dart';

/// 支払い頻度の選択ダイアログ（案件 UIデザイン改修 §7）
///
/// プリセット5種（毎月／隔月／3ヶ月毎／半年毎／毎年）のフラットなリストから
/// タップ即決定する。旧実装のDropdownMenu×2＋OK/キャンセルは廃止。
/// 現在値がプリセット外（例: 4ヶ月毎）の場合のみ、その値の行を末尾に追加表示して
/// 既存データの選択状態を壊さない。
class PaymentFrequencyPicker extends ConsumerWidget {
  const PaymentFrequencyPicker(
      {super.key, required this.originalPaymentFrequency});

  final PaymentFrequencyValue originalPaymentFrequency;

  /// プリセット（intervalNumber, intervalUnit）
  static const List<(int, PaymentFrequencyIntervalUnit)> _presets = [
    (1, PaymentFrequencyIntervalUnit.month),
    (2, PaymentFrequencyIntervalUnit.month),
    (3, PaymentFrequencyIntervalUnit.month),
    (6, PaymentFrequencyIntervalUnit.month),
    (1, PaymentFrequencyIntervalUnit.year),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = (
      originalPaymentFrequency.intervalNumber,
      originalPaymentFrequency.intervalUnit,
    );
    final options = [
      ..._presets,
      // プリセット外の既存値は末尾に追加表示する
      if (!_presets.contains(current)) current,
    ];

    return Dialog(
      backgroundColor: context.colors.fillOpaque,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      // 選択肢リストをダイアログの縁までフラットに敷くため、角丸でクリップする
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // タイトル行（右上に閉じるボタン）
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 14),
            child: Row(
              children: [
                Text('支払い頻度', style: AppTextStyles.dialogTitle),
                const Spacer(),
                _CloseButton(onTap: () => Navigator.of(context).pop()),
              ],
            ),
          ),
          Container(height: 0.5, color: context.colors.separator),
          for (int i = 0; i < options.length; i++) ...[
            if (i != 0)
              Container(
                height: 0.5,
                margin: const EdgeInsets.only(left: 24),
                color: context.colors.separator,
              ),
            Builder(builder: (context) {
              // 表示ラベルと保存値がずれないよう、同じ値オブジェクトを共有する
              final value = PaymentFrequencyValue.fromDB(
                intervalNumber: options[i].$1,
                intervalUnitNumber: options[i].$2.inturvalUnitNumber,
              );
              return _FrequencyRow(
                value: value,
                isSelected: options[i] == current,
                onTap: () {
                  ref
                      .read(
                          paymentFrequencyControllerNotifierProvider.notifier)
                      .setData(value);
                  Navigator.of(context).pop();
                },
              );
            }),
          ],
        ],
      ),
    );
  }
}

/// 選択肢の1行。高さ48・タップ即決定。選択中はprimaryのチェックのみで示す
class _FrequencyRow extends StatelessWidget {
  const _FrequencyRow({
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final PaymentFrequencyValue value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 48,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(
                value.dateLabel,
                style: isSelected
                    ? AppTextStyles.dialogListEmphasis
                    : AppTextStyles.dialogList
                        .copyWith(color: context.colors.textSecondary),
              ),
              const Spacer(),
              if (isSelected)
                Icon(
                  Icons.done_rounded,
                  size: 18,
                  color: context.colors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 右上の閉じるボタン（円28px・fillSecondary地）
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.fillSecondary,
        ),
        child: Icon(
          Icons.close_rounded,
          size: 16,
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}
