import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_detail_provider.dart';
import 'package:kakeibo/application/fixed_cost_expense/fixed_cost_expense_usecase.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/domain/core/payment_frequency_value/payment_frequency_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/app_inset_group.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/component/success_snackbar.dart';
import 'package:kakeibo/view/fixed_cost_setting_page/fixed_cost_setting_page.dart';
import 'package:kakeibo/view/presentation_mixin.dart';
import 'package:kakeibo/view/register_page/category_area/category_area.dart';
import 'package:kakeibo/view/register_page/common_input_field/const_getter.dart/color_getter.dart';
import 'package:kakeibo/view/register_page/common_input_field/price_input_row/price_input_row.dart';
import 'package:kakeibo/view/register_page/expense_tab/expense_basic_group.dart';
import 'package:kakeibo/view_model/state/register_page/entered_income_source_controller/entered_income_source_controller.dart';
import 'package:kakeibo/view_model/state/register_page/entered_memo_controller.dart';
import 'package:kakeibo/view_model/state/register_page/entered_price_controller.dart';
import 'package:kakeibo/view_model/state/register_page/input_date_controller/input_date_controller.dart';
import 'package:kakeibo/view_model/state/register_page/input_initialized_controller.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

/// 固定費の実績行（expenseのうち fixed_cost_id を持つ行）の編集シート
///
/// 編集できるのは金額・拠出元・メモのみ。固定費グループ（名称・頻度／支払日／予想額）は
/// 表示のみで、変更は「固定費」行から固定費の設定画面で行う（仕様 §6.6）。
class EditFixedCostExpensePage extends ConsumerStatefulWidget {
  const EditFixedCostExpensePage({
    super.key,
    required this.expenseEntity,
  });

  final ExpenseEntity expenseEntity;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditFixedCostExpensePageState();
}

