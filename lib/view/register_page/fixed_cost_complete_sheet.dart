import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/domain/core/payment_frequency_value/payment_frequency_value.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_inset_group.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/year_page/fixed_cost_button_area/fixed_cost_registration_list_page/fixed_cost_registration_list_page.dart';

/// 固定費の登録完了シートを開く（追加改修 0828・案2）
///
/// 固定費は「未来の予定を作る」操作なので、汎用スナックバーではなく
/// 登録内容と次回支払日を確認できるシートで完了を伝える。
Future<void> showFixedCostCompleteSheet(
  BuildContext context, {
  required FixedCostEntity entity,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => FixedCostCompleteSheet(entity: entity),
  );
}

/// 固定費の登録完了シート本体
///
/// 登録したマスタの名称・金額・頻度・次回支払日を表示し、
/// 固定費一覧への導線を添える。
class FixedCostCompleteSheet extends ConsumerWidget {
  const FixedCostCompleteSheet({super.key, required this.entity});

  /// 登録した固定費マスタ（nextPaymentDate設定済み）
  final FixedCostEntity entity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.read(systemDatetimeNotifierProvider);
    final frequencyLabel = PaymentFrequencyValue.fromDB(
      intervalNumber: entity.intervalNumber,
      intervalUnitNumber: entity.intervalUnit,
    ).dateLabel;
    final isVariable = entity.variable == 1;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        border: Border(top: BorderSide(color: context.colors.surfaceBorder)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ハンドル
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.fillSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Icon(
              Icons.check_circle_rounded,
              size: 44,
              color: context.colors.income,
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Text('固定費を登録しました', style: AppTextStyles.sheetTitle),
            ),
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: Text(
                '次回から自動で支出に記録されます',
                style: AppTextStyles.insetGroupNote,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppInsetGroup(
              note: isVariable
                  ? null
                  : '年間換算 ${yenmarkFormattedPriceGetter(_annualizedPrice())}',
              children: [
                AppInsetRow.display(label: '名称', value: entity.name),
                AppInsetRow.display(
                  label: '金額',
                  // 変動型は毎回金額が変わるため、確定額ではなく種別を示す
                  value: isVariable
                      ? '変動'
                      : yenmarkFormattedPriceGetter(entity.price),
                ),
                AppInsetRow.display(label: '頻度', value: frequencyLabel),
                AppInsetRow.display(
                  label: '次回支払日',
                  value: _nextPaymentLabel(today),
                  valueColor: context.colors.primary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            MainButton(
              buttonText: '固定費一覧を見る',
              onPressed: () {
                final navigator = Navigator.of(context, rootNavigator: true);
                navigator.pop();
                navigator.push(
                  MaterialPageRoute(
                    builder: (context) => const FixedCostRegistrationListPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            MainButton(
              buttonType: ButtonColorType.secondary,
              buttonText: '閉じる',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  /// 次回支払日の表示文字列（例: 「9月25日（金）」「2027年2月1日（月）」）
  ///
  /// 今年と同じ年は年を省略する。nextPaymentDateが無い場合は初回支払日を使う
  String _nextPaymentLabel(DateTime today) {
    final dateStr = entity.nextPaymentDate ?? entity.firstPaymentDate;
    final date = DateTime(
      int.parse(dateStr.substring(0, 4)),
      int.parse(dateStr.substring(4, 6)),
      int.parse(dateStr.substring(6, 8)),
    );
    const weekdayLabels = ['月', '火', '水', '木', '金', '土', '日'];
    final weekday = weekdayLabels[date.weekday - 1];
    final yearPrefix = date.year == today.year ? '' : '${date.year}年';
    return '$yearPrefix${date.month}月${date.day}日（$weekday）';
  }

  /// 年間換算の金額（月単位: 年12ヶ月ぶんに換算／年単位: 1年あたりに換算）
  int _annualizedPrice() {
    if (entity.intervalUnit == PaymentFrequencyIntervalUnit.year.inturvalUnitNumber) {
      return (entity.price / entity.intervalNumber).round();
    }
    return (entity.price * 12 / entity.intervalNumber).round();
  }
}
