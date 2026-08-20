import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/view/component/app_empty_state.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

/// ボーナス未入力時に登録を促すカード（ADR-022 の `AppEmptyState`）。
class BonusRegisterPromptArea extends ConsumerWidget {
  const BonusRegisterPromptArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppEmptyState(
      icon: Icons.savings_rounded,
      title: '特別枠の収入を登録しましょう',
      description: 'ボーナスなどの収入を登録すると利用状況が表示されます',
      buttonLabel: '＋ 収入を登録する',
      onPressed: () {
        final today = ref.read(systemDatetimeNotifierProvider);
        final newIncome = IncomeEntity(
          date: DateFormat('yyyyMMdd').format(today),
          // 初期選択は小カテゴリー「ボーナス」（大カテゴリーIDではなく小カテゴリーID）
          categoryId: IncomeSmallCategoryConstants.bonus,
        );
        showAppModalBottomSheet(
          context,
          child: RegisaterPageBase.addIncome(incomeEntity: newIncome),
        );
      },
    );
  }
}
