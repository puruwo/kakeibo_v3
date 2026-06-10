import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

/// ボーナス未入力時に登録を促すカード。
/// yearly_balance_area.dart の空状態と同じ構成（アイコン＋見出し＋説明＋ボタン）。
class BonusRegisterPromptArea extends ConsumerWidget {
  const BonusRegisterPromptArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CardContainer(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 20.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.savings_rounded,
              size: 32,
              color: context.colors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              'ボーナスを登録しましょう',
              style: AppTextStyles.appCardTitleLabel,
            ),
            const SizedBox(height: 4),
            Text(
              'ボーナスを登録すると利用状況が表示されます',
              style: AppTextStyles.listCardSecondaryTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: MainButton(
                buttonText: '＋ ボーナスを登録する',
                onPressed: () {
                  final today = ref.read(systemDatetimeNotifierProvider);
                  final newIncome = IncomeEntity(
                    date: DateFormat('yyyyMMdd').format(today),
                    categoryId:
                        IncomeBigCategoryConstants.incomeSourceIdBonus,
                  );
                  showAppModalBottomSheet(
                    context,
                    child: RegisaterPageBase.addIncome(
                      incomeEntity: newIncome,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
