import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_detail_provider.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';

/// 固定費の支払い履歴ページ（準備中）
///
/// 固定費の設定画面の「すべての支払いを見る」からの遷移先（仕様 §6.8）。
/// 本実装は本案件クローズ後に別途対応するため、現状はプレースホルダー。
class FixedCostPaymentHistoryPage extends ConsumerWidget {
  const FixedCostPaymentHistoryPage({super.key, required this.fixedCostId});

  /// 表示対象の固定費マスタID
  final int fixedCostId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 名称はマスタから引く。取得前・失敗時は名称なしで案内だけ出す
    final name = ref.watch(fixedCostByIdProvider(fixedCostId)).maybeWhen(
          data: (fixedCost) => fixedCost.name,
          orElse: () => null,
        );

    return Scaffold(
      backgroundColor: context.colors.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        flexibleSpace: const GlassAppBarBackground(),
        title: Text('支払い履歴', style: AppTextStyles.pageHeaderText),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.colors.text,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (name != null) ...[
              Text(name, style: AppTextStyles.insetGroupLabel),
              const SizedBox(height: AppSpacing.sm),
            ],
            Text('この画面は準備中です', style: AppTextStyles.listEmptyMessage),
          ],
        ),
      ),
    );
  }
}