class _EditFixedCostExpensePageState
    extends ConsumerState<EditFixedCostExpensePage> with PresentationMixin {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(registerScreenModeNotifierProvider.notifier)
          .setData(RegisterScreenMode.edit);
      _initializeInputs();
    });

    super.initState();
  }

  /// 入力状態の初期値をセットする
  void _initializeInputs() {
    ref.read(enteredMemoControllerProvider).text = widget.expenseEntity.memo;
    ref
        .read(enteredIncomeSourceControllerNotifierProvider.notifier)
        .setData(widget.expenseEntity.incomeSourceBigCategory);
    ref.read(inputDateControllerNotifierProvider.notifier).setData(
          DateTime.parse(
            '${widget.expenseEntity.date.substring(0, 4)}-${widget.expenseEntity.date.substring(4, 6)}-${widget.expenseEntity.date.substring(6, 8)}',
          ),
        );
    ref.read(inputInitializedControllerProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    final leftsidePadding = 16.0 * context.screenHorizontalMagnification;
    final fixedCostId = widget.expenseEntity.fixedCostId;
    // 未確定行は金額入力＝確定操作。ボタン文言も変える（仕様 §6.6）
    final isUnconfirmed = widget.expenseEntity.isConfirmed == 0;

    if (fixedCostId == null) {
      return const AppErrorState();
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
        backgroundColor: context.colors.surfaceElevated,
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // 上部：支出ピル + 大きな金額表示
                PriceInputRow(
                  mode: RegisterScreenMode.edit,
                  originalPrice: widget.expenseEntity.price ?? 0,
                  showEmptyWhenZero: isUnconfirmed,
                ),

                if (isUnconfirmed) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '金額を入力すると、この月の支払いが確定します',
                      style: AppTextStyles.insetGroupNote,
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),

                // 基本グループ（拠出元／メモ。日付はマスタの支払日が正のため出さない）
                const ExpenseBasicGroup(showDate: false),

                const SizedBox(height: AppSpacing.md),

                // 固定費グループ（表示のみ）
                _buildFixedCostGroup(context, fixedCostId),

                const SizedBox(height: AppSpacing.lg),

                // カテゴリーグリッド（選択状態の表示のみ。変更はマスタ編集からの一括反映に限定）
                Center(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.5,
                      child: CategoryArea(
                        transactionMode: TransactionMode.expense,
                        originalCategoryId:
                            widget.expenseEntity.paymentCategoryId,
                        showRearrangeLink: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: MainButton(
                buttonColor: getPillColor(context, TransactionMode.expense),
                buttonText: isUnconfirmed ? '金額を確定' : '更新',
                onPressed: () => _submit(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 固定費グループ（名称・頻度／支払日／予想額）を組み立てる
  ///
  /// マスタ属性は支出レコードの画面からは変更しない。
  /// 「固定費」行タップで固定費の設定画面へ遷移する（仕様 §6.6）。
  Widget _buildFixedCostGroup(BuildContext context, int fixedCostId) {
    return ref.watch(fixedCostByIdProvider(fixedCostId)).when(
          data: (fixedCost) {
            final frequencyLabel = PaymentFrequencyValue.fromDB(
              intervalNumber: fixedCost.intervalNumber,
              intervalUnitNumber: fixedCost.intervalUnit,
            ).dateLabel;
            final date = widget.expenseEntity.date;

            return AppInsetGroup(
              note: '名称・頻度・支払日・カテゴリーの変更や固定費の削除は「固定費」行から設定画面で行います',
              children: [
                AppInsetRow.navigation(
                  icon: Icons.autorenew_rounded,
                  label: '固定費',
                  value: '${fixedCost.name} ・ $frequencyLabel',
                  onTap: () => _openSettingPage(context, fixedCost),
                ),
                AppInsetRow.display(
                  icon: Icons.calendar_today_outlined,
                  label: '支払日',
                  value: '${int.parse(date.substring(4, 6))}/'
                      '${int.parse(date.substring(6, 8))}',
                ),
                AppInsetRow.display(
                  icon: Icons.trending_up_rounded,
                  label: fixedCost.variable == 1 ? '予想額（過去平均）' : '金額',
                  value: yenmarkFormattedPriceGetter(
                    fixedCost.variable == 1
                        ? fixedCost.estimatedPrice
                        : fixedCost.price,
                  ),
                ),
              ],
            );
          },
          error: (error, stackTrace) => const AppErrorState(),
          loading: () => const SizedBox(height: kAppInsetRowHeight * 3),
        );
  }

  /// 固定費の設定画面（マスタ編集）へ遷移する
  Future<void> _openSettingPage(
    BuildContext context,
    FixedCostEntity fixedCost,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FixedCostSettingPage(fixedCostEntity: fixedCost),
      ),
    );
  }

  /// 金額の確定・更新を実行する
  void _submit(BuildContext context) {
    execute(
      context,
      action: () async {
        final enteredPriceText = ref
            .read(enteredPriceControllerProvider)
            .text
            .replaceAll(RegExp(r'\D'), '');
        final enteredPrice = int.tryParse(enteredPriceText) ?? 0;

        final entity = widget.expenseEntity.copyWith(
          price: enteredPrice,
          memo: ref.read(enteredMemoControllerProvider).text,
          incomeSourceBigCategory:
              ref.read(enteredIncomeSourceControllerNotifierProvider),
        );

        // 未確定行への金額入力は常に確定操作として扱う（仕様 §6.4）
        await ref.read(fixedCostExpenseUsecaseProvider).edit(entity: entity);
      },
      succesAction: () async {
        ref.read(updateDBCountNotifierProvider.notifier).incrementState();
        ref.invalidate(enteredPriceControllerProvider);
        ref.invalidate(enteredMemoControllerProvider);
        ref.invalidate(inputDateControllerNotifierProvider);
        ref.invalidate(inputInitializedControllerProvider);

        Navigator.of(context, rootNavigator: true).pop();

        final rootContext = Navigator.of(context, rootNavigator: true).context;
        SuccessSnackBar.show(
          ScaffoldMessenger.of(rootContext),
          message: '登録が完了しました',
        );
      },
    );
  }
}
